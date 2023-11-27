#!/bin/sh
# Merges two DEM files using different commands
# Author: GrHalbgott
# Date: today

DIR=../data # data folder

echo "Merging DEM files"
echo "----------"

# Merge dem files using gdal_merge
echo "\nMerging to TIF file:"
echo "----------"
gdal_merge.py $DIR/n45_e013_1arc_v3_sub.tif $DIR/N45E014_sub.gpkg -o $DIR/dem_merge.tif
gdalinfo $DIR/dem_merge.tif

# Merge dem files using gdal_build_vrt
echo "\nMerging to VRT file:"
echo "----------"
gdalbuildvrt $DIR/n45_e013_1arc_v3_sub.tif $DIR/N45E014_sub.gpkg -o $DIR/dem_buildvrt.vrt # skips one file
gdalinfo $DIR/dem_buildvrt.tif
