#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""Test functions of population"""


import pytest
import numpy as np
import rasterio as rio
from pathlib import Path

from network_analysis.population import check_pop_file, numpy2coords


def test_check_pop_file(monkeypatch):
    """
    Tests whether the correct population file is selected
    :return:
    """
    # Test case 1: No population file found
    datadir = Path("data")
    pop_file_list = []
    result = check_pop_file(datadir, pop_file_list)
    assert result == (None, False)

    # Test case 2: Single population file found
    pop_file_list = ["./data/pop_file.tif"]
    result = check_pop_file(datadir, pop_file_list)
    assert result == ("./data/pop_file.tif", True)

    # Test case 3: Multiple population files found
    pop_file_list = [
        "./data/pop_file1.tif",
        "./data/pop_file2.tif",
        "./data/pop_file3.tif",
    ]

    # Mocking user input (first invalid second valid)
    user_input = iter(["hello", "2"])
    monkeypatch.setattr("builtins.input", lambda _: next(user_input))

    result = check_pop_file(datadir, pop_file_list)
    assert result == ("./data/pop_file2.tif", True)


def test_numpy2coords():
    """
    Tests whether the numpy columns/rows are correctly transformed to geographic coordinates
    :return:
    """
    transform = rio.transform.from_origin(10000000.0, 7000000.0, 250.0, 250.0)
    indices = np.arange(0, 20, 1).reshape(5, 4)
    selected_index = 0
    expected_x = 10000000.0 + 0.5 * 250
    expected_y = 7000000.0 + 0.5 * -250

    actual_x, actual_y = numpy2coords(indices, selected_index, transform)

    # Assert that the actual values are close to the expected values
    np.testing.assert_almost_equal(actual_x, expected_x, 1)
    np.testing.assert_almost_equal(actual_y, expected_y, 1)
