#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""Class to represent a rectangle"""


import numpy as np


class Rectangle:
    """Rectangle geometry"""

    def __init__(self, minx: float, miny: float, maxx: float, maxy: float):
        """
        Constructs a Rectangle object based on the minimum and maximum x and y coordinates
        :param minx: Minimum x coordinate
        :param miny: Minimum y coordinate
        :param maxx: Maximum x coordinate
        :param maxy: Maximum y coordinate
        """
        self.minx = minx
        self.maxx = maxx
        self.miny = miny
        self.maxy = maxy

    def check_arguments(self):
        """
        Test whether the types of values are correct
        :return: 4 values for creation of rectangle
        """
        if (
            not isinstance(self.minx, (float))
            and isinstance(self.maxx, (float))
            and isinstance(self.miny, (float))
            and isinstance(self.maxy, (float))
        ):
            raise ValueError

    def coordinates_rectangle(self):
        """Returns coordinates as list"""
        return [self.minx, self.miny, self.maxx, self.maxy]

    def get_area(self):
        """
        Calculates rectangle area using the formula: a×b
        :return: area of the rectangle
        """
        return (self.maxx - self.minx) * (self.maxy - self.miny)

    def get_perimeter(self):
        """
        Calculates perimeter of rectangle using formula: 2a+2b
        :return: perimeter of the rectangle
        """
        return (self.maxx - self.minx) * 2 + (self.maxy - self.miny) * 2

    def __str__(self):
        """Returns a formatted string with details about the Rectangle object"""
        return (
            "Rectangle, minx={:0.2f}, maxx={:0.2f}, miny={:0.2f}, maxy={:0.2f}".format(
                self.minx, self.maxx, self.miny, self.maxy
            )
        )


"""Class to represent a circle"""


class Circle:
    """Circle geometry"""

    def __init__(self, centerx, centery, radius):
        """
        Constructs a Circle object based on a centroid and a radius around it
        :param centerx: x coordinate
        :param centery: y coordinate
        :param radius: radius value
        """
        self.centerx = centerx
        self.centery = centery
        self.radius = radius

    def check_arguments(self):
        """
        Test whether the types of values are correct
        :return: 4 values for creation of rectangle
        """
        if (
            not isinstance(self.centerx, (float, int))
            and isinstance(self.centery, (float, int))
            and isinstance(self.radius, (float, int))
        ):
            raise ValueError

    def get_area(self):
        """
        Calculates circle area using the formula: π * r²
        :return: area of the circle
        """
        return round(np.pi * self.radius**2, 5)

    def get_perimeter(self):
        """
        Calculates perimeter of rectangle using formula: 2π * r
        :return: perimeter of the rectangle
        """
        return round(2 * np.pi * self.radius, 5)

    def __str__(self):
        """Returns a formatted string with details about the Circle object"""
        return "Circle, centerx={:0.2f}, centery={:0.2f}, radius={:0.2f}".format(
            self.centerx, self.centery, self.radius
        )
