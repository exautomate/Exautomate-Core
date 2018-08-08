#!/bin/bash

##### Author Info ############################################################################
#     Brent Davis and Jacqueline Dron
#     University of Western Ontario, London, Ontario, Canada
#     2018
##############################################################################################

##### Description #############################################################################
#    MergeVCFs
#    Merges two .vcf files together and then runs a validate on them.
###############################################################################################

##### Input Parameters / Requirements #########################################################
#   Java
#
#   $1 is the first .vcf file to be merged
#   $2 is the second .vcf file to be merged
#   $3 is the path to hg19.fasta file
#   $4 is the output .vcf file name (include extension)
###############################################################################################

java -jar ../dependencies/GenomeAnalysisTK.jar -T CombineVariants -R $3 -V $1 -V $2 -o $4 -genotypeMergeOptions UNIQUIFY -env
dos2unix $4
java -jar ../dependencies/GenomeAnalysisTK.jar -T ValidateVariants -R $3 -V $4 --validationTypeToExclude ALL
