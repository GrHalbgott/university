#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""Functions to process population data"""


import sys
import logging
import subprocess
import numpy as np
import geopandas as gpd
import rasterio as rio
import rasterio.mask as mask
from pathlib import Path
from shapely.geometry import Point, Polygon


def check_pop_file(datadir: Path, pop_file_list: list):
    """
    Check which population file to use when multiple are found
    :param datadir: path to data directory
    :param pop_file_list: list of population files
    :return: path to population file
    """
    if len(pop_file_list) > 1:
        n_items = len(pop_file_list)
        logging.warning(
            f"Multiple ({n_items}) population files found in {datadir}: {pop_file_list}"
        )
        choose_num = 0
        while choose_num not in range(1, n_items):
            try:
                choose_num = input(
                    f"Which one to use? Enter a number from 1 to {n_items}: \n"
                )
                choose_num = int(choose_num)
            except ValueError:
                logging.error("Error: the input could not be understood, try again.")
        pop_file = pop_file_list[int(choose_num) - 1]
    else:
        pop_file = pop_file_list[0]

    return pop_file


def population_handler(
    datadir: Path, pop_file: Path, aoi_poly: gpd.GeoDataFrame, n_routes: int
):
    """
    Process population file and select random coordinates within the population raster
    :param datadir: path to data directory
    :param pop_file: path to population file
    :param aoi_poly: area of interest polygon
    :param n_routes: number of routes to be calculated
    :return: coordinate lists for start and destination points
    """
    aoi = aoi_poly["geometry"]
    logging.info("Preprocessing population file...")
    pop_file_clip_reproj = preprocess(datadir, pop_file, aoi)

    if pop_file_clip_reproj is None:
        logging.warning("Preprocessing of population file failed.")
        logging.warning(
            "Skipping population distribution based random route generation..."
        )
        return None, None, None, None

    with rio.open(pop_file_clip_reproj) as src:
        population = src.read(1)
        new_transform = src.transform
        nodata = src.nodata
    population = np.where((population == nodata) | (population < 0), 0, population)
    prob = population / population.sum()

    logging.info("Population distribution based random route generation...")
    start_x, start_y = select_random_coords_in_pop(aoi, n_routes, prob, new_transform)
    dest_x, dest_y = select_random_coords_in_pop(aoi, n_routes, prob, new_transform)

    return start_x, start_y, dest_x, dest_y


def preprocess(datadir: Path, pop_file: Path, aoi: Polygon):
    """
    Preprocess population file by clipping and reprojecting
    :param datadir: path to data directory
    :param pop_file: path to population file
    :param aoi: area of interest polygon
    :return: path to preprocessed population file
    """
    out_clip = datadir / "pop_file_clipped.tif"
    out_raster = datadir / "pop_file_clip_proj.tif"
    # clip raster
    try:
        # open the raster in reading mode to be able to write the info to a new raster file
        with rio.open(pop_file, "r") as src:
            aoi_reproj = aoi.to_crs(src.crs)
            out_image, out_transform = mask.mask(src, aoi_reproj, crop=True)
            # take the metadata of the original rasterfile
            out_meta = src.meta.copy()
        out_meta.update(
            {
                "driver": "GTiff",
                "height": out_image.shape[1],
                "width": out_image.shape[2],
                "transform": out_transform,
                "dtype": "float64",
                "nodata": 0,
            }
        )
        # write raster file with new info to file
        with rio.open(out_clip, "w", **out_meta) as dest:
            dest.write(out_image)
    except Exception as e:
        logging.error(f"Error when clipping raster with shapefile: {e}")
        return None
    # reproject raster
    try:
        logging.info("Reprojecting population raster...")
        subprocess.call(
            f"rio warp {out_clip} --dst-crs EPSG:4326 --dst-nodata 0 -o {out_raster}",
            shell=True,
            stdout=subprocess.DEVNULL,
        )  # hardcode
    except Exception as e:
        logging.error(f"Error when reprojecting raster: {e}")
        return None

    return out_raster


def select_random_coords_in_pop(
    aoi: Polygon, n_routes: int, prob: np.ndarray, transform: rio.Affine
):
    """
    Select random coordinates within the population raster
    :param aoi: area of interest polygon
    :param n_routes: number of routes to be calculated
    :param prob: probability of selecting a cell
    :param transform: rasterio.transform.Affine of the raster associated with prob
    :return: list of coordinates for x and y
    """
    start_coords = []
    dest_coords = []
    while len(start_coords) != n_routes:
        valid = None
        while valid is None:
            # select random pixel of raster
            selected_point = Point(*select_pixel(prob, transform))
            # Check if point is within aoi
            valid = selected_point.within(aoi[0])
        start_coords.append(selected_point.x)
        dest_coords.append(selected_point.y)

    assert (
        len(start_coords) == n_routes == len(dest_coords)
    ), "Error: list length of start and destination coordinates do not match!"
    return start_coords, dest_coords


def select_pixel(prob: np.ndarray, transform: rio.Affine):
    """
    Select a random pixel from a raster
    :params prob: the probability for selection of a cell
    :param transform: rasterio.transform.Affine of the raster associated with prob
    :return: return from function numpy2coords
    """
    cell_index = np.arange(0, prob.size, 1)
    selected_index = np.random.choice(a=cell_index, size=1, p=prob.ravel())
    cell_index = cell_index.reshape(prob.shape)

    return numpy2coords(cell_index, selected_index, transform)


def numpy2coords(
    cell_index: np.ndarray, selected_index: np.ndarray, transform: rio.Affine
):
    """
    Return the coordinates of a numpy cell
    :param cell_index: numpy array with cell indices
    :param selected_index: numpy array with selected cell index
    :param transform: rasterio.transform.Affine of the raster
    :return: coordinates of the selected cell in x and y
    """
    row, col = np.where(cell_index == selected_index)
    coords = rio.transform.xy(transform=transform, rows=row, cols=col, offset="center")
    if isinstance(coords[0], list):
        coords_x = coords[0][0]
        coords_y = coords[1][0]

    return coords_x, coords_y
