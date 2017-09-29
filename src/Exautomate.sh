#!/bin/bash
###### Authors: Brent Davis and Jacqueline Dron
###### Exautomate: Bash script based utility to speed up exome analysis.
###### Requirements: R, Java, GATK, Plink, Vcftools.
clear
echo "Welcome to Ex-Automate."
printf "1: Pre-merged vcf \n 2: Merge case and control vcf for analysis. \n 3: Retrieve 1000 Genomes options \n 4: Synthetic run \n"
read -p "Enter (1-4): " choice

if [ $choice -eq 1 ]; then
  ls ../input/*.vcf
  read -p "Enter the vcf file you would like to analyze: " vcfInput
  echo ""
  #If there are comments (eg lines starting with #) mid-vcf file then this command is invalid. However, there should not be.
  headerLines=$(grep -o '#' $vcfInput | wc -l)
  read -p "Enter filename for processed vcf (include .vcf): " vcfOutput
  echo ""
  read -p "Enter filename for output plink files (no extension): " plinkOutput
  echo ""
  read -p "Enter the number of controls. Script assumes vcf is all cases, then all controls: " numControls

  ./ExomeAnalysisAutomationScript ../dependencies/hg_19.fasta $vcfInput $vcfOutput $headerLines $plinkOutput $numControls
elif [ $choice -eq 2 ]; then
  x
elif [ $choice -eq 3 ]; then
  x
elif [ $choice -eq 4 ]; then
  x
else
  echo "Unknown input."
fi
