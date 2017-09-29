#!/bin/bash
# $1 - First VCF file to be merged
# $2 - Second VCF file to be merged
# $3 - Path to HG 19 FASTA file.
# $4 - Output vcf file name.

java -jar GenomeAnalysisTK.jar -T CombineVariants -R $3 -V $1 -V $2 -o $4 -genotypeMergeOptions UNIQUIFY -env
