opalsImport -inFile ./data/MtRainier/mtrainier_points.las -outFile ./data/mtrainier_points.odm -coord_ref_sys WKT:PROJCS["NAD83 / UTM zone 10N",GEOGCS["NAD83",DATUM["North_American_Datum_1983",SPHEROID["GRS 1980",6378137,298.257222101,AUTHORITY["EPSG","7019"]],AUTHORITY["EPSG","6269"]],PRIMEM["Greenwich",0,AUTHORITY["EPSG","8901"]],UNIT["degree",0.01745329251994328,AUTHORITY["EPSG","9122"]],AUTHORITY["EPSG","4269"]],UNIT["metre",1,AUTHORITY["EPSG","9001"]],PROJECTION["Transverse_Mercator"],PARAMETER["latitude_of_origin",0],PARAMETER["central_meridian",-123],PARAMETER["scale_factor",0.9996],PARAMETER["false_easting",500000],PARAMETER["false_northing",0],AUTHORITY["EPSG","26910"],AXIS["Easting",EAST],AXIS["Northing",NORTH]]

opalsGrid -inFile ./data/mtrainier_points.odm -outFile ./export/mtrainier_dsm.tif -grid 5.0

opalsShade -inFile ./export/mtrainier_dsm.tif -outfile ./export/mtrainier_dsm_shd.tif

opalsInfo -inf ./data/mtrainier_points.odm

opalsCell –inf ./data/mtrainier_points.odm -outf ./export/mtrainier_pdens.tif -feat pdens -cel 3.0

opalsCell -inFile ./data/mtrainier_points.odm -outFile ./export/mtrainier_dtm.tif -feature min

opalsStatFilter -inFile ./export/mtrainier_dtm.tif -outFile ./export/mtrainier_dtm_smooth.tif -feature mean -kernelSize 3 

opalsAlgebra 
