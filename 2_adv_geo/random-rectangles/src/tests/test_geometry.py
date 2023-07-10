#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""Tests classes in geometry module"""

from geometry import Rectangle


def test_rectangle_get_area():
    """
    Test whether the area is calculated correctly
    :return: 4 values for creation of rectangle
    """
    # Given: Test values and expected result
    minx = 0
    maxx = 3
    miny = 0
    maxy = 3
    expected_area = 9

    # When: Create rectangle objects and call functions which should be tested
    new_rectangle = Rectangle(
        minx=minx,
        maxx=maxx,
        miny=miny,
        maxy=maxy,
    )
    actual_area = new_rectangle.get_area()

    # Then: Check if actual result is equal to expected result
    assert actual_area == expected_area


def test_rectangle_get_perimeter():
    """
    Test whether the perimeter is calculated correctly
    :return:
    """
    # Given: Test values and expected result
    minx = 0
    maxx = 3
    miny = 0
    maxy = 3
    expected_perimeter = 12

    # When: Create rectangle objects and call functions which should be tested
    new_rectangle = Rectangle(
        minx,
        maxx,
        miny,
        maxy,
    )
    actual_perimeter = new_rectangle.get_perimeter()

    # Then: Check if actual result is equal to expected result
    assert actual_perimeter == expected_perimeter
