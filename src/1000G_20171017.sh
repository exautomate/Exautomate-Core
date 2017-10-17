#!/bin/bash

##### Author Info ############################################################################
#     Written by Jacqueline Dron
#     Robarts Research Institute, Schulich School of Medicine and Dentistry
#     University of Western Ontario, London, Ontario, Canada
#     March 2016
##############################################################################################

##### Description #############################################################################
#    This script downloads and processes all of the vcf files for each chromosome, 
#    while filtering it using the specifieid .bed file ($1), and for only the individuals
#    whose IDs are specified in the .txt file ($2 and $3). The intermediate files will be
#    deleted. The seperate chromosome.vcf files will be concatinated.
###############################################################################################

##### Input Parameters ########################################################################
# $1 is the .bed file (include extension)
# $2 is the main population.txt file (include extension)
# $3 is the males population.txt file (include extension)
# $4 is the thing we need to name the files, based on the data type and source (ex. _1k_F_W)
###############################################################################################

echo "";
echo "Starting 1000G_euro script:";
echo "";


### loop through chromosomes to download their files and process with WES .bed file ###
for i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22	
	do
	echo "Processing chromosome ${i}...";
	echo "";
	tabix -fhB ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/release/20130502/ALL.chr${i}.phase3_shapeit2_mvncall_integrated_v5a.20130502.genotypes.vcf.gz $1 | vcf-subset -e -c $2 > chr${i}$4.vcf		# downloads the chromosome .vcf, filters it against the bed file, filters it by the population we specified in the text file, and removes lines that are only WT
	done


### X and Y can't be looped through because they have different download links ###
echo "Processing chromosome X...";
echo "";
tabix -fhB ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/release/20130502/ALL.chrX.phase3_shapeit2_mvncall_integrated_v1b.20130502.genotypes.vcf.gz $1 | vcf-subset -e -c $2 > chrX$4.vcf 	# same methods as the tabix line above

echo "Processing chromosome Y...";
echo "";
tabix -fhB ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/release/20130502/ALL.chrY.phase3_integrated_v2a.20130502.genotypes.vcf.gz $1 | vcf-subset -e -c $3 > chrY$4.vcf		# same methods as the tabix line above


### clean up files ###
echo "Cleaning up files...";
echo "";
rm -f *genotypes.vcf.gz.tbi	# deletes files that contains "genotypes.vcf.gz.tbi" - they are a biproduct of the above steps, and are not required later on
 

### concat all the seperate chromosome vcfs into one ###
echo "Concatinating chromosome files...";
echo "";
vcf-concat -p *$4.vcf > merged$4.all.vcf   

##rm -f *$4.vcf 	# delete chromosome.vcfs when finished

#Commenting these out so we can rename them after.

echo "All done!";
echo "";

exit; 

