#!/bin/bash
echo ""
echo "---- [formatFix] SCRIPT STARTING ----"
echo ""

# Script to fix the format of merged .VCF the Robarts / Computer Science collaboration.
# $1 is merged .VCF file without extension.
# $2 is # of header lines in .VCF file to be ignored.
# $3 is name for merged output .VCF file.

echo "Parameter input: File name ["$1"] | Number of header lines in .VCF ["$2"] | Output .VCF name ["$3"]"
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
echo "---- [formatFix] SCRIPT FINISHED ----"
echo ""