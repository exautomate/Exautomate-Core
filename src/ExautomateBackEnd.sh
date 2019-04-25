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
#   $3 is the filename for the .vcf and PLINK output files
#   $4 is the kernel to run
#   $5 is the method for SKAT (SKAT-O, SKAT, etc)
#   $6 is the multiple comparisons adjustment following analysis
#
#   R (plus packages), Java, GATK, PLINK, vcftools, ANNOVAR, bgzip, tabix
###############################################################################################

echo "### Entering ExautomateBackEnd.sh ###"
echo ""

LOGFILE=../output/EXAUTOMATEmethods.log
echo "" >> $LOGFILE
echo "ExautomateBackEnd.sh contains all of the commands used to prepare the .vcf file for $5" >> $LOGFILE #methods.log

# Takes a .vcf.gz file, unzips it, searches for the '#CHROM' line in the vcf, takes the file and converts the rows (sample IDs) to a line-by-line file and removes the non-sample IDs.
bgzip -c $2 | grep -m 1 '#CHROM' | sed -e 'y/\t/\n/' | tail -n +10 > samplelist.txt

########## PREPARING .VCF FILE FOR SKAT/SKAT-O ANALYSIS ##########
### Recommend setting -Xmx nG based on RAM of computer, where n is the RAM to be used. ###
# Ensuring the .vcf file only contains biallelic, single-nucleotide polymorphisms.

#GATK 3 Compatible
#java -jar ../dependencies/GenomeAnalysisTK.jar -T SelectVariants -R $1 -V $2 -o ../output/$3.biallelic.vcf -restrictAllelesTo BIALLELIC -selectType SNP

#GATK 4 Update
## TO-DO: make an output folder if it doesn't already exist
../dependencies/gatk-4.1.1.0/gatk-4.1.1.0/gatk --java-options "-Xmx32G" SelectVariants -R $1 -V $2 -O ../output/$3.biallelic.vcf -restrictAllelesTo BIALLELIC -selectType SNP


bgzip -c ../output/$3.biallelic.vcf > ../output/$3.biallelic.vcf.gz
vcftools --gzvcf ../output/$3.biallelic.vcf.gz --min-alleles 2 --max-alleles 2 --remove-indels --recode --stdout | gzip -c > ../output/$3.biallelic.2.vcf.gz

# Unzipping file to prepare for formatFix.sh.
bgzip -d ../output/$3.biallelic.2.vcf.gz

# formatFix.sh fixes the formatting inconsistancies that were generated from the merging steps for the .vcf files.
./formatFix.sh ../output/$3.biallelic.2.vcf ../output/$3.formatFix.vcf

bgzip -c ../output/$3.formatFix.vcf > ../output/$3.formatFix.vcf.gz

# Removes any position with missing data/allele calls.
vcftools --gzvcf ../output/$3.formatFix.vcf.gz --max-missing 1 --recode --stdout | gzip -c > ../output/$3.noMiss.vcf.gz
# Removes X and Y chromosome positions.
vcftools --gzvcf ../output/$3.noMiss.vcf.gz --not-chr X --not-chr Y --recode --stdout | gzip -c > ../output/$3.noMissXY.vcf.gz

########## GENERATING PLINK FILES FOR SKAT/SKAT-O ANALYSIS ##########
vcftools --gzvcf ../output/$3.noMissXY.vcf.gz --plink --out ../output/$3.noMissXY
plink --file ../output/$3.noMissXY --make-bed --out ../output/$3 --noweb

# Manual update of the .fam file with phenotype status, necessary for SKAT.
placeholder="y"
choice="n"
while [ $choice != $placeholder ]; do
  read -e -p "Stop and edit the .fam file (must be the same name as what was entered at the beginning + .adj.fam). Finished? (y/n):" choice
done

dos2unix ../output/$3.adj.fam

########## USING ANNOVAR TO GENERATE .SETID FILE FOR SKAT/SKAT-O ANALYSIS ##########
### TODO: UPDATE THIS TO RUN FROM DEPENDENCIES FOLDER ###
# Changing the ANNOVAR commands may require editing the ANNOVAR to SetID script.
bgzip -d -c ../output/$3.noMissXY.vcf.gz > ../output/$3.noMissXY.vcf
../dependencies/annovar/convert2annovar.pl -format vcf4 ../output/$3.noMissXY.vcf > ../output/tmp.avinput
../dependencies/annovar/table_annovar.pl ../output/tmp.avinput ../dependencies/annovar/humandb/ -buildver hg19 -out ../output/$3.noMissXY.anno -remove -protocol refGene -operation g -nastring .

# Calling conversion script from ANNOVAR to .SetID files.
echo ""
./AnnovarToSetID.sh ../output/$3.noMissXY.anno.hg19_multianno.txt ../output/$3

echo "File preparation for $5 analysis complete. Results are in $3. The processed, final .vcf file is " ../output/$3.noMissXY.vcf.gz
echo ""

########## SKAT/SKAT-O ANALYSIS ##########
echo "Beginning $5 analysis."
echo ""
Rscript RunSkat.R ../output/$3.bed ../output/$3.bim ../output/$3.adj.fam ../output/$3.adj.SetID "SSD_File.SSD" $4 $5 $6

echo "$5 analysis complete."

echo ""
echo "### Exiting ExautomateBackEnd.sh ###"
