opalsImport -inf ./data/UniversitySquare_trees.laz -iformat las -outf ./data/UniversitySquare_trees.odm
opalsImport -inf ./data/UniversitySquare_notrees.laz -iformat las -outf ./data/UniversitySquare_notrees.odm

opalsNormals -inf ./data/UniversitySquare_trees.odm -neighbours 20 -searchRadius 3 -searchmode d3
opalsNormals -inf ./data/UniversitySquare_notrees.odm -neighbours 20 -searchRadius 3 -searchmode d3

opalsView -inf ./data/UniversitySquare_trees.odm
opalsView -inf ./data/UniversitySquare_notrees.odm

opalsExport -inf ./data/UniversitySquare_trees.odm -oformat ./data/oformat_vostok.xml -outf ./data/UniversitySquare_trees_normals.xyz
opalsExport -inf ./data/UniversitySquare_notrees.odm -oformat ./data/oformat_vostok.xml -outf ./data/UniversitySquare_notrees_normals.xyz