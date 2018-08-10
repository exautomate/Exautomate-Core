#!/bin/bash

##### Author Info ############################################################################
#     Brent Davis and Jacqueline Dron
#     University of Western Ontario, London, Ontario, Canada
#     2018
##############################################################################################

##### Description #############################################################################
#    ExautomateBackEnd
#    ?????????
###############################################################################################

##### Input Parameters / Requirements #########################################################
#   R (plus packages), Java, GATK, PLINK, vcftools, ANNOVAR, bgzip
#
#   $1 is hg.fasta input for GATK
#   $2 is merged .vcf file (including extension)
#   $3 is name for merged output .vcf file (including extension)
#   $4 is the number of header files in the .vcf file
#   $5 is the filename for the PLINK output files
#   $6 is the kernel to run
#   $7 is the number of controls
#   $8 is the method for SKAT (SKAT-O, SKAT, etc)
###############################################################################################

#This takes the number of samples from the .vcf file to be merged together.
#numControls=$(awk '{if ($1 == "#CHROM"){print NF-9; exit}}' $7)
numControls=$7
echo "Finished counting controls = " $numControls
echo ""

#Takes a .vcf.gz file, unzips it, searches for the '#CHROM' line in the vcf, takes the file and converts the rows (sample ids) to a line by line file
#and removes the non-sample ids.
bgzip -c $2 | grep -m 1 '#CHROM' | sed -e 'y/\t/\n/' | tail -n +10 > samplelist.txt

########## PREPARING .VCF FILE FOR SKAT/SKAT-O ANALYSIS ##########
####Recommend setting -Xmx nG based on RAM of computer, where n is the RAM to be used.
java -jar ../dependencies/GenomeAnalysisTK.jar -T SelectVariants -R $1 -V $2 -o ../output/$3.biallelic.vcf -restrictAllelesTo BIALLELIC -selectType SNP
bgzip -c ../output/$3.biallelic.vcf > ../output/$3.biallelic.vcf.gz
#rm $2.biAllelic.vcf
vcftools --gzvcf ../output/$3.biallelic.vcf.gz --min-alleles 2 --max-alleles 2 --remove-indels --recode --stdout | gzip -c > ../output/$3.biallelic.2.vcf.gz
#rm $2.biAllelic.vcf.gz

#Unzipping file to prepare for formatFix.sh
bgzip -d ../output/$3.biallelic.2.vcf.gz

#formatFix.sh is to fix the formatting inconsistancies that were generated from the merging steps for the .vcf files
### QUESTION: can the input be a gzvcf file? if not, then we need to add in a step to unzip the file. ###
### NOTE: We can put the unzipping in there if we need to. ###
echo "Calling formatFix.sh"
echo ""
./formatFix.sh ../output/$3.biallelic.2.vcf $4 ../output/$3.formatFix.vcf
echo "formatFix.sh finished"
echo ""

bgzip -c ../output/$3.formatFix.vcf > ../output/$3.formatFix.vcf.gz

#Clean up .vcf . If needed again unzip the $3 with gunzip
#rm $3.vcf

# removes any position with missing data (. or 1/.)
vcftools --gzvcf ../output/$3.formatFix.vcf.gz --max-missing 1 --recode --stdout | gzip -c > ../output/$3.noMiss.vcf.gz
# removes X and Y chromosome positions
vcftools --gzvcf ../output/$3.noMiss.vcf.gz --not-chr X --not-chr Y --recode --stdout | gzip -c > ../output/$3.noMissXY.vcf.gz


########## GENERATING PLINK FILES FOR SKAT/SKAT-O ANALYSIS ##########
vcftools --gzvcf ../output/$3.noMissXY.vcf.gz --plink --out ../output/$3.noMissXY
plink --file ../output/$3.noMissXY --make-bed --out ../output/$5 --noweb

#Updating the .fam file with phenotype status, necessary for SKAT
placeholder="y"
choice="n"
while [ $choice != $placeholder ]; do
  read -e -p "Stop and edit the fam file. (must be the same name as what was entered at the beginning + .adj.fam). Finished? (y/n):" choice
done

dos2unix ../output/$5.adj.fam

########## USING ANNOVAR TO GENERATE .SETID FILE FOR SKAT/SKAT-O ANALYSIS ##########
#Requires ANNOVAR perl scripts in the local folder
### TODO: maybe automate to take the file location ###
### TODO: UPDATE THIS TO RUN FROM DEPENDENCIES FOLDER ###
#Changing the ANNOVAR commands may require editing the ANNOVAR to SetID script.
#bgzip -d -c ../output/$3.noMissXY.vcf.gz > ../output/$3.noMissXY.vcf
#../dependencies/annovar/convert2annovar.pl -format vcf4 ../output/$3.noMissXY.vcf > ../output/tmp.avinput
#../dependencies/annovar/table_annovar.pl ../output/tmp.avinput ../dependencies/annovar/humandb/ -buildver hg19 -out ../output/$3.noMissXY.anno -remove -protocol refGene -operation g -nastring .
bgzip -d -c ../output/$3.noMissXY.vcf.gz > ../output/$3.noMissXY.vcf
../dependencies/annovar/convert2annovar.pl -format vcf4 ../output/$3.noMissXY.vcf > ../output/tmp.avinput
../dependencies/annovar/table_annovar.pl ../output/tmp.avinput ../dependencies/annovar/humandb/ -buildver hg19 -out ../output/$3.noMissXY.anno -remove -protocol refGene -operation g -nastring .

#Calling conversion script.
./AnnovarToSetID.sh ../output/$3.noMissXY.anno ../output/$3

echo "File preparation for " $8 " analysis complete. Results are in " $5 " and the processed, final .vcf file is " ../output/$3.noMissXY.vcf.gz
echo ""

########## SKAT/SKAT-O ANALYSIS ##########
echo "Beginning SKAT/SKAT-O analysis with the following files and parameters: "
### TODO: maybe make a list of the things so the user can see? ###
echo ""
Rscript RunSkat.R ../output/$5.bed ../output/$5.bim ../output/$5.adj.fam ../output/$3.SetID "SSD_File.SSD" $6 $8

echo "SKAT/SKAT-O analysis complete."
