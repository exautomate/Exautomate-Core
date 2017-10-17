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

  read -p "Enter the number of controls in your vcf file. Script assumes vcf is all controls, then all cases: " numControls
  echo ""

  read -p "Choose filename for processed vcf (include .vcf): " vcfOutput
  echo ""

  read -p "Choose filename for output plink files (no extension): " plinkOutput
  echo ""

  read -p "Enter the kernel to be used in the analysis: " kernel
  echo ""

  #Put in if statements asking for optimal.adj if the kernel is linear or linear weighted, and errors for unknown ones.

  ./ExomeAnalysisAutomationScript ../dependencies/hg_19.fasta $vcfInput $vcfOutput $headerLines $plinkOutput $kernel $numControls

elif [ $choice -eq 2 ]; then

  ls ../input/*.vcf
  read -p "Enter the name of the control vcf: " controlvcf
  numControls=$(awk '{if ($1 == "#CHROM"){print NF-9; exit}}' $controlvcf)
  echo "Detecting " $numControls " controls"
  echo ""

  ls ../input/*.vcf
  read -p "Enter the name of the cases vcf: " casesvcf
  echo ""

  read -p "Enter the name of the output file: " vcfInput

  ./MergeVCFs.sh $controlvcf $casesvcf ../dependencies/hg19.fasta $vcfInput

  read -p "Enter the desired name of the processed vcf: "

  read -p "Choose filename for output plink files (no extension): " plinkOutput
  echo ""

  read -p "Enter the kernel to be used in the analysis: " kernel
  echo ""

  ./ExomeAnalysisAutomationScript ../dependencies/hg_19.fasta $vcfInput $vcfOutput $headerLines $plinkOutput $kernel $numControls



elif [ $choice -eq 3 ]; then
#Requires wget.
#Fragile. If the location of the 1000 genome files are moved then this will fail.
  echo "To be implemented"

  wget -A ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/release/20130502/*.vcf.*

elif [ $choice -eq 4 ]; then

  ls ../input/*.sim
  read -p "Enter the filename of the .sim file to be used: " simInput
  echo ""

  read -p "Enter the filename for the output: " outputName
  echo ""

  ./synthesizeSKATFiles.sh $simInput $outputName

  read -p "Enter the kernel to run on the synthetic files: " kernel
  echo ""

  echo "Running SKAT"
  Rscript RunSkat.R $outputName.bed $outputName.bim $outputName.fam $outputName.bim.SetID "SSD_File.SSD" $kernel
  echo "SKAT complete."
  mv $outputName.* ../output/$outputName.*


else
  echo "Unknown input."
fi
