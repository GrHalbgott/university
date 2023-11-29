#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""Functions to preprocess the graph"""


import sys
import requests
import logging
import osmnx as ox
import networkx as nx
import geopandas as gpd
from pathlib import Path


ox.settings.use_cache = True


def get_bounds(aoi: str, skip_aoi: bool, aoi_path: Path):
    """
    Get bounds from file or query OSMnx
    :param aoi: name of the area of interest
    :param aoi_path: path to area of interest
    :return: polygon geometry and coordinate list of bounds
    """
    if Path(aoi_path).exists() and skip_aoi is False:
        try:
            aoi_poly = gpd.read_file(aoi_path, encoding="utf-8").to_crs(epsg=4326)
        except Exception as e:
            logging.exception(f"Error when reading AOI file: {e}")
            sys.exit(1)
    else:
        logging.info("Aoi file not found. Trying to query it...")
        try:
            aoi_poly = ox.geocode_to_gdf(aoi).to_crs(epsg=4326)
        except requests.exceptions.ConnectionError as e:
            logging.error(
                f"Error when requesting OSMnx: {e}. Please check your internet connection."
            )
            sys.exit(1)
        except TypeError:
            logging.exception(
                f"Error when requesting OSMnx: Nominatim could not geocode query {aoi}. Please check your AOI (Nominatim API conformity)"
            )
            sys.exit(1)

    return aoi_poly, aoi_poly.total_bounds


def get_graph(aoi_poly: gpd.GeoDataFrame):
    """
    Query OSMnx to create a graph from a geocode
    :param aoi: name of the area of interest
    :return: graph containing edges and nodes
    """
    poly = aoi_poly.iloc[0]["geometry"]
    graph = ox.graph_from_polygon(poly, network_type="drive")

    return graph


def extract_edges(graph: nx.MultiDiGraph):
    """
    Extract edges from graph and covert to geodataframe
    :param graph: graph containing edges and nodes
    :return: geodataframe
    """
    edges_gdf = ox.graph_to_gdfs(graph)[1]  # 0 = nodes, 1 = edges

    return edges_gdf


def add_travel_times(graph: nx.MultiDiGraph):
    """
    Add travel times to graph for fastest routes
    :param graph: nx.MultiDiGraph containing edges and nodes
    :return: nx.MultiDiGraph with added travel speeds
    """
    # Get and read file from ORS for road speeds
    r = requests.get(
        r"https://raw.githubusercontent.com/GIScience/openrouteservice/master/ors-engine/src/main/resources/resources/services/routing/speed_limits/car.json"
    )
    if r.status_code == 200:  # Status == OK
        hwy_speeds = r.json()["default"]

    graph_with_speeds = ox.add_edge_speeds(graph, hwy_speeds)
    graph_with_travel_times = ox.speed.add_edge_travel_times(graph_with_speeds)

    return graph_with_travel_times
