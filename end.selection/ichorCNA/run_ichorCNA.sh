#!/bin/bash
#
# Author: Kun Sun @ SZBL (sunkun@szbl.ac.cn)
# Date  :
#
set -o nounset
set -o errexit
#command || { echo "command failed"; exit 1; }

## input paramater:
## 1: sample id
## 2：/path/to/bam
## 3: PoN file

## modify the location of ichorCNA!!!
ichorCNA=/mnt/software/ichorCNA-master

sid=$1
bam=$2
PoN=$3

mkdir -p $sid
readCounter --window 500000 --quality 30 \
	--chromosome "chr1,chr2,chr3,chr4,chr5,chr6,chr7,chr8,chr9,chr10,chr11,chr12,chr13,chr14,chr15,chr16,chr17,chr18,chr19,chr20,chr21,chr22,chrX,chrY" \
	$bam >$sid/$sid.bin500K.wig

## parameter for higher sensitivity
Rscript $ichorCNA/scripts/runIchorCNA.R --id $sid \
	--ploidy "c(2)" --maxCN 3 \
	--normal "c(0.5,0.6,0.7,0.8,0.9,0.95,0.99,0.995,0.999)" \
	--includeHOMD False --chrs "c(1:22)" --chrTrain "c(1:22)" \
	--estimateNormal True --estimatePloidy True \
	--estimateScPrevalence False --scStates "c()" \
	--txnE 0.9999 --txnStrength 10000 \
	--gcWig $ichorCNA/inst/extdata/gc_hg38_500kb.wig \
	--mapWig $ichorCNA/inst/extdata/map_hg38_500kb.wig \
	--centromere $ichorCNA/inst/extdata/GRCh38.GCA_000001405.2_centromere_acen.txt \
	--normalPanel $PoN  \
	--WIG $sid/$sid.bin500K.wig \
	--outDir $sid
