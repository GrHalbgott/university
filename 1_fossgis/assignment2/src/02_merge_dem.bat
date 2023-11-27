::!/bin/sh
:: Merges two DEM files using different commands
:: Author: GrHalbgott
:: Date: today

set DIR=../data

echo "Merging DEM files"

:: Merge dem files using gdal_merge
echo "Merging to TIF file:"
gdal_merge.py %DIR%/n45_e013_1arc_v3_sub.tif %DIR%/N45E014_sub.gpkg -o %DIR%/dem_merge.tif
gdalinfo %DIR%/dem_merge.tif

:: Merge dem files using gdal_build_vrt
echo "Merging to VRT file:"
gdalbuildvrt %DIR%/N45E014_sub.gpkg %DIR%/n45_e013_1arc_v3_sub.tif -o %DIR%/dem_buildvrt.vrt
gdalinfo %DIR%/dem_buildvrt.vrt
