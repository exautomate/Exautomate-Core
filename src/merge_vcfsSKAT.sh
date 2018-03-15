#!/bin/bash

##### Author Info ############################################################################
#     Jacqueline Dron
#     University of Western Ontario, London, Ontario, Canada
#     2018
##############################################################################################

##### Description #############################################################################
#    merge_vcfsSKAT
#    Script that merges multiple .vcf files together.
###############################################################################################

##### Input Parameters / Requirements #########################################################
#  	vcftools, tabix, bgzip
#
#		Requires all .vcf files to be meged together to exist in a folder with nothing else but
#		the ./merge_vcfsSKAT.sh file.
#
#		$1 is merged .VCF file without extension.
#   $2 is # of header lines in .VCF file to be ignored.
#   $3 is name for merged output .VCF file.
###############################################################################################

#bgzip each .VCF file
echo "-- bgzip starting --"
echo ""

ls *.vcf > all_vcfs.txt
declare -a all_vcfs
readarray -t all_vcfs < all_vcfs.txt
echo "Zipping ${#all_vcfs[*]} .VCFs"
echo ""

for i in ${all_vcfs[@]}
	do bgzip $i
	done
echo "-- bgzip finished --"
echo ""

#Indexing the zipped .VCF files
echo "-- index starting --"
echo ""
ls *.vcf.gz > all_gz_vcfs.txt
declare -a all_gz_vcfs
readarray -t all_gz_vcfs < all_gz_vcfs.txt

for i in ${all_gz_vcfs[@]}
    do tabix -p vcf $i
    done

echo "-- index finished --"
echo ""

#Merge .vcf files using vcftools
echo "-- vcftools merge starting --"
echo ""
echo "Merging ${#all_gz_vcfs[*]} zipped .VCFs into one .VCF"
echo ""

for i in all_gz_vcfs
    do vcf-merge ${all_gz_vcfs[*]} | bgzip -c > merged.vcf.gz
    done

echo "Finished merging ${#all_gz_vcfs[*]} .VCF files";
echo "";

rm -f all_vcfs.txt
rm -f all_gz_vcfs.txt

echo "-- vcftools merge finished --"
echo ""

#Clean up the files that are not needed
echo "-- file clean-up starting --"
echo ""

rm -f *.txt
rm -f *.tbi
rm -f *.vcf.gz
rm -f *.vcfidx
rm -f *.map
rm -f *.ped

echo "-- file clean-up finished --"
echo ""

exit;
