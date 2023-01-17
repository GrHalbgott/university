opalsImport -inFile ./data/strip12.laz -outFile ./data/strip12.odm

opalsNormals -inf ./data/strip12.odm -neighbours 20 -searchRadius 3 -searchmode d3

opalsSegmentation -inf ./data/strip12.odm -searchRadius 1 -minSegSize 10 -method planeExtraction -maxDist 0.3 -maxSigma 0.1 -seedCalc "NormalSigma0 < 0.02 and z > 270 ? NormalSigma0 : invalid"

opalsView -inFile ./data/strip12.odm