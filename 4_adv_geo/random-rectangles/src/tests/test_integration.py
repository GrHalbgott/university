#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""Integration tests"""

import subprocess


def test_run_main():
    """Tests whether main is run correctly"""
    subprocess.check_call(["python", "main.py"])
