#!/bin/bash
#
# Author: Kun Sun @ SZBL (sunkun@szbl.ac.cn)
# Date  :
#
set -o nounset
set -o errexit
#command || { echo "command failed"; exit 1; }

## input paramater: 
## 1: a file with 2 columns: sid and /path/to/bed
## 2: /path/to/human.reference.genome.fa
bedlist=$1
refgenome=$2

PRG=/mnt/software/end.selection
## the following files are under PRG:
bed2fa=$PRG/bed2fa.pl
bed2fa_right=$PRG/bed2fa_right.pl
grabend=$PRG/grab.end.with.extension.pl
extractMotif=$PRG/extract.motif.with.extension.pl

left=""
right=""
while read sid bedfile
do
	perl $grabend $bedfile $sid $layout $sizeRange y 2 4
	left="$left $sid.left.outer2.inner4.bed"
	right="$right $sid.right.outer2.inner4.bed"
done < $bedlist

echo -e "\rExtracting sequence ... "
perl $bed2fa $refgenome $left
perl $bed2fa_right $refgenome $right

while read sid extra
do
	echo -en "\rLoading $sid ... "
	cat $sid.right.outer2.inner4.fa $sid.left.outer2.inner4.fa | perl $extractMotif - 4 $length> $sid.motif &
done < $bedlist
wait
