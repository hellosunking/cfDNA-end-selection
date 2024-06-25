#!/bin/bash
#
# Author: Kun Sun @ SZBL (sunkun@szbl.ac.cn)
# Date  :
#
set -o nounset
set -o errexit
#command || { echo "command failed"; exit 1; }

currSHELL=`readlink -f $0`
PRG=`dirname $currSHELL`

for feature in Nindex DeltaS DeltaM
do
	[ -d $feature ] || mkdir -p $feature
	cd $feature

	## building models
	Rscript $PRG/GBM.R $PRG/Cristiano.matrix/$feature.bin5M.matrix ./ >log
	Rscript $PRG/cross.validation.AUC.R GBM.pred.txt
	Rscript $PRG/ROC.R EXCEL.score.txt >>log

	cd ../
done

