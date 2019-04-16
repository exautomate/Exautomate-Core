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
#   $1 is merged .vcf file (with extension)
#   $2 is name for merged output .vcf file
###############################################################################################

echo "### Entering formatFix.sh ###"

# Number of header lines
headerLines=$(grep -c "#" $1)

file_name=$1
N=$(wc -l < $file_name)
L=$(($N-$headerLines))
head -n $headerLines $1 > $1_top
tail -n $L $1 > $1_bottom
T=$1_top
B=$1_bottom

# This ensures that the genotype coding of the merged .vcf file is consistant.
sed -i 's/\.\/\./0\|0/g' $B
cat $T $B > $2.temp.vcf
bcftools annotate -x ^FORMAT/GT -o $2 $2.temp.vcf
rm $T
rm $B
rm $2.temp.vcf

echo "### Exiting formatFix.sh ###"
echo ""
