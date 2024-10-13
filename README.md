*** Scripts to replicate the results in [Ju et al. Cell Reports Methods 2024](https://doi.org/10.1016/j.crmeth.2024.100877 "Ju et al.")***

Distributed under the [CC BY-NC-ND 4.0](https://creativecommons.org/licenses/by-nc-nd/4.0/ "CC BY-NC-ND")
license for **personal and academic usage only.**

### IMPORTANT NOTE: Unauthorized commercial usages are strictly forbidden!!!
---

### The following software/packages are required:
1. samtools
2. bedtools
3. ichorCNA
4. R packages: creditmodel, gbm, caret, pROC, dplyr, Rmisc, ggplot2

### The following files are required (they're too large to be included in this package):
1. Hg38 human reference genome

You can download the file from
```
https://hgdownload.cse.ucsc.edu/goldenpath/hg38/bigZips/hg38.fa.gz
```

2. GM12878 nucleosome track

You can download the file from
```
https://download.cncb.ac.cn/nucmap/organisms/v1/Homo_sapiens/byDataType/Nucleosome_peaks_DANPOS/Homo_sapiens.hsNuc0390101.nucleosome.DANPOSPeak.bed.gz
```

then use following command to parse this file:
```
zcat Homo_sapiens.hsNuc0390101.nucleosome.DANPOSPeak.bed.gz | \
perl -lane '$c=($F[1]+$F[2])>>1; print join("\t", $F[0], $c-73, $c+1+73, $F[3]) if $F[0]=~/chr\d+$/' | \
sort -k1,1 -k2,2n | gzip >hsNuc0390101.DANPOSPeak.ext73.bed.gz
```

### End selection
The script is `calc.cfDNA.features.with.end.selection.sh` under `end.selection` directory. To run it, you need to prepare a 2-column file that
records the sample id and path to the bed file from paired-end cfDNA sequencing reads (could be gzipped) separated by TAB.
Here is an example of this file:
```
s1	/path/to/s1.bed.gz
s2	/path/to/s2/s2.bed.gz
```

For BED format, please see `https://genome.ucsc.edu/FAQ/FAQformat.html#format1` (the first 6 columns are required).
Here are some example records for BED file:
```
chr1	805429	805626	LH00128:50:222KJ3LT4:7:1389:34785:19840	31	-
chr1	805768	805955	LH00128:50:222KJ3LT4:7:2219:47967:23637	30	+
chr1	806265	806427	LH00128:50:222KJ3LT4:7:2248:21854:11324	32	+
```

### The EXCEL model
The script to build EXCEL model is `do.EXCEL.sh` under `EXCEL` directory. We had already included the features for Cristiano et al. dataset,
and this script will build 3 EXCEL models using N-index, Delta-S, and Delta-M features, respectively.

