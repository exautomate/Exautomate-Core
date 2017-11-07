#!/bin/bash
###### Authors: Brent Davis and Jacqueline Dron
###### Exautomate: Bash script based utility to speed up exome analysis.
###### Requirements: R (plus packages), Java, GATK, Plink, Vcftools, Annovar.
clear
echo "Welcome to Ex-Automate."
choice = 0

while [ $choice -ne 5]; do
  printf "1: Pre-merged vcf \n 2: Merge case and control vcf for analysis. \n 3: Retrieve 1000 Genomes options \n 4: Synthetic run \n 5: Exit \n"
  read -p "Enter (1-4): " choice
  if [ $choice -eq 1 ]; then

    ls ../input/*.vcf
    read -p -e "Enter the vcf file you would like to analyze: " vcfInput
    echo ""

    #If there are comments (eg lines starting with #) mid-vcf file then this command is invalid. However, there should not be.
    headerLines=$(grep -o '#' $vcfInput | wc -l)

    read -p -e "Enter the number of controls in your vcf file. Script assumes vcf is all controls, then all cases: " numControls
    echo ""

    read -p -e "Choose filename for processed vcf (include .vcf): " vcfOutput
    echo ""

    read -p -e "Choose filename for output plink files (no extension): " plinkOutput
    echo ""

<<<<<<< HEAD
  echo "Kernels: linear, linear.weighted, quadratic, IBS, 2wayIX"
  read -p "Enter the kernel to be used in the analysis: " kernel
  echo ""

#Handles the choice of methods that are available for different kernels.
  if [ "$kernel" == "linear" ] || [ "$kernel" == "linear.weighted" ]; then
    read -p "Choose SKAT or SKAT-O: " choice
    if [ "$choice" == "SKAT-O" ]; then
      method = "optimal.adj"
    else
      method = "davies"
    fi
  else
    method = "davies"
  fi


  #Put in if statements asking for optimal.adj if the kernel is linear or linear weighted, and errors for unknown ones.

  ./ExomeAnalysisAutomationScript ../dependencies/hg_19.fasta $vcfInput $vcfOutput $headerLines $plinkOutput $kernel $numControls $method
=======
    #make a file called kernelist.txt with all valid kernel names.
    more kernellist.txt
    read -p -e "Enter the kernel to be used in the analysis: " kernel
    echo ""

    #Put in if statements asking for optimal.adj if the kernel is linear or linear weighted, and errors for unknown ones.

    ./ExomeAnalysisAutomationScript ../dependencies/hg_19.fasta $vcfInput $vcfOutput $headerLines $plinkOutput $kernel $numControls
>>>>>>> cde13b9b8eb382f2ae4ca03c48840bb84c779891

  elif [ $choice -eq 2 ]; then

    ls ../input/*.vcf
    read -p -e "Enter the name of the control vcf: " controlvcf
    numControls=$(awk '{if ($1 == "#CHROM"){print NF-9; exit}}' $controlvcf)
    echo "Detecting " $numControls " controls"
    echo ""

    ls ../input/*.vcf
    read -p -e "Enter the name of the cases vcf: " casesvcf
    echo ""

    read -p -e "Enter the name of the output file: " vcfInput

    ./MergeVCFs.sh $controlvcf $casesvcf ../dependencies/hg19.fasta $vcfInput

    read -p -e "Enter the desired name of the processed vcf: "

    read -p -e "Choose filename for output plink files (no extension): " plinkOutput
    echo ""

    read -p -e "Enter the kernel to be used in the analysis: " kernel
    echo ""

<<<<<<< HEAD
  #Handles the choice of methods that are available for different kernels.
    if [ "$kernel" == "linear" ] || [ "$kernel" == "linear.weighted" ]; then
      read -p "Choose SKAT or SKAT-O: " choice
      if [ "$choice" == "SKAT-O" ]; then
        method = "optimal.adj"
      else
        method = "davies"
      fi
    else
      method = "davies"
    fi


  ./ExomeAnalysisAutomationScript ../dependencies/hg_19.fasta $vcfInput $vcfOutput $headerLines $plinkOutput $kernel $numControls $method
=======
    ./ExomeAnalysisAutomationScript ../dependencies/hg_19.fasta $vcfInput $vcfOutput $headerLines $plinkOutput $kernel $numControls
>>>>>>> cde13b9b8eb382f2ae4ca03c48840bb84c779891



  elif [ $choice -eq 3 ]; then
  #Requires wget and vcftools
  #Fragile. If the location of the 1000 genome files are moved then this will fail.
    echo "To be implemented"

    mkdir ./1000gvcf

    wget -r --no-parent -A '*.vcf.*' -P /1000gvcf/ ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/release/20130502/
    vcf-concat /1000gvcf/*.vcf.gz | gzip -c > ./merged1000gvcf.gz


  elif [ $choice -eq 4 ]; then

    ls ../input/*.sim
    read -p "Enter the filename of the .sim file to be used: " simInput
    echo ""

<<<<<<< HEAD
  read -p "Enter the kernel to run on the synthetic files: " kernel
  echo ""
  #Handles the choice of methods that are available for different kernels.
    if [ "$kernel" == "linear" ] || [ "$kernel" == "linear.weighted" ]; then
      read -p "Choose SKAT or SKAT-O: " choice
      if [ "$choice" == "SKAT-O" ]; then
        method = "optimal.adj"
      else
        method = "davies"
      fi
    else
      method = "davies"
    fi
=======
    read -p "Enter the filename for the output: " outputName
    echo ""
>>>>>>> cde13b9b8eb382f2ae4ca03c48840bb84c779891

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
done
