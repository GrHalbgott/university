#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""Test functions of file manager"""


from network_analysis.file_manager import outname_creator


def test_outname_creator():
    """
    Test if outname is created correctly
    :return:
    """
    # Test case 1: Method is "gibc", therefore no route_type, use_pop false
    assert (
        outname_creator("Berlin, Germany", "gibc", "shortest", 100, False)
        == "Berlin_gibc_100"
    )

    # Test case 2: Multiple commas in AOI name, use_pop true
    assert (
        outname_creator("San Francisco, California, USA", "nx", "shortest", 100, True)
        == "San Francisco_nx_shortest"
    )

    # Test case 3: Leading/trailing spaces in method and route_type, gibc without route_type, use_pop true
    assert (
        outname_creator("Sydney, Australia", "   gibc  ", "  fastest   ", 100, True)
        == "Sydney_gibc_100_pop"
    )

    # Test case 4: Random words
    assert (
        outname_creator("one word, sd, sd,", "random", "words", 100, False)
        == "one word_random_words"
    )  # handled by check_system_arguments
