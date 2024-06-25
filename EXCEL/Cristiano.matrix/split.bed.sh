#!/bin/bash
#
# Author: Kun Sun @ SZBL (sunkun@szbl.ac.cn)
# Date  :
#
set -o nounset
set -o errexit
#command || { echo "command failed"; exit 1; }

## input parameter: 1 bed.list file with 2 columns: sid /path/to/bed

bedlist=$1

while read sid bed extra
do
	[ -d bed_5M/$sid ] || mkdir -p bed_5M/$sid
	
	while read chr spos epos extra
	do
		echo -e "$chr\t$spos\t$epos" >/tmp/hg38.$chr.$spos.$epos.bed
		bedtools intersect -a $bed -b /tmp/hg38.$chr.$spos.$epos.bed -wa | \
		awk '{if($4>=30)print}' | gzip > bed_5M/$sid/$sid.$chr.$spos.$epos.bed.gz
		rm -f /tmp/hg38.$chr.$spos.$epos.bed
	done < hg38.bin5M.bed
	## then calculcate the cfDNA features for all BEDs and build matrix
done < $bedlist
