opalsImport -inf ./data/aoi_2017.laz -outFile ./data/opals/aoi_2017.odm
opalsImport -inf ./data/aoi_2018.laz -outFile ./data/opals/aoi_2018.odm

opalsGrid -inf ./data/opals/aoi_2017.odm -outFile ./data/opals/aoi_2017_0.1.tif -grid 0.1
opalsGrid -inf ./data/opals/aoi_2018.odm -outFile ./data/opals/aoi_2018_0.1.tif -grid 0.1
opalsGrid -inf ./data/opals/aoi_2017.odm -outFile ./data/opals/aoi_2017_0.5.tif -grid 0.5
opalsGrid -inf ./data/opals/aoi_2018.odm -outFile ./data/opals/aoi_2018_0.5.tif -grid 0.5
opalsGrid -inf ./data/opals/aoi_2017.odm -outFile ./data/opals/aoi_2017_1.0.tif -grid 1.0
opalsGrid -inf ./data/opals/aoi_2018.odm -outFile ./data/opals/aoi_2018_1.0.tif -grid 1.0

opalsDiff -inf ./data/opals/aoi_2018_0.1.tif ./data/opals/aoi_2017_0.1.tif -outFile ./export/diffs_18-17_0.1.tif
opalsDiff -inf ./data/opals/aoi_2018_0.5.tif ./data/opals/aoi_2017_0.5.tif -outFile ./export/diffs_18-17_0.5.tif
opalsDiff -inf ./data/opals/aoi_2018_1.0.tif ./data/opals/aoi_2017_1.0.tif -outFile ./export/diffs_18-17_1.0.tif

opalsZColor -inf ./export/diffs_18-17_0.1.tif -outFile ./export/diffs_18-17_0.1_col.tif -zRange -1 1 -interval 0.1 -pal differencePal.xml
opalsZColor -inf ./export/diffs_18-17_0.5.tif -outFile ./export/diffs_18-17_0.5_col.tif -zRange -1 1 -interval 0.1 -pal differencePal.xml
opalsZColor -inf ./export/diffs_18-17_1.0.tif -outFile ./export/diffs_18-17_1.0_col.tif -zRange -1 1 -interval 0.1 -pal differencePal.xml
