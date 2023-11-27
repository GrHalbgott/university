#!/bin/sh
# Script to calculate a color relief map for a selected district
# Author:  
# This script must be located in the root directory of the repository and the data in the folder ./data
# ToDo: Replace the [...] with the correct parameters

# 3.2. Extract the target district and save it in a new shapefile
ogr2ogr [...]

# 3.3. Reproject the DEM and clip it to the target district
gdalwarp [...]

# 3.4. Create color relief from clipped dem (result from 3.3.)
gdaldem [...]
