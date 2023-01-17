opalsImport -inFile ./data/alps/alps_points.xyz -outFile ./data/alps_points.odm -iFormat ./data/alps/alps_import.xml

opalsGrid -inFile ./data/alps_points.odm -outFile ./export/alps_dsm.tif -grid 5.0

opalsShade -inFile ./export/alps_dsm.tif -outfile ./export/alps_dsm_shd.tif

opalsInfo -inf ./data/alps_points.odm

opalsCell –inf ./data/alps_points.odm -outf ./export/alps_pdens.tif -feat pdens -cel 1.0

opalsCell -inf ./data/alps_points.odmm -outFile ./export/alps_dtm.tif -feature min
