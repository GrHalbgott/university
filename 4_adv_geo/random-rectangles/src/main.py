#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""Generates random rectangles"""


from geometry import Rectangle
from geometry import Circle
import numpy as np
import pandas as pd
from shapely.geometry import box
import matplotlib.pyplot as plt
import os
import sys

os.chdir(sys.path[0])


def plot_rectangles(dataframe: pd.DataFrame):
    """
    Creates a plot with all rectangles in the dataframe
    :param dataframe: Dataframe containing rectangles
    """
    fig, axes = plt.subplots(1, 1)
    for _, r in dataframe.iterrows():
        poly = box(*r["geometry"].coordinates_rectangle())
        axes.plot(*poly.exterior.xy)
    plt.savefig("../data/rectangles.png", layout="tight")


def main():
    """
    Generates random rectangles, calculates their area and perimeter and saves it in a pandas.DataFrame
    :return:
    """
    n_objects = 10
    x_range = (0, 50)
    y_range = (0, 50)
    r_range = (0, 10)

    # Create rectangle objects
    rectangles = {}
    for i in range(n_objects):
        minx = np.random.uniform(low=x_range[0], high=x_range[1])
        miny = np.random.uniform(low=y_range[0], high=y_range[1])
        maxx = np.random.uniform(low=x_range[0], high=x_range[1])
        maxy = np.random.uniform(low=y_range[0], high=y_range[1])

        new_rectangle = Rectangle(minx=minx, maxx=maxx, miny=miny, maxy=maxy)

        r_area = new_rectangle.get_area()
        r_perimeter = new_rectangle.get_perimeter()

        rectangles[i] = {
            "area": r_area,
            "perimeter": r_perimeter,
            "geometry": new_rectangle,
        }

    # Save in dataframe and write to csv file
    rectangles_df = pd.DataFrame().from_dict(rectangles, orient="index")
    rectangles_df.to_csv("../data/rectangles.csv")

    plot_rectangles(rectangles_df)

    # Create Circle objects
    circles = {}
    for i in range(n_objects):
        centerx = np.random.uniform(low=x_range[0], high=x_range[1])
        centery = np.random.uniform(low=y_range[0], high=y_range[1])
        radius = np.random.uniform(low=r_range[0], high=r_range[1])

        new_circle = Circle(centerx=centerx, centery=centery, radius=radius)

        c_area = new_circle.get_area()
        c_perimeter = new_circle.get_perimeter()

        circles[i] = {"area": c_area, "perimeter": c_perimeter, "geometry": new_circle}

    # Save in dataframe and write to csv file
    circles_df = pd.DataFrame().from_dict(circles, orient="index")
    circles_df.to_csv("../data/circles.csv")


if __name__ == "__main__":
    main()