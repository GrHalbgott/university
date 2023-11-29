#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""Functions to read and write files"""


import networkx as nx
import osmnx as ox
import numpy as np
import geopandas as gpd
import rasterio as rio
import matplotlib.pyplot as plt
from pathlib import Path


def outname_creator(
    aoi: str, method: str, route_type: str, n_routes: int, use_pop: bool
):
    """
    Create name for output
    :param aoi: name of the area of interest
    :param method: method used for the calculation
    :param route_type: route type used for the calculation
    :param n_routes: number of routes used for the calculation
    :param use_pop: whether population data was used
    :return: output name
    """
    aoiname = aoi.split(",")[0].strip()
    method = method.strip()
    route_type = route_type.strip()
    if method == "gibc":
        outname = f"{aoiname}_{method}_{n_routes}"
        if use_pop:
            outname += "_pop"
    else:
        outname = f"{aoiname}_{method}_{route_type}"
    return outname.strip()


def subfolder_creator(outdir: Path, outname: str):
    """
    Create subfolder for output
    :param outdir: output directory
    :param outname: output name
    :return: output folder name
    """
    outfolder = outdir / outname
    outfolder.mkdir(parents=True, exist_ok=True)
    return outfolder


def save_graph(aoi: str, outdir: Path, graph: nx.MultiDiGraph):
    """Save graph as png"""
    outfile = outdir / f"{aoi}_graph.png"
    if not outfile.exists():
        ox.plot_graph(
            graph, node_size=5, show=False, save=True, filepath=outfile, dpi=200
        )


def save_population_rater(datadir: Path, outdir: Path, aoi: str):
    """Save population raster as png"""
    outfile = outdir / f"{aoi}_population_raster.png"
    enlarge_by = 7
    if not outfile.exists():
        file = rio.open(datadir / "pop_file_clipped.tif")
        data = file.read(1)
        data = data.repeat(enlarge_by, axis=0).repeat(
            enlarge_by, axis=1
        )  # enlarge image 5 times
        plt.imsave(outfile, data, cmap="viridis", vmin=0, dpi=200)


def write_gdf(gdf: gpd.GeoDataFrame, outfolder: Path, outname: str):
    """Export GeoDataFrame as GeoPackage"""
    gdf["osmid"] = gdf["osmid"].apply(
        lambda x: str(x)
    )  # fix for wrong type (list) in "osmid"
    gdf.to_file(outfolder / f"{outname}.gpkg", driver="GPKG", mode="w")


def save_figure(gdf: gpd.GeoDataFrame, outfolder: Path, outname: str, n_routes: int):
    """Export figure as png"""
    params = outname.split("_")
    ax = gdf.plot(column="centrality", cmap="magma_r", legend=True)
    ax.set_facecolor("#d9d9d9")
    if params[1] == "gibc":
        ax.set(
            title=f"Geographically Informed Betweenness Centrality\nfor {params[0].title()}, n = {n_routes}"
        )
    else:
        ax.set(
            title=f"Betweenness Centrality for {params[0].title()}\nusing {params[2]} routes"
        )
    plt.savefig(outfolder / f"{outname}.png", bbox_inches="tight", dpi=200)


def cleanup_temp(datadir: Path):
    """Delete temporary files from ./data/"""
    for item in list(datadir.iterdir()):
        if item in list(datadir.glob("*_clip*.tif")):
            item.unlink()
