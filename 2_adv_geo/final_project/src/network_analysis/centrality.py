#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""Functions to calculate Betweenness Centrality"""


import sys
import logging
import osmnx as ox
import networkx as nx
import pandas as pd
import geopandas as gpd
import numpy as np
from pathlib import Path
from shapely.geometry import Point

import network_analysis.population as pop


ox.settings.use_cache = True


def centrality_handler(
    datadir: Path,
    n_routes: int,
    method: str,
    route_type: str,
    aoi_poly: gpd.GeoDataFrame,
    aoi_bounds: tuple,
    graph: nx.MultiDiGraph,
    weight: str,
    use_pop: bool,
    pop_file_list: list,
):
    """
    Handle centrality calculation
    :param datadir: path to data directory
    :param n_routes: number of routes
    :param method: method to be used
    :param route_type: type of route to be used
    :param aoi_poly: polygon of area of interest
    :param aoi_bounds: bounds of area of interest
    :param graph: nx.MultiDiGraph containing edges and nodes
    :param weight: weight to be used for calculation
    :param use_pop: use population file to create random points
    :param pop_file_list: list of population files
    :return: dataframe with centrality values
    """
    key_list = ["u", "v", "key"]
    if method == "nx":
        logging.info(f"Calculating betweenness centrality for {route_type} routes...")
        try:
            centrality_df = calculate_centrality(graph, weight, key_list)
        except Exception as e:
            logging.error(f"Error when calculating betweenness centrality: {e}")
            sys.exit(1)
    else:
        logging.info(
            "Calculating geographically informed betweenness centrality (GIBC)..."
        )
        try:
            centrality_df = gibc(
                graph,
                aoi_poly,
                aoi_bounds,
                weight,
                n_routes,
                key_list,
                use_pop,
                pop_file_list,
                datadir,
            )
        except Exception as e:
            logging.error(f"Error when calculating GIBC: {e}")
            sys.exit(1)

    return centrality_df


def calculate_centrality(graph: nx.MultiDiGraph, weight: str, key_list: list):
    """
    Calculate betweenness centrality and prepare dataframe
    :param graph: nx.MultiDiGraph containing edges and nodes
    :param weight: weight to be used for calculation
    :param key_list: list of keys for index
    :return: nx.MultiDiGraph with added centrality values
    """
    centrality = nx.edge_betweenness_centrality(graph, weight=weight)

    logging.info("Create dataframe with centrality values...")
    centrality_df = pd.DataFrame(index=centrality.keys(), data=centrality.values())
    centrality_df.reset_index(inplace=True)
    centrality_df.columns = key_list + ["centrality"]
    centrality_df = centrality_df.set_index(key_list)

    return centrality_df


def gibc(
    graph: nx.MultiDiGraph,
    aoi_poly: gpd.GeoDataFrame,
    aoi_bounds: tuple,
    weight: str,
    n_routes: int,
    key_list: list,
    use_pop: bool,
    pop_file_list: list,
    datadir: Path,
):
    """
    Calculate geographically informed betweenness centrality (GIBC)
    :param graph: nx.MultiDiGraph containing edges and nodes
    :param aoi_poly: polygon of area of interest
    :param aoi_bounds: bounds of area of interest
    :param weight: weight to be used for calculation
    :param n_routes: number of routes to be calculated
    :param key_list: list of keys for index
    :param use_pop: use population file to create random points
    :param pop_file_list: list of population files
    :param datadir: path to data directory
    :return: dataframe with centrality values
    """
    try:
        logging.info("Creating random routes...")
        if use_pop:
            pop_file = pop.check_pop_file(datadir, pop_file_list)
            start_x, start_y, dest_x, dest_y = pop.population_handler(
                datadir, pop_file, aoi_poly, n_routes
            )
        else:
            start_x, start_y = select_random_coords(aoi_poly, aoi_bounds, n_routes)
            dest_x, dest_y = select_random_coords(aoi_poly, aoi_bounds, n_routes)

        start_nodes = ox.nearest_nodes(graph, start_x, start_y)
        dest_nodes = ox.nearest_nodes(graph, dest_x, dest_y)

        routes = ox.shortest_path(graph, start_nodes, dest_nodes, weight=weight)

        routes_list = []
        invalid = 0
        routes = ox.shortest_path(graph, start_nodes, dest_nodes, weight="travel_time")
        for route in routes:
            if route is None or len(route) <= 1:
                invalid += 1
                continue
            else:
                routes_list.append(ox.utils_graph.route_to_gdf(graph, route))
    except Exception as e:
        logging.error(f"Error when creating random routes: {e}")
        sys.exit(1)

    logging.info(f"Number of routes: {len(routes)}")
    logging.info(f"Number of invalid routes: {invalid}")
    logging.info("Merging routes...")
    merged_routes_df = pd.concat(routes_list, axis=0)

    logging.info("Calculating centrality...")
    try:
        centrality = (
            merged_routes_df.groupby(key_list)
            .size()
            .reset_index()
            .rename(columns={0: "centrality"})
            .set_index(key_list)
        )
    except Exception as e:
        logging.error(f"Error when calculating centrality: {e}")
        sys.exit(1)

    return centrality


def join_edges(centrality: pd.DataFrame, edges: gpd.GeoDataFrame):
    """
    Join edges to centrality dataframe
    :param centrality: centrality df
    :param edges: edges gdf
    :return: geodataframe
    """
    df = centrality.join(edges[["osmid", "geometry"]])
    gdf = gpd.GeoDataFrame(df, crs=4326)

    return gdf


def select_random_coords(aoi_poly: gpd.GeoDataFrame, bounds: tuple, n_routes: int):
    """
    Returns random x and y coordinates within bounds
    :param: aoi_poly: polygon of area of interest
    :param: bounds: tuple of total bounds of edges/graph
    :param: n_routes: number of routes to be calculated
    :return: coordinate lists for x and y
    """
    minx, miny, maxx, maxy = bounds
    x_coords = []
    y_coords = []
    coords = []
    while len(coords) < n_routes:
        within = None
        while within is None:
            x = np.random.uniform(minx, maxx)
            y = np.random.uniform(miny, maxy)
            within = aoi_poly.contains(Point(x, y))
        x_coords.append(x)
        y_coords.append(y)
        coords.append((x, y))

    return x_coords, y_coords
