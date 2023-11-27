::!/bin/sh
:: Prints metadata of the files
:: Author: GrHalbgott
:: Date: today

set DIR=../data

echo "Printing info about input files"

:: Get info about gadm36_SVN.gpkg
echo "Showing info about gadm36_SVN.gpkg:"
ogrinfo %DIR%/gadm36_SVN.gpkg
ogrinfo -so %DIR%/gadm36_SVN.gpkg gadm36_SVN_0 

:: Get info about N45E014_sub.gpkg
echo "Showing info about N45E014_sub.gpkg:"
gdalinfo %DIR%/N45E014_sub.gpkg

:: Get info about n45_e013_1arc_v3_sub.tif
echo "Showing info about n45_e013_1arc_v3_sub.tif:"
gdalinfo %DIR%/n45_e013_1arc_v3_sub.tif
