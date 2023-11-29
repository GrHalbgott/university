#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""Test functions of utils"""


import pytest
from network_analysis.utils import args_checker


def test_args_checker():
    """
    Test if arguments are correctly checked
    :return:
    """
    # Test case 1: correct arguments
    n_routes = 100
    method = "nx"
    route_type = "shortest"

    expected_args = ("nx", "shortest", 100)
    actual_args = args_checker(n_routes, method, route_type)

    assert expected_args == actual_args

    # Test case 2: n_routes as string, method with leading and trailing whitespaces
    n_routes = "50"
    method = "   gibc   "
    route_type = "shortest"

    expected_args = ("gibc", "fastest", 50)
    actual_args = args_checker(n_routes, method, route_type)

    assert expected_args == actual_args

    # Test case 3: method not in ["nx", "gibc"]
    n_routes = 1000
    method = "g"
    route_type = "shortest"

    with pytest.raises(SystemExit) as exc_info:
        args_checker(n_routes, method, route_type)

    assert exc_info.value.args[0] == 1

    # Test case 4: n_routes less than 1
    n_routes = -7
    method = "g"
    route_type = "shortest"

    with pytest.raises(SystemExit) as exc_info:
        args_checker(n_routes, method, route_type)

    assert exc_info.value.args[0] == 1
