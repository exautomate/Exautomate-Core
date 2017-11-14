#!/bin/bash

#Script to automate the Robarts / Computer Science collaboration.
#Requires local copy of Genome Analysis Toolkit in local folder.
# $1 is hg.fasta input for GATK
# $2 is merged file including extension (.vcf)
# $3 is name for merged output file including extension
# $4 is the number of header files in the vcf file.
# $5 is the name for the file to be put on the plink output files.
# $6 is the kernel to run.
# $7 is the number of controls.
# $8 is the method for SKAT (SKAT-O, SKAT, etc)

#This takes the number of samples from the vcf file to be merged together.
#numControls=$(awk '{if ($1 == "#CHROM"){print NF-9; exit}}' $7)
numControls=$7
echo "Finished counting controls - " $numControls


#Use Jacqueline's merging script here.
##PUT IN DEPENDENCIES ##
java -jar GenomeAnalysisTK.jar -T SelectVariants -R $1 -V $2 -o $3 -restrictAllelesTo BIALLELIC -selectType SNP
bgzip -c $3 > $3.gz
#rm $2.biAllelic.vcf
vcftools --gzvcf $3.gz --min-alleles 2 --max-alleles 2 --remove-indels --recode --stdout | gzip -c > $3.2.gz
#rm $2.biAllelic.vcf.gz

echo "Finished GATK usage"

bgzip -d $3.2.gz

# SED COMMAND SCRIPT THAT BRENT MADE! this is to fix the formatting inconsistancies that were generated from the merging steps
# can the input be a gzvcf file? if not, then we need to add in a step to unzip the file
# We can put the unzipping in there if we need to.
echo "Calling formatFix"
./formatFix.sh $3.2 $4 $3

#need to add something to do an automatic overwrite
bgzip -c $3 > $3.gz

#Clean up .vcf . If needed again unzip the $3 with gunzip
#rm $3.vcf

# removes any position with missing data (. or 1/.)
vcftools --gzvcf $3.gz --max-missing 1 --recode --stdout | gzip -c > $3.noMiss.vcf.gz
# removes X and Y chromosome positions
vcftools --gzvcf $3.noMiss.vcf.gz --not-chr X --not-chr Y --recode --stdout | gzip -c > $3.noMissXY.vcf.gz
#rm $3.noMiss.vcf.gz

# generation of plink and binary plink files
vcftools --gzvcf $3.noMissXY.vcf.gz --plink --out $3.noMissXY
#rm $3.noMiss.vcf.gz
plink --file $3.noMissXY --make-bed --out $5 --noweb

#rm $3.noMissXY

awk '{if (NR <= $numControls){$6=1;print} if (NR >$numControls){$6=2;print}}' $5.fam > $5.adj.fam

#-----------------
#----Begin ANNOVAR

#Requires ANNOVAR perl scripts available in the local folder.
#Can automate to take the file location later.
#Changing the ANNOVAR commands may require editing the ANNOVAR to SetID script.
####UPDATE THIS TO RUN FROM DEPENDENCIES FOLDER #######
./table_annovar.pl $3.noMissXY.vcf.gz humandb/ -buildver hg19 -out $3.noMissXY.anno -remove -protocol refGene -operation g -nastring . -vcfinput

#Calling conversion script.
./AnnovarToSetID.sh $3.noMissXY.anno.hg19_multianno.txt $3

echo "Exome Analysis Script complete. Results are in " $5 " and the vcf file made is found in " $3.noMissXY.vcf.gz


echo "Running SKAT"

Rscript RunSkat.R $5.bed $5.bim $5.adj.fam $3.SetID "SSD_File.SSD" $6 $8

echo "SKAT complete."
