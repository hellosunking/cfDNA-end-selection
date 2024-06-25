#!/bin/bash
#
# Author: Kun Sun @ SZBL (sunkun@szbl.ac.cn)
# Date  :
#
set -o nounset
set -o errexit
#command || { echo "command failed"; exit 1; }

## input paramater:
## 1. a file with 2 columns: sid and /path/to/bed
## 2. path to hg38 genome in fasta format
if [ $# -lt 2 ]
then
	echo "Usage: $0 <sample.info> <hg38.genome.fa>"
	exit 2
fi >/dev/stderr

bedinfo=$1
refgenome=$2

## modify the following path to the one containing all the programs in this repo if necessary
currSHELL=`readlink -f $0`
PRG=`dirname $currSHELL`

mkdir -p original end.selection bed
## filter bed file: keep autosome and mapQ>=30 reads
while read sid bed
do
	less $bed | perl -lane 'print "$F[0]\t$F[1]\t$F[2]\t$F[4]" if $F[0]=~/^chr\d+$/ && $F[4]>=30' >bed/$sid.filter.bed
	echo -e "$sid\t$PWD/bed/$sid.filter.bed" >>original.bed.list
	echo -e "$sid\t$PWD/bed/$sid.end.selected.bed" >>end.selection.bed.list
done < $bedinfo

## End selection and genomewide N-index, 4 threads will be used by default
cd bed
chmod 755 $PRG/cfDNA.end.selection
$PRG/cfDNA.end.selection $PRG/hg38.info $PRG/hsNuc0390101.DANPOSPeak.ext73.bed.gz original.bed.list >../N-index.genomewide
cd ../

## size
while read sid bed
do
	perl $PRG/bed2size.pl $PWD/bed/$sid.filter.bed original/$sid.size &
	perl $PRG/bed2size.pl $PWD/bed/$sid.end.selected.bed end.selection/$sid.size &
	wait
done < $bedinfo

## motif
cd original
sh $PRG/profile.motif.sh ../original.bed.list $refgenome
cd ../end.selected
sh $PRG/profile.motif.sh ../end.selection.bed.list $refgenome
cd ../

## make stat
echo -e "SampleID\tNindex\tDelta-S\tDelta-M" >cfDNA.features
while read sid Allreads Endselected Nindex
do
	S150=`cat original/$sample.size | awk '{if ($1 == "150")print}' | cut -f 4`
	S150_es=`cat end.selected/$sample.end.size | awk '{if ($1 == "150")print}' | cut -f 4`
	DeltaS=`perl -e "print $S150_es-$S150"`
	
	CCCA=`grep ^CCCA original/$sample.motif | cut -f 5`
	CCCA_es=`grep ^CCCA end.selected/$sample.motif | cut -f 5`
	DeltaM=`perl -e "print $CCCA_es-$CCCA"`

	echo -e "$sid\t$Nindex\t$DeltaS\t$DeltaM" >>cfDNA.features
done < N-index.genomewide

