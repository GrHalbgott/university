::!/bin/sh
:: Script to calculate a color relief map for a selected district
:: Author: GrHalbgott
:: date: today

set DIR=../data
set TEMP=../temp
set /P NAME="Enter aoi: "

echo "Creating color relief image:"

:: 3.2. Extract the target district and save it in a new shapefile
echo "Extracting $NAME from gpkg:"
ogr2ogr -f "ESRI Shapefile" %TEMP%/%NAME%.shp -lco ENCODING=UTF-8 -sql "SELECT * FROM gadm36_SVN_2 WHERE NAME_2 = '%NAME%'" %DIR%/gadm36_SVN.gpkg
:: ogr2ogr -f "ESRI Shapefile" %DIR%/%NAME%.shp -lco ENCODING=UTF-8 -where "\"NAME_2\" = '%NAME%'" %DIR%/gadm36_SVN.gpkg gadm36_SVN_2

:: 3.3. Reproject the DEM and clip it to the target district
echo "Reprojecting the DEM and clipping to %NAME%:"
gdalwarp -cutline %TEMP%/%NAME%.shp -crop_to_cutline -t_srs EPSG:32632 -dstnodata -9999 %DIR%/dem_merge.tif %TEMP%/%NAME%_dem.tif

:: 3.4. Create color relief from clipped DEM
echo "Creating color relief:"
gdaldem color-relief %TEMP%/%NAME%_dem.tif color_text.txt ../figures/color_relief_%NAME%.jpg
