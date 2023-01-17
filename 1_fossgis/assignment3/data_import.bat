::g.mapset mapset=new location=baden_wuerttemberg
g.region -p

ogr2ogr motorwaysProj.geojson motorways.geojson -t_srs EPSG:25832 
v.in.ogr input=motorwaysProj.geojson output=motorways

ogr2ogr admin2_ger.shp gadm28_adm2_germany.shp -t_srs EPSG:25832 
v.in.ogr input=admin2_ger.shp where="ID_1=1" snap=1e-08 output=districts

g.region vector="districts" -p

gdalwarp GHS_POP_E2015_GLOBE_R2019A_54009_250_V1_0_18_3.tif -t_srs EPSG:25832 GHS_POP.tif
r.in.gdal input=GHS_POP.tif output=population

g.region raster="population"
g.list type=all
g.list type=rast,vect
g.region -p