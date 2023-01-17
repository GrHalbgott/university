# FOSSGIS Assignment 2 - Documentation

***Kolaxidis/Weise***

## Exercise 1

Use the commands gdalinfo and ogrinfo to answer the following questions about all three files, e.g.

What is the coordinate reference system (EPSG) of each file?
What is the driver (file format) of each file?
What is the spatial resolution of the raster files? (Don't forget to provide the units)
How many bands (for raster files) or layers (for vector files) does each file contain?

---

N45E014.hgt
CRS: EPSG:4326
Driver: SRTMHGT/SRTMHGT File Format
Spatial Resolution: 0.0002 degrees (approx. 30 meters)
Bands: 1

n45_e013_1arc_v3.tif
CRS: EPSG:4326
Driver: GTiff/GeoTIFF
Spatial Resolution: 0.0002 degrees (approx. 30 meters)
Bands: 1

gadm36_SVN.gpkg
CRS: EPSG:4326
Driver: GPKG Geo Package
Layers: 3

---

## Exercise 2

What is the difference between the two output files? What is the reason for this?

- The main difference between VRT-Files and TIF-Files is their size. Merging raster files into a TIF-File is actually merging them into a new file, combining all data of the raster files, therefore merged TIF-Files are always as big as the source raster files combined. 
  VRT-Files on the other hand are virtual files that combine raster data virtually without actually merging them. VRT-Files just have the information how to merge which files, never actually merging them into a whole new file. Using gdalinfo, the original files are still recognizable in the buildvrt file.
- Additionally, this can be seen in the max and min values of the merged files. Looking at the two outputfiles in QGIS it is observable that the min and max values of the two original files have been adopted in the TIF-File but not in the VRT-File which uses virtual max and min values adopting to the current calculations. The reason for this is probably a different computation for different uses, shown in the answer to the next question:

What might be an advantage of using `gdalbuildvrt` instead of `gdalmerge`?

- VRT-Files are much more convenient to use than TIF-Files if the merged files are just a step in multiple calculations and not the final result. Buildvrt is faster, uses less space and checks whether the raster files are perfectly mergeable with their stats beforehand. There are more commands you can implement in buildvrt and also the original files are still recognizable which could be handy for retracing the origin of the buildvrt file for other potential users.
