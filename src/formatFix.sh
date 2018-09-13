#!/bin/bash

##### Author Info ############################################################################
#     Brent Davis and Jacqueline Dron
#     University of Western Ontario, London, Ontario, Canada
#     2018
##############################################################################################

##### Description #############################################################################
#    formatFix
#    Fixes format inconsistancies in .vcf file that arise through the merging process.
###############################################################################################

##### Input Parameters ########################################################################
#   $1 is merged .vcf file (no extension)
#   $2 is # of header lines in .vcf file to be ignored
#   $3 is name for merged output .vcf file
###############################################################################################

echo "Parameter input: File name ["$1"] | Number of header lines in .vcf ["$2"] | Output .vcf name ["$3"]"
echo ""

file_name=$1
N=$(wc -l < $file_name)
L=$(($N-$2))
head -n $2 $1 > $1_top
tail -n $L $1 > $1_bottom
T=$1_top
B=$1_bottom

# This ensures that the genotype coding of the merged .vcf file is consistant. 
sed -i 's/\.\/\./0\|0/g' $B
sed -i 's/\.:\.:\./0\|0/g' $B
sed -i 's/\t0:\.:\./\t0\|0/g' $B
sed -i 's/:\.:\./\t0\|0/g' $B
cat $T $B > $3
rm $T
rm $B
