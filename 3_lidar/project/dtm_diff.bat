::Import point clouds to ODM
opalsImport -inf ./data/stardune_1810_5cm.laz -iformat las -coord_ref_sys EPSG:32630 -outf ./data/stardune_1810.odm
opalsImport -inf ./data/stardune_2002_5cm.laz -iformat las -coord_ref_sys EPSG:32630 -outf ./data/stardune_2002.odm

::Derive Digital Terrain Model (DTM) of each point clouds
opalsGrid -inf ./data/stardune_1810.odm -outf ./data/stardune_1810_dtm.tif -gridsize 1.0 -interpolation robMovingPlanes
opalsGrid -inf ./data/stardune_2002.odm -outf ./data/stardune_2002_dtm.tif -gridsize 1.0 -interpolation robMovingPlanes

::Fill gaps in the DTM
opalsStatFilter -inf ./data/stardune_1810_dtm.tif -outf ./data/stardune_1810_dtm_smooth.tif -feature mean -kernelSize 3 
opalsStatFilter -inf ./data/stardune_2002_dtm.tif -outf ./data/stardune_2002_dtm_smooth.tif -feature mean -kernelSize 3 
opalsAlgebra -inf ./data/stardune_1810_dtm.tif -inf ./data/stardune_1810_dtm_smooth.tif -outf ./exports/opals/stardune_1810_dtm_filled.tif -formula "r[0] ? r[0] : r[1]" -gridSize 1.0
opalsAlgebra -inf ./data/stardune_2002_dtm.tif -inf ./data/stardune_2002_dtm_smooth.tif -outf ./exports/opals/stardune_2002_dtm_filled.tif -formula "r[0] ? r[0] : r[1]" -gridSize 1.0

::Create a shading for visualization
opalsShade -inf ./exports/opals/stardune_1810_dtm_filled.tif
opalsShade -inf ./exports/opals/stardune_2002_dtm_filled.tif 

::Calculate the DTM difference from 1810 to 2002 --> diff = 2002-1810
opalsDiff -inf ./exports/opals/stardune_2002_dtm_filled.tif ./exports/opals/stardune_1810_dtm_filled.tif -outf ./results/opals/stardune_diff_2002-1810.tif 

::Apply color palette to difference raster
opalsZColor -inf ./results/opals/stardune_diff_2002-1810.tif -zRange -2.0 2.0 -interval 0.1 -pal differencePal.xml -outf ./results/opals/stardune_diff_colorized.tif

::View in Opals
::opalsView -inf ./results/opals/stardune_diff_2002_to_1810.tif