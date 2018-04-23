#!/bin/bash

##### Author Info ############################################################################
#     Brent Davis
#     University of Western Ontario, London, Ontario, Canada
#     2018
##############################################################################################

##### Description #############################################################################
#    formatFix
#    Fixes format inconsistancies in .vcf file that arise through the merging process.
###############################################################################################

##### Input Parameters / Requirements #########################################################
#   $1 is merged .VCF file without extension.
#   $2 is # of header lines in .VCF file to be ignored.
#   $3 is name for merged output .VCF file.
###############################################################################################

echo "Parameter input: File name ["$1"] | Number of header lines in .vcf ["$2"] | Output .vcf name ["$3"]"
echo ""

file_name=$1
N=$(wc -l < $file_name)
#echo $N
L=$(($N-$2))
#echo $L "L is that"
head -n $2 $1 > top_$1
#echo "Top " $2 "lines extracted"
tail -n $L $1 > bottom_$1
T=top_$1
B=bottom_$1

ls -l  $B
sed -i 's/\.\/\./0\|0/g' $B
sed -i 's/\.:\.:\./0\|0/g' $B
sed -i 's/\t0:\.:\./\t0\|0/g' $B
sed -i 's/:\.:\./\t0\|0/g' $B
cat $T $B > $3
rm $T
rm $B
