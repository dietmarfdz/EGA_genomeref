# Name
genome_ref_cal.sh: Script for inferring the genome reference from a vcf file. Works with genome ref grch37, grch38 and hg17.

# Synopsis

This script allows to calculate the genome reference from a vcf file. We extracted unique nucleotides per pos in hg17, grch37, grch38.

We select the chromosome with more variants in the vcf file and we run the script for that specific chromosome.

It searchs for matches in 3 dictionaries (one per reference genome gb37, gb38 & gh17) and takes the one having matches (only one)

A maximum of 10K variants per chromosome are analyzed. Also a maximum of 100 matches per chromosome are analyzed.

The script includes the dictionaries for inferring the genome reference.

# Run

The script runs on Linux (tested on Debian-based distribution). The script uses bash commands and requires bcftools.

We have to work with the file bgzipped and tabix indexed.

You need to run the script where the file.vcf.gz is located.


```
bash /path/genome_ref_cal_v3.4.sh 
```

# Demo

Demo folder contains a subset of vcf from chromosome 22 from 1000 Genomes data for testing purposes.  Result folder contains all files generated when running the script:

1. gb17 folder: contains file with number of matches per each chromosome for gb17.
2. grch37 folder: contains file with number of matches per each chromosome for grch37.
3. grch38 folder: contains file with number of matches per each chromosome for grch38.
4. variants_subset folder: contains file with list of variants matching per each chromosome.
5. all_match_gb17: contains number of matches for all chromosomes for gb17.
6. all_match_gb37: contains number of matches for all chromosomes for gb37.
7. all_match_gb38: contains number of matches for all chromosomes for gb38.
8. final: contains total number of matches for each genome reference.
9. infer_ref: contains the inferred genome reference.
10. demo_subset.vcf.gz.chromosome: file generated with the number of chromosomes and variants present in the demo vcf.



# Author

Written by Dietmar Fernandez, PhD. Info about EGA can be found at https://ega-archive.org/.


# Copyright

This bash script is copyrighted. See the LICENSE file included in this distribution.
