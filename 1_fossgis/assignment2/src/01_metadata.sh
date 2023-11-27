#!/bin/sh
# Prints metadata of the files
# Author: GrHalbgott
# Date: today

DIR=../data # data folder

echo "Printing info about input files"
echo "----------"

# Get info about gadm36_SVN.gpkg
echo "\nShowing info about gadm36_SVN.gpkg:"
echo "----------"
ogrinfo $DIR/gadm36_SVN.gpkg # summary only (-so not needed)
ogrinfo -so $DIR/gadm36_SVN.gpkg gadm36_SVN_0 # summary only of layer

# Get info about N45E014_sub.gpkg
echo "\nShowing info about N45E014_sub.gpkg:"
echo "----------"
gdalinfo $DIR/N45E014_sub.gpkg

# Get info about n45_e013_1arc_v3_sub.tif
echo "\nShowing info about n45_e013_1arc_v3_sub.tif:"
echo "----------"
gdalinfo $DIR/n45_e013_1arc_v3_sub.tif
