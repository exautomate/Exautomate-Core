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
### TODO: Use Jacqueline's merging script here. ###
### TODO: Direct bgzip and vcftools to the dependencies folder ###
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
### NOTE: Yes. Will try to push an update version.
echo "----- Invoking formatFix.sh ------"
echo ""
# INVOKE FILE-1 FILE-2 INVOCATION ONLY
./formatFix.sh ../output/$3.biallelic.2.vcf $4 ../output/$3.formatFix.vcf
echo "formatFix.sh finished"
echo ""

### TODO: Add something TODO an automatic overwrite ###
bgzip -c ../output/$3.formatFix.vcf > ../output/$3.formatFix.vcf.gz

#Clean up .vcf . If needed again unzip the $3 with gunzip
#rm $3.vcf

# removes any position with missing data (. or 1/.)
vcftools --gzvcf ../output/$3.formatFix.vcf.gz --max-missing 1 --recode --stdout | gzip -c > ../output/$3.noMiss.vcf.gz
# removes X and Y chromosome positions
vcftools --gzvcf ../output/$3.noMiss.vcf.gz --not-chr X --not-chr Y --recode --stdout | gzip -c > ../output/$3.noMissXY.vcf.gz
#rm $3.noMiss.vcf.gz

########## GENERATING PLINK FILES FOR SKAT/SKAT-O ANALYSIS ##########
vcftools --gzvcf ../output/$3.noMissXY.vcf.gz --plink --out ../output/$3.noMissXY
#rm $3.noMiss.vcf.gz
### TODO:
plink --file ../output/$3.noMissXY --make-bed --out ../output/$5 --noweb
#rm $3.noMissXY

#Updating the .fam file with phenotype status, necessary for SKAT
################################# this needs fixing i think
### TODO: Make this run with this - https://stackoverflow.com/questions/47230019/awk-compare-columns-from-two-files-and-replace-text-in-first-file
### TODO: Figure out whether to take list of controls and cases or to auto detect.
## NOTE: ../input/controllist.txt needs to be a file of one control name per line. It will match column 6 of the .fam file
## NOTE: If the vcf file format changes how it labels its row headers in the vcf, this will need to be updated.
awk -i inplace 'NR==FNR{ a[$1]; next }$1 in a{ $6=1 }1' ../input/controllist.txt FS=',' OFS=',' ../output/$5.adj.fam
awk -i inplace 'NR==FNR{ a[$1]; next }$1 in a{ $6=2 }1' ../input/controllist.txt FS=',' OFS=',' ../output/$5.adj.fam
#awk '-var ###FIX###{if (NR <= $numControls){$6=1;print} if (NR >$numControls){$6=2;print}}' ../output/$5.fam > ../output/$5.adj.fam

########## USING ANNOVAR TO GENERATE .SETID FILE FOR SKAT/SKAT-O ANALYSIS ##########
#Requires ANNOVAR perl scripts in the local folder
### TODO: maybe automate to take the file location ###
### TODO: UPDATE THIS TO RUN FROM DEPENDENCIES FOLDER ###
#Changing the ANNOVAR commands may require editing the ANNOVAR to SetID script.
bgzip -d -c ../output/$3.noMissXY.vcf.gz > ../output/$3.noMissXY.vcf
../dependencies/annovar/table_annovar.pl ../output/$3.noMissXY.vcf ../dependencies/annovar/humandb/ -buildver hg19 -out ../output/$3.noMissXY.anno -remove -protocol refGene -operation g -nastring .

#Calling conversion script.
./AnnovarToSetID.sh ../output/$3.noMissXY.anno.hg19_multianno.txt ../output/$3

echo "File preparation for " $8 " analysis complete. Results are in " $5 " and the processed, final .vcf file is " ../output/$3.noMissXY.vcf.gz
echo ""

########## SKAT/SKAT-O ANALYSIS ##########
echo "Beginning SKAT/SKAT-O analysis with the following files and parameters: "
### TODO: maybe make a list of the things so the user can see? ###
echo ""
Rscript RunSkat.R ../output/$5.bed ../output/$5.bim ../output/$5.adj.fam ../output/$3.SetID "SSD_File.SSD" $6 $8

echo "SKAT/SKAT-O analysis complete."
