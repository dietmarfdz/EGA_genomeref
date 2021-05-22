#!/bin/bash


###################################################################
#Script Name    : genome_ref_cal.sh
#Date           : 2021-05-22
#Version        : 3.5
#Author         : Dietmar Fernandez (dietmar.fernandez@crg.eu)
#usage          : bash genome_ref_cal.sh
#Description    : This script allows to calculate the genome reference from a vcf file. We extracted unique nucleotides per pos in hg17, grch37, grch38 and created a dictionary.
#Description    : It searchs for matches in 3 dictionaries (one per reference genome gb37, gb38 & gh17) and takes the one having matches (only one) generating a text file with the result.
#Requirements   : Bcftools (tested version 1.9), htslib (tested version 1.9), gzip (tested version 1.10), awk (tested version Awk 5.0.1), grep (tested version 3.4), sed (tested sed (GNU sed) 4.7), wc (tested version (GNU coreutils) 8.30).
###################################################################

#We establish where the dic files are located
path_dic="/PATH/TO/YOUR/DIC/ref_dics"

#We have to work with the file bgzipped compressed and tabix indexed
file=$(basename *.vcf.gz)
tabix -p vcf $file

#We get the list of chromosomes present in each vcf and with the number of variants present sorted descending:

zcat $file | awk '{print $1}' | grep -v "#" |sort |uniq -c |sort -r -n >$file.chromosome

lines=$(wc -l $file.chromosome | awk '{print $1}')

for i in $(seq 1 $lines)
do
    chrom=$(awk '{print $2}' $file.chromosome |head -n $i |tail -n 1)
    #We extract the variants:
    bcftools query -r $chrom -f'%CHROM\t%POS\t%REF\n' $file -o $chrom.variants.txt
    #We select a maximum number of 10K random variants per chromosome.
    shuf -n 10000 $chrom.variants.txt | sort >subset.$chrom.variants.txt
    sed -i 's/chr//g' subset.$chrom.variants.txt
    rm $chrom.variants.txt
    chrom2=$(awk '{print $1}' subset.$chrom.variants.txt |head -n 1)
    #Now we look for the first 100 matches within each of the variants from the vcf and the subset of the dictionaries.
    grep -m 100 -Ef subset.$chrom.variants.txt $path_dic/subset.chr$chrom2.final.dic_hg17 | wc -l >$chrom.matches_gb17.txt
    grep -m 100 -Ef subset.$chrom.variants.txt $path_dic/subset.chr$chrom2.final.dic_grch37 | wc -l >$chrom.matches_grch37.txt
    grep -m 100 -Ef subset.$chrom.variants.txt $path_dic/subset.chr$chrom2.final.dic_grch38 | wc -l >$chrom.matches_grch38.txt
done

head *.matches_gb17.txt>>all_match_gb17
head *.matches_grch37.txt>>all_match_grch37
head *.matches_grch38.txt>>all_match_grch38

#Organizing files:
mkdir variants_subset
mv subset* ./variants_subset

mkdir gb17 grch37 grch38
mv *.matches_gb17.txt ./gb17/
mv *.matches_grch37.txt ./grch37/
mv *.matches_grch38.txt ./grch38/

# Declare a string array with type
declare -a StringArray=("gb17" "grch37" "grch38")

# Read the array values with space
for j in "${StringArray[@]}"
do
	cd $j
	sum=0
	mypath=$(pwd)
	mypath=$(basename $mypath)
	for i in $(ls *.txt); do value=$(head -n 1 $i); sum=$((sum+ value)); done
	chrom_tot=$(ls *.txt | wc -l | awk '{print $1}')
	echo "There are $sum matches and $chrom_tot chromosomes in reference $mypath" >>../final
	cd ..
done

awk -v max=0 '{if($3>max){want=$10; max=$3}}END{print want} ' final >infer_ref
