#!/bin/bash

##### Author Info ############################################################################
#     Brent Davis and Jacqueline Dron
#     University of Western Ontario, London, Ontario, Canada
#     2018
##############################################################################################

##### Description #############################################################################
#    ExautomateBackEnd
###############################################################################################

##### Input Parameters / Requirements #########################################################
#   $1 is hg.fasta input for GATK
#   $2 is merged .vcf file (with extension)
#   $3 is name for merged output .vcf file (with extension)
#   $4 is the number of header files in the .vcf file
#   $5 is the filename for the PLINK output files
#   $6 is the kernel to run
#   $7 is the number of controls
#   $8 is the method for SKAT (SKAT-O, SKAT, etc)
#
#   R (plus packages), Java, GATK, PLINK, vcftools, ANNOVAR, bgzip, tabix
###############################################################################################

### QUESTION: I don't actually think numControls gets used in this script. If not, can confirm to delete this line?
numControls=$7

# Takes a .vcf.gz file, unzips it, searches for the '#CHROM' line in the vcf, takes the file and converts the rows (sample IDs) to a line-by-line file and removes the non-sample IDs.
bgzip -c $2 | grep -m 1 '#CHROM' | sed -e 'y/\t/\n/' | tail -n +10 > samplelist.txt

########## PREPARING .VCF FILE FOR SKAT/SKAT-O ANALYSIS ##########
### Recommend setting -Xmx nG based on RAM of computer, where n is the RAM to be used. ###
# Ensuring the .vcf file only contains biallelic, single-nucleotide polymorphisms.
java -jar ../dependencies/GenomeAnalysisTK.jar -T SelectVariants -R $1 -V $2 -o ../output/$3.biallelic.vcf -restrictAllelesTo BIALLELIC -selectType SNP
bgzip -c ../output/$3.biallelic.vcf > ../output/$3.biallelic.vcf.gz
vcftools --gzvcf ../output/$3.biallelic.vcf.gz --min-alleles 2 --max-alleles 2 --remove-indels --recode --stdout | gzip -c > ../output/$3.biallelic.2.vcf.gz

# Unzipping file to prepare for formatFix.sh.
bgzip -d ../output/$3.biallelic.2.vcf.gz

# formatFix.sh fixes the formatting inconsistancies that were generated from the merging steps for the .vcf files.
echo "Calling formatFix.sh"
echo ""
./formatFix.sh ../output/$3.biallelic.2.vcf $4 ../output/$3.formatFix.vcf
echo "formatFix.sh finished"
echo ""

bgzip -c ../output/$3.formatFix.vcf > ../output/$3.formatFix.vcf.gz

# Removes any position with missing data/allele calls.
vcftools --gzvcf ../output/$3.formatFix.vcf.gz --max-missing 1 --recode --stdout | gzip -c > ../output/$3.noMiss.vcf.gz
# Removes X and Y chromosome positions.
vcftools --gzvcf ../output/$3.noMiss.vcf.gz --not-chr X --not-chr Y --recode --stdout | gzip -c > ../output/$3.noMissXY.vcf.gz


########## GENERATING PLINK FILES FOR SKAT/SKAT-O ANALYSIS ##########
vcftools --gzvcf ../output/$3.noMissXY.vcf.gz --plink --out ../output/$3.noMissXY
plink --file ../output/$3.noMissXY --make-bed --out ../output/$5 --noweb

# Manual update of the .fam file with phenotype status, necessary for SKAT.
placeholder="y"
choice="n"
while [ $choice != $placeholder ]; do
  read -e -p "Stop and edit the .fam file (must be the same name as what was entered at the beginning + .adj.fam). \n Finished? (y/n):" choice
done

dos2unix ../output/$5.adj.fam

########## USING ANNOVAR TO GENERATE .SETID FILE FOR SKAT/SKAT-O ANALYSIS ##########
### TODO: UPDATE THIS TO RUN FROM DEPENDENCIES FOLDER ###
# Changing the ANNOVAR commands may require editing the ANNOVAR to SetID script.
bgzip -d -c ../output/$3.noMissXY.vcf.gz > ../output/$3.noMissXY.vcf
../dependencies/annovar/convert2annovar.pl -format vcf4 ../output/$3.noMissXY.vcf > ../output/tmp.avinput
../dependencies/annovar/table_annovar.pl ../output/tmp.avinput ../dependencies/annovar/humandb/ -buildver hg19 -out ../output/$3.noMissXY.anno -remove -protocol refGene -operation g -nastring .

# Calling conversion script from ANNOVAR to .SetID files.
./AnnovarToSetID.sh ../output/$3.noMissXY.anno ../output/$3

echo "File preparation for " $8 " analysis complete. Results are in " $5 " and the processed, final .vcf file is " ../output/$3.noMissXY.vcf.gz
echo ""

########## SKAT/SKAT-O ANALYSIS ##########
echo "Beginning SKAT/SKAT-O analysis with the following files and parameters: "
echo ""
Rscript RunSkat.R ../output/$5.bed ../output/$5.bim ../output/$5.adj.fam ../output/$3.SetID "SSD_File.SSD" $6 $8

echo "SKAT/SKAT-O analysis complete."
echo ""
