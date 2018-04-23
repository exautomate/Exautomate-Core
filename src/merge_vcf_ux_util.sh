#!/bin/bash

##### Author Info ############################################################################
#     Brent Davis & Jacqueline Dron
#     University of Western Ontario, London, Ontario, Canada
#     2018
##############################################################################################

##### Description #############################################################################
#    merge_vcfs_ux.sh
#    Script that merges multiple .vcf files together with some UX in mind.
###############################################################################################

##### Input Parameters / Requirements #########################################################
#  	vcftools, tabix, bgzip
#
#		Requires all .vcf.gz files to be in the input/merge/ folder (/src/-> ../input/merge/folder)
###############################################################################################

#dos2unix *.vcf
ls -l -s -h ../input/merge/*.vcf
echo "---- Divisor ----"
echo "These are the .vcf files to be merged."
echo "---- Divisor ----"

###Make a branch for 1) Rename, 2)


choice="empty"
echo "Please enter the name of any to be moved to the temporary holding folder."
echo "Enter the filenames one-at-a-time to be removed, followed by enter/return. Type 'done' to continue."

cd ../input/merge/
mkdir movedfiles
while [ "$choice" != "done" ];
do

 read -e -p "Choose files to be move: " choice;
 mv $choice ./movedfiles/

done

echo "--- Running bgzip ---"
echo ""
for i in *.vcf
do
  bgzip -c $i > $i.gz
done
echo "--- Completed bgzip ---"
echo ""


  echo "--- Running Tabix ---"
  echo ""
  for i in *.vcf.gz
  do
    tabix $i
  done
  echo "--- Completed Tabix ---"
  echo ""

  echo "--- Running vcf-concat ---"
  echo ""
  #Using --pad-missing [ . in place of missing columns ] and -s to allow small overlaps in files.
  #vcf-concat -p -s *.vcf.gz | bgzip -c > merged.vcf.gz
  vcf-merge -R "0|0" *.vcf.gz | bgzip -c > merged.vcf.gz

 #java -Xmx16g -jar ../../dependencies/GenomeAnalysisTK.jar -T CombineVariants -R ../../dependencies/hg19.fasta -V 1116E.clc.vcf.gz -V 1188E.clc.vcf.gz -o iteration1.vcf.gz -genotypeMergeOptions UNIQUIFY -env

#count=1
#for i in *.vcf.gz
# do
#
#   if [ $count -eq 1 ]
#   then
#     tmpfile=$i
#   elif [$count -eq 2 ]
#   then
#     java -Xmx16g -jar ../../dependencies/GenomeAnalysisTK.jar -T CombineVariants -R ../../dependencies/hg19.fasta -V $tmpfile -V $i -o $count.vcf.gz -genotypeMergeOptions UNIQUIFY -env
#   else
#   then
#     subcount=$((count-1));
#     java -Xmx16g -jar ../../dependencies/GenomeAnalysisTK.jar -T CombineVariants -R ../../dependencies/hg19.fasta -V $subcount.vcf.gz -V $i -o $count.vcf.gz -genotypeMergeOptions UNIQUIFY -env
#
#   fi
#
#   count=$((count+1));
#
# done



  echo ""
  echo "--- Finishing vcf-concat ---"

  #Put files back.
  mv /movedfiles/* ./


#  for i in *.vcf
# do
# sed -i 's/E_R1.*$/E_R1/g' $i
# done
