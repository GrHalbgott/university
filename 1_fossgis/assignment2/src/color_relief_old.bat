::Script for Fossgis Assignment 2 - Kolaxidis/Weise

ogr2ogr -f "ESRI Shapefile" koper.shp -lco ENCODING=UTF-8 -sql "SELECT * FROM gadm36_SVN_2 WHERE NAME_2 = 'Koper'" gadm36_SVN.gpkg
::SQL is a language used for handling data in databases and can be implemented in the workflow of GIS. In this exercise it is used to select all features from the Layer ..._2 from the GeoPackage where the field "Name_2" has data named "koper". The selected features are then exported as koper.shp in an ESRI shapefile and encoded in UTF-8.

gdalwarp -cutline koper.shp -crop_to_cutline -t_srs EPSG:32632 -dstnodata -9999 dem_merge.tif koper_dem.tif
::To clip the DEM, we first need to specify the extent (cutline) and then use it to clip (crop_to_cutline) the raster with the cutline. T_srs reprojects the target file into the given CRS. NoData values have to be additionally defined (dstnodata) for the target dataset to not take them into account. With this, the background of the target DEM will be transparent and not filled with a colour.

gdaldem color-relief koper_dem.tif color_text.txt koper_color_relief.jpg
::Finally we use this tool to visualize the DEM as a colour-relief map with specific colours defined in a textfile. The tool doesn't work without color definitions.


ogr2ogr -f "ESRI Shapefile" izola.shp -lco ENCODING=UTF-8 -sql "SELECT * FROM gadm36_SVN_2 WHERE NAME_2 = 'Izola'" gadm36_SVN.gpkg
gdalwarp -cutline izola.shp -crop_to_cutline -t_srs EPSG:32632 -dstnodata -9999 dem_merge.tif izola_dem.tif
gdaldem color-relief izola_dem.tif color_text.txt izola_color_relief.jpg

ogr2ogr -f "ESRI Shapefile" divaca.shp -lco ENCODING=UTF-8 -sql "SELECT * FROM gadm36_SVN_2 WHERE NAME_2 = 'Divaca'" gadm36_SVN.gpkg
gdalwarp -cutline Divaca.shp -crop_to_cutline -t_srs EPSG:32632 -dstnodata -9999 dem_merge.tif divaca_dem.tif
gdaldem color-relief divaca_dem.tif color_text.txt divaca_color_relief.jpg

ogr2ogr -f "ESRI Shapefile" Vipava.shp -lco ENCODING=UTF-8 -sql "SELECT * FROM gadm36_SVN_2 WHERE NAME_2 = 'Vipava'" gadm36_SVN.gpkg
gdalwarp -cutline vipava.shp -crop_to_cutline -t_srs EPSG:32632 -dstnodata -9999 dem_merge.tif vipava_dem.tif
gdaldem color-relief vipava_dem.tif color_text.txt vipava_color_relief.jpg