preAttribute.py -i ./data/niederrhein.laz -c ./data/preAttributeNiederrhein.cfg -o ./export/

clfTreeModelTrain.py -i ./export/niederrhein.odm -c ./data/clfTrainNiederrhein.cfg

clfTreeModelApply.py -i ./export/niederrhein.odm -c ./data/clfApplyNiederrhein.cfg

opalsView -inFile ./export/niederrhein.odm