#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""Utility functions"""


import sys
import argparse
import logging
import json


def _check_system_arguments():
    """Check and parse system arguments using argparse"""
    help_msg = "Calculate betweenness centrality. You can use the following options to adapt the calculation to your needs. Have fun!"
    parser = argparse.ArgumentParser(description=help_msg, prefix_chars="-")
    parser._action_groups.pop()
    # use two groups of inputs (required and optional)
    required_args = parser.add_argument_group("required arguments")
    optional_args = parser.add_argument_group("optional arguments")
    required_args.add_argument(
        "-aoi",
        metavar="Area of interest",
        dest="aoi",
        help="String | Name of the aoi (geocode or name of file)",
        required=True,
    )
    optional_args.add_argument(
        "-skip",
        action="store_true",
        dest="skip_aoi",
        help="Flag | Use this to skip the aoi file in the data folder and query the -aoi instead.",
    )
    optional_args.add_argument(
        "-pop",
        action="store_true",
        dest="use_pop",
        help="Flag | Use this to use the population file to create random points depending on population density (during GIBC).",
    )
    optional_args.add_argument(
        "-n",
        metavar="Number of routes",
        dest="n_routes",
        help="Integer | Number of routes to be calculated. Default value: 100",
        default=100,
    )
    optional_args.add_argument(
        "-m",
        metavar="Method",
        dest="method",
        help="String | Method to calculate centrality {networkx/nx or geographical/gibc}. Default value: nx",
        default="nx",
    )
    optional_args.add_argument(
        "-rt",
        metavar="Route type",
        dest="route_type",
        help="String | Route type used for the calculation {shortest, fastest}. Default value: shortest",
        default="shortest",
    )
    optional_args.add_argument(
        "-out",
        metavar="Output directory",
        dest="out_dir",
        help="String | Name of output directory. Default value: output",
        default="output",
    )

    # show help dialog if no arguments are given
    if len(sys.argv) == 1:
        parser.print_help(sys.stderr)
        logging.warning("Exiting program. At least argument -aoi is required.")
        sys.exit(0)
    else:
        args = parser.parse_args()

    # Assign arguments to variables and do some checks for error-handling
    aoi = args.aoi.title().strip()
    skip_aoi = args.skip_aoi
    use_pop = args.use_pop
    n_routes = args.n_routes
    method = args.method.lower()
    route_type = args.route_type.lower()
    out_dir = args.out_dir.lower().strip()

    method, route_type, n_routes = args_checker(n_routes, method, route_type)

    return n_routes, aoi, skip_aoi, use_pop, method, route_type, out_dir


def args_checker(n_routes, method, route_type):
    """Check parameters and resolve conflicts"""
    method = method.strip()
    route_type = route_type.strip()
    # n_routes
    try:
        n_routes = int(n_routes)
        if n_routes < 1:
            logging.error(
                "Number of routes must be greater than 0. More than 10 are recommended."
            )
            sys.exit(1)
    except ValueError:
        logging.error("Number of routes must be of type integer.")
        sys.exit(1)
    # method
    if method not in ["nx", "networkx", "gibc", "geographical"]:
        logging.error("Method must be either 'nx'/'networkx' or 'gibc'/'geographical'.")
        sys.exit(1)
    if method in ["nx", "networkx"]:
        method = "nx"
    elif method in ["gibc", "geographical"]:
        method = "gibc"
    # route_type
    if route_type not in ["shortest", "fastest"]:
        logging.error("Route type must be either 'shortest' or 'fastest'.")
        sys.exit(1)
    # method/route_type combination
    if method == "gibc" and route_type == "shortest":
        logging.warning(
            "Cannot use geographical method with shortest routes. Using fastest routes instead."
        )
        route_type = "fastest"

    return method, route_type, n_routes


def init_logger(logging_config_file=None):
    """Set up a logger instance with stream and file logger"""
    with open(logging_config_file, "r") as src:
        logging_config = json.load(src)

    logging.config.dictConfig(logging_config)
