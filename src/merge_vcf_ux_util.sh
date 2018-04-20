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

ls -l -s -h ../input/merge/*.vcf.*
echo "---- Divisor ----"
echo "These are the vcfs to be merged. Please enter the name of any to be moved to the temporary holding folder."
echo "---- Divisor ----"

###Make a branch for 1) Rename, 2)


choice="empty"
echo "Enter the filenames to be removed, one at a time followed by enter/return, or hit enter to continue."

cd ../input/merge/
mkdir movedfiles
while [ "$choice" != "done" ];
do

 read -e -p "Choose a filename " choice;
 mv $choice ./movedfiles/

done


done

  echo "--- Running Tabix ---"
  echo ""
  for i in *.vcf.*
  do
    tabix $i
  done
  echo "--- Completed Tabix ---"
  echo ""

  echo "--- Running vcf-concat ---"
  echo ""
  #Using --pad-missing [ . in place of missing columns ] and -s to allow small overlaps in files.
  vcf-concat -p -s *.vcf.* | gzip -c > merged.vcf.gz
  echo ""
  echo "--- Finishing vcf-concat ---"

  #Put files back.
  mv /movedfiles/* ./
