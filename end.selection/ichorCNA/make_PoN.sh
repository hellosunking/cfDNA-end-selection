set -o nounset
set -o errexit
#command || { echo "command failed"; exit 1; }

## input paramater: a file with 2 columns: sid and /path/to/bam
baminfo=$1

## modify the location of ichorCNA!!!
ichorCNA=/mnt/software/ichorCNA-master

rm -f PoN.wig.list
mkdir -p wig.bin500K
while read sid bamfile
do
	## bam to wig
	
	if [ ! -s wig.bin500K/$sid.wig ]
	then
		readCounter --window 500000 --quality 20 \
		--chromosome "chr1,chr2,chr3,chr4,chr5,chr6,chr7,chr8,chr9,chr10,chr11,chr12,chr13,chr14,chr15,chr16,chr17,chr18,chr19,chr20,chr21,chr22,chrX,chrY" \
		$bamfile >wig.bin500K/$sid.wig
	fi

	echo -e "wig.bin500K/$sid.wig" >> PoN.wig.list
done < $baminfo

mkdir -p ichorCNA.with.PoN
Rscript $ichorCNA/scripts/createPanelOfNormals.R \
        --filelist PoN.wig.list \
        --gcWig $ichorCNA/inst/extdata/gc_hg38_500kb.wig \
        --mapWig $ichorCNA/inst/extdata/map_hg38_500kb.wig \
        --centromere $ichorCNA/inst/extdata/GRCh38.GCA_000001405.2_centromere_acen.txt \
        --outfile ichorCNA.with.PoN/PoN

##the PoN file is ichorCNA.with.PoN/PoN_median.rds
