import logging
import os
import requests
import sys
import warnings
import yaml
from pathlib import Path
from typing import Tuple, List

import geopandas as gpd
import numpy as np
import pandas as pd
from geocube.api.core import make_geocube
from hydra.core.hydra_config import HydraConfig
from ohsome import OhsomeClient
from rasterio.enums import Resampling
from shapely.geometry import LineString, MultiLineString, box
from sklearn.preprocessing import OneHotEncoder

log_level = os.getenv('LOG_LEVEL', 'INFO')
log_config = 'conf/logging/app/logging.yaml'
log = logging.getLogger(__name__)

pd.set_option('future.no_silent_downcasting', True)


class RoadNetwork:

    def __init__(self, cache_dir: Path):
        """Initialize the RoadNetwork class."""

        # Define cache directory
        self.cache_dir: Path = cache_dir
        self.cache_dir.mkdir(parents=True, exist_ok=True)
        # Define logging directory
        log_dir = HydraConfig.get().runtime.output_dir if HydraConfig.initialized() else None
        # Initialize ohsome client
        self.ohsome = OhsomeClient(user_agent='nkolaxidis/LULC', log_dir=log_dir, log=HydraConfig.initialized())

        # Read asset file with road network specifics
        with open('./assets/road_network.yaml', 'r') as src:
            asset = yaml.safe_load(src)
        attributes = ['tags', 'road_types', 'road_types_optimized', 'country_iso', 'speed_cols', 'speed_zone_types', 'speed_limit_classes']
        for attr in attributes:
            setattr(self, attr, asset[attr])

    ################
    # Road Network #
    ################

    def load_road_network(self, area_coords: Tuple[float, float, float, float],
                          time: str,
                          utm: str,
                          target_size: Tuple[int, int],
                          bbox_id: str = None) -> gpd.GeoDataFrame:
        """This class method requests the road network from the ohsome API, caches it after preprocessing and returns it.

        :param area_coords: tuple of area coordinates (min_x, min_y, max_x, max_y)
        :param time: timestamp of the request
        :param utm: UTM projection string, derived from osm_operator.py
        :param target_size: tuple of target size (height, width), derived from imagery_store_operator.py
        :param bbox_id: uuid of the area, derived from osm_operator.py

        :return: preprocessed gpd.GeoDataFrame with road network data, loaded from cache
        """
        # Define cache file location
        cache_file = self.cache_dir / f'{bbox_id}.feather'
        # Define bbox from area coordinates
        self.bbox = area_coords
        # Define utm projection
        self.utm = utm
        # Define target size
        self.target_size = target_size
        # Define road types filter for the request from the ohsome API
        road_types_filter = ','.join([f'{road_type}' for road_type in self.road_types])

        if not cache_file.exists():
            # Request road network from ohsome API
            try:
                response = self.ohsome.elements.geometry.post(
                    bboxes = area_coords,
                    filter = f'highway in ({road_types_filter}) and type:way and geometry:line',
                    time = time,
                    properties = 'tags'
                ).as_dataframe()
            except Exception as err:
                log.error(f'Requesting road network from ohsome API failed: {err}')
                sys.exit()

            # Preprocess response and save as feather file
            self.preprocess(response).to_feather(cache_file)

        if cache_file.exists():
            # Load feather file
            return gpd.read_feather(cache_file)
        else:
            log.error(f'Loading road network from cache failed: {cache_file} does not exist')
            sys.exit()

    def preprocess(self, response: gpd.GeoDataFrame) -> gpd.GeoDataFrame:
        """This class method preprocesses the response from the ohsome API.

        :param response: gpd.GeoDataFrame with raw road network data
        :param utm: UTM projection string, derived from osm_operator.py

        :return: gpd.GeoDataFrame with preprocessed road network data
        """
        # Remove all non (Multi-)LineString geometries (primarily relics/false geometries)
        with warnings.catch_warnings():
            warnings.filterwarnings('ignore', category=FutureWarning) # already in line with future changes
            roads_linestrings = response[response['geometry'].astype(object).apply(lambda geom: isinstance(geom, (LineString, MultiLineString)))]

        # Break up multi-index
        roads_linestrings.reset_index(inplace=True)
        if roads_linestrings['@osmId'].is_unique:
            roads_linestrings = roads_linestrings.set_index('@osmId')

        # Apply a lanebased buffer to motorways and trunks
        roads_linestrings.to_crs(self.utm, inplace=True)
        highways_mask = roads_linestrings['highway'].isin(['motorway', 'motorway_link', 'trunk', 'trunk_link'])
        roads_linestrings.loc[highways_mask, 'geometry'] = roads_linestrings.loc[highways_mask].apply(self.__lanecountbased_buffer, axis=1)
        roads_linestrings.to_crs(4326, inplace=True)

        # Only keep columns specified in road_network.yaml
        tags = [tag.strip() for tag in self.tags]
        tags_to_keep = [col for col in tags if col in roads_linestrings.columns]

        # Return cleaned and preprocessed road network
        return roads_linestrings[tags_to_keep]

    @staticmethod
    def __lanecountbased_buffer(row):
        """Apply dynamic buffer to motorways and trunks based on lane count."""
        # Data from FGSV.2011 - max width values for EKA 1 roads if not specified otherwise
        if row['lanes'] == '2' and row['highway'] in ('motorway_link', 'trunk_link'):
            value = 9.5
        elif row['lanes'] == '2' and row['highway'] == 'trunk': # EKA 2
            value = 28 / 2
        elif row['lanes'] == '2' and row['highway'] == 'motorway':
            value = 31 / 2
        elif row['lanes'] == '3': # Connectors with > 2 lanes not possible in Germany -> regulations
            value = 36 / 2
        elif row['lanes'] == '4':
            value = 43.5 / 2
        else: # If lanes == nan or 1 (motorways/trunks with 1 lane not possible in Germany -> regulations)
            return row['geometry'].buffer(6) # Single connector lane width

        return row['geometry'].buffer(value)

    ##############
    # Extensions #
    ##############

    def boolean_road_network(self, road_network: gpd.GeoDataFrame) -> np.ndarray[np.uint8]:
        """This class method rasterizes the geometry of the road network data.

        :return: np.ndarray with rasterized road network data as raster band
        """

        return self.rasterize_road_network(road_network)

    def encode_rasterize_category(self, road_network: gpd.GeoDataFrame,
                        categorical_vals: List[str],
                        categorical_col: str) -> np.ndarray[np.uint8]:
        """This class method rasterizes the one-hot encoded categorical values of the road network.

        :param road_network: gpd.GeoDataFrame with road network data
        :param categorical_vals: list of possible values to encode
        :param categorical_col: column with categorical_vals to encode

        :return: np.ndarray with rasterized categorical values as raster bands
        """
        # Preprocess the road network based on the categorical column
        if categorical_col == 'highway':
            road_network = self.__categorize_road_types(road_network)
        elif categorical_col == 'speed_limit_class':
            if not hasattr(self, 'country_speeds') or not hasattr(self, 'self.speed_zone_types_mapping'):
                self.load_speed_data()
            road_network = self.feature_engineer_maxspeeds(road_network)
            road_network = self.categorize_speed_limits(road_network)

        # One-hot encode the categorical column of the road network
        road_network_category_encoded = self.__one_hot_encode(road_network, categorical_vals, categorical_col)

        # Create empty 3D numpy array for storing the rasterized categorical values
        rasterized_road_network = np.empty((self.target_size[0], self.target_size[1], len(categorical_vals)), dtype=np.uint8)

        # Iterate through the categorical values list and rasterize each value
        for i, cat_val in enumerate(categorical_vals):
            # Extract true encoded categorical values from road network
            category_gdf = road_network_category_encoded.loc[road_network_category_encoded[cat_val] != 0, ['geometry', cat_val]]
            # Rasterize categorical values and add to road network raster as new band
            rasterized_road_network[:, :, i] = self.rasterize_road_network(category_gdf)

        # Return np.ndarray with rasterized categorical values as bands
        return rasterized_road_network

    ##############
    # Road types #
    ##############

    @staticmethod
    def __categorize_road_types(road_network):
        """Reduce the road types count of the road network."""
        road_type_mapping = {
            # Merge to residential due to similar LULC relationship
            'pedestrian': 'residential',
            'living_street': 'residential',
            # Merge to highways due to observability in satellite imagery
            'motorway': 'highways',
            'motorway_link': 'highways',
            'trunk': 'highways',
            'trunk_link': 'highways',
        }
        # Apply mapping dictionary
        road_network['highway'] = road_network['highway'].replace(road_type_mapping)
        return road_network

    ################
    # Speed limits #
    ################

    def load_speed_data(self):
        """This class method loads speed data from file and creates a mapping dict of speed zone types."""
        # Query OSM speed data
        speeds_request = requests.get(
            r'https://raw.githubusercontent.com/GIScience/openrouteservice/master/ors-engine/src/main/resources/resources/services/routing/speed_limits/car.json'
        )
        if speeds_request.status_code == 200:  # Status == OK
            hwy_speeds = speeds_request.json()
            self.country_speeds = hwy_speeds['max_speeds']
            self.default_speeds = hwy_speeds['default']
        else:
            log.error(f'Error when requesting ORS for speed limits: {speeds_request.status_code}')
            sys.exit()

        # Create speed type mapping dictionary
        self.speed_zone_types_mapping = {
            **{f'{key}': self.country_speeds.get(f'{self.country_iso}:{key}', self.default_speeds.get(key)) for key in self.speed_zone_types},
            'walk': self.country_speeds.get(f'{self.country_iso}:living_street', self.default_speeds.get('living_street')),
            'variable': np.nan,
            # none != Nan, so set to 255 as 'unlimited'
            'none': 255,
        }

    def feature_engineer_maxspeeds(self, road_network: gpd.GeoDataFrame) -> gpd.GeoDataFrame:
        """This class method feature engineers the maxspeed column by utilizing mapping dictionaries and other columns with speed values."""
        # Remove all occurrences of 'sign'
        road_network = road_network.replace('sign', np.nan, regex=False)

        # Enrich source:maxspeed by merging other columns
        for column in self.speed_cols:
            # Create col if it doesn't exist
            road_network[column] = road_network[column] if column in road_network.columns else np.nan
            # Add vales from col to source:maxspeed
            if road_network['source:maxspeed'].isna().any():
                road_network['source:maxspeed'] = road_network['source:maxspeed'].fillna(road_network[column])

        road_network = self.__cleanup_speed_column(road_network, 'source:maxspeed', self.speed_zone_types_mapping)
        road_network = self.__cleanup_speed_column(road_network, 'maxspeed', self.speed_zone_types_mapping)

        # Replace values in maxspeed with mapping_dict
        road_network['maxspeed'] = road_network['maxspeed'].replace(self.speed_zone_types_mapping)
        # Replace values in source:maxspeed only when maxspeed is Nan (if maxspeed exists, filling not necessary)
        road_network.loc[road_network['maxspeed'].isna(), 'source:maxspeed'] = road_network['source:maxspeed'].replace(self.speed_zone_types_mapping)
        # Fill Nans in maxspeed with enriched source:maxspeed, fill remaining Nans with zeros
        road_network['maxspeed'] = road_network['maxspeed'].fillna(road_network['source:maxspeed']).fillna(0)

        def assign_maxspeeds_from_file(row):
            # Create adapted mapping dictionary using the speed file and highway type
            file_mapping_dict = {
                **{key: self.country_speeds.get(f'{self.country_iso}:{key}', self.default_speeds.get(row['highway'])) for key in self.speed_zone_types_mapping.keys()},
                # Check if highway type in default speeds, else set to 0
                'default': self.default_speeds.get(row['highway'], 0)
            }

            return file_mapping_dict.get(row['maxspeed'], row['maxspeed'])

        # Get speed values for speed type maxspeeds
        road_network['maxspeed'] = road_network.apply(assign_maxspeeds_from_file, axis=1)
        # Convert maxspeed values to integers
        road_network['maxspeed'] = road_network['maxspeed'].astype(int)

        # Return road network with feature engineered maxspeed, drop used cols except last one (maxspeed)
        return road_network.drop(columns=self.speed_cols[:-1], errors='ignore')

    def categorize_speed_limits(self, road_network: gpd.GeoDataFrame) -> gpd.GeoDataFrame:
        """This class method categorizes the speed limits of the road network."""
        road_network['speed_limit_class'] = (
            pd.cut(
                road_network['maxspeed'],
                bins=self.speed_limit_classes['class_bounds'],
                labels=self.speed_limit_classes['class_labels'],
                include_lowest=True,
                ordered=True
            )
        )
        # Drop all roads without assigned speed limit class
        road_network.dropna(subset=['speed_limit_class'], inplace=True)
        # Convert categorical col to strings (for OHE)
        road_network['speed_limit_class'] = road_network['speed_limit_class'].astype(str)

        return road_network


    @staticmethod
    def __cleanup_speed_column(df, column_name, mapping_dict):
        df[column_name] = (
            df[column_name]
            # Replace all points with colons (points are probably wrongly mapped)
            .str.replace('.', ':', regex=False)
            # Remove everything before and including a colon ':' (e.g. DE:zone30 -> zone30)
            .str.replace('^.*?:', '', regex=True)
            # Remove all occurrences of 'zone' (e.g. zone30 -> 30)
            .str.replace('zone', '', regex=False)
            # If remaining values are empty strings, convert them to Nan
            .replace('', np.nan)
        )
        # Check remains: if one of the conditions is True, keep value
        df[column_name] = df[column_name].where(
            # If value is Nan
            df[column_name].isna() |
            # If value is in speed_zone_types_mapping keys
            df[column_name].isin(mapping_dict.keys()) |
            # If value is a digit
            df[column_name].str.isdigit() |
            # Default values get assigned later on (special case)
            (df[column_name] == 'default')
        )
        return df

    ############################
    # Rasterization & Encoding #
    ############################

    def rasterize_road_network(self,
                  gdf: gpd.GeoDataFrame,
                  val_col: str = 'value',
                  resolution = (.0001, .0001)) -> np.ndarray[np.uint8]:
        """This class method rasterizes the given road network data.

        :param gdf: gpd.GeoDataFrame with road network data
        :param area_coords: tuple of area coordinates (min_x, min_y, max_x, max_y)
        :param val_col: column name of values
        :param resolution: tuple of resolution in degrees

        :return: np.ndarray with rasterized road network data
        """
        # Calculate extent from bbox
        extent = gpd.GeoDataFrame(index=['extent'],
                                  crs='epsg:4326',
                                  geometry=[box(*self.bbox, ccw=True)])

        # Add val_col with boolean values
        gdf[val_col] = 1
        extent[val_col] = 0

        # Extend df with extent
        vector_data = pd.concat([gdf, extent], ignore_index=True)

        # Sort by descending area to stack road network (smaller) on top of background (larger)
        sorted_desc_areas_idx = vector_data.copy().to_crs(self.utm).geometry.area.argsort()[::-1]

        # Create geocube (xarray.Dataset) from gdf
        geocube = make_geocube(
            vector_data=vector_data.iloc[sorted_desc_areas_idx],
            measurements=[val_col],
            resolution=resolution,
            output_crs='EPSG:4326',
            fill=0
        ).astype(np.uint8)

        # Resample geocube values (xarray.DataArray) to target_size from imagery
        raster_data = geocube[val_col].rio.reproject(geocube[val_col].rio.crs, shape=self.target_size, resampling=Resampling.bilinear)

        # Return np.ndarray of raster values
        return raster_data.values

    @staticmethod
    def __one_hot_encode(gdf: gpd.GeoDataFrame,
                         categorical_vals: List[str],
                         categorical_col: str) -> gpd.GeoDataFrame:
        """One-hot encode a select column of given road network data.

        :param gdf: gpd.GeoDataFrame with road network data
        :param categorical_vals: list of possible values to encode
        :param categorical_col: column with categorical_vals to encode

        :return: gpd.GeoDataFrame with one-hot encoded categorical values
        """
        # One-hot encode the categorical column
        ohe = OneHotEncoder(sparse_output=False, dtype=np.uint8, categories=[categorical_vals])
        # Fit on all possible categorical_vals (list as DataFrame)
        ohe.fit(pd.DataFrame(categorical_vals, columns=[categorical_col]))

        # Transform the current road network and replace missing values with 'unknown'
        ohe_encoded = ohe.transform(gdf[[categorical_col]].fillna('unknown'))

        # Add encoded columns to road network
        for i, category in enumerate(ohe.categories_[0]):
            if category in gdf[categorical_col].unique():
                gdf[category] = ohe_encoded[:, i]
            else:
                # Fill missing category value column with zeros
                gdf[category] = 0

        # Return road network with added one-hot encoded columns
        return gdf
