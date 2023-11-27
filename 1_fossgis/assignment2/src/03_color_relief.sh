#!/bin/sh
# Script to calculate a color relief map for a selected district
# Author: GrHalbgott
# date: today

DIR=../data
read -p "Enter aoi: " NAME

echo "Creating color relief image:"
echo "----------"

# 3.2. Extract the target district and save it in a new shapefile
echo "\nExtracting $NAME from gpkg:"
echo "----------"
ogr2ogr -f "ESRI Shapefile" $DIR/${NAME}.shp -lco ENCODING=UTF-8 -sql "SELECT * FROM gadm36_SVN_2 WHERE NAME_2 = '$NAME'" $DIR/gadm36_SVN.gpkg

# 3.3. Reproject the DEM and clip it to the target district
echo "\nReprojecting the DEM and clipping to $NAME:"
echo "----------"
gdalwarp -cutline $DIR/${NAME}.shp -crop_to_cutline -t_srs EPSG:32632 -dstnodata -9999 $DIR/dem_merge.tif $DIR/${NAME}_dem.tif

# 3.4. Create color relief from clipped DEM
echo "\nCreating color relief:"
echo "----------"
gdaldem color-relief $DIR/${NAME}_dem.tif ../color_text.txt ../img/color_relief_${NAME}.jpg
