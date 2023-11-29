#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""Test functions of centrality"""


import pytest
import geopandas as gpd
from shapely.geometry import Point

from network_analysis.centrality import get_bounds, select_random_coords


def test_get_bounds():
    """
    Test if bounds are correctly queried from OSMnx
    :return:
    """
    aoi = "Weinheim"
    skip_aoi = False
    aoi_path = "./data/aoi.geojson"

    expected_bounds = [1, 2, 3, 4]
    expected_minx = 8.6033429
    actual_gdf, actual_bounds = get_bounds(aoi, skip_aoi, aoi_path)

    # Assert that bounds are correctly queried from OSMnx
    assert len(actual_gdf) == 1
    assert len(actual_bounds) == len(expected_bounds)
    assert expected_minx == actual_bounds[0]

    aoi = "help me"
    skip_aoi = False
    aoi_path = "./data/aoi.geojson"

    # Assert that SystemExit is raised if no bounds are found
    with pytest.raises(SystemExit) as exc_info:
        get_bounds(aoi, skip_aoi, aoi_path)

    assert exc_info.value.args[0] == 1


def test_select_random_coords():
    """
    Test if random coordinates are correctly generated
    :return:
    """
    polygon = gpd.GeoDataFrame(
        {"geometry": [Point(0, 0).buffer(1), Point(2, 2).buffer(1)]}
    )
    bounds = (0, 0, 3, 3)
    n_routes = 5

    x_coords, y_coords = select_random_coords(polygon, bounds, n_routes)

    assert len(x_coords) == len(y_coords) == n_routes

    # Assert that all generated coordinates are within the bounds
    for x, y in zip(x_coords, y_coords):
        assert bounds[0] <= x <= bounds[2]
        assert bounds[1] <= y <= bounds[3]

        # Assert that generated coordinates are within the provided GeoDataFrame
        point = Point(x, y)
        assert any(polygon.contains(point))
