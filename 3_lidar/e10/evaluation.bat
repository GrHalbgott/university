opalsImport -inf ./results/universitySquare_vostok_summer_notrees.xyz -iformat ./data/iformat_vostok.xml -outf ./results/universitySquare_vostok_summer_notrees.odm
opalsImport -inf ./results/universitySquare_vostok_summer_trees.xyz -iformat ./data/iformat_vostok.xml -outf ./results/universitySquare_vostok_summer_trees.odm

opalsView -inf ./results/universitySquare_vostok_summer_trees.odm
opalsView -inf ./results/universitySquare_vostok_summer_notrees.odm