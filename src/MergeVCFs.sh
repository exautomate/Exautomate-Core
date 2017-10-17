#!/bin/bash
# $1 - First VCF file to be merged
# $2 - Second VCF file to be merged
# $3 - Path to HG 19 FASTA file.
# $4 - Output vcf file name.

#Author: Jacqueline Dron and Brent Davis
#Merges two vcf files together and then runs a validate on them.
#Does not deal with the dos vs unix file formating problems we've encountered before. To be added?

java -jar GenomeAnalysisTK.jar -T CombineVariants -R $3 -V $1 -V $2 -o $4 -genotypeMergeOptions UNIQUIFY -env
##TEST
java -jar GenomeAnalysisTK.jar -T ValidateVariants -R $3 -V $4 --validationTypeToExclude ALL
