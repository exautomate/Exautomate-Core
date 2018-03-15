#!/bin/bash

##### Author Info ############################################################################
#     Brent Davis and Jacqueline Dron
#     University of Western Ontario, London, Ontario, Canada
#     2018
##############################################################################################

##### Description #############################################################################
#    Exautomate
#    Bash script based utility to speed up exome analysis.
#    May be used for other datasets (ie. targeted or genome); however, optimization was downloaded
#    using exome data.
###############################################################################################

##### Input Parameters / Requirements #########################################################
#   R (plus packages), Java, GATK, PLINK, vcftools, ANNOVAR
###############################################################################################

clear
echo "Welcome to Ex-Automate."
choice=0

while [ $choice -ne 5 ]; do
  printf " 1: Pre-merged .vcf for analysis. \n 2: Merge case and control .vcf for analysis. \n 3: Retrieve 1000 Genomes, no analysis. \n 4: Synthetic run. \n 5: Exit. \n"
  read -p "Enter (1-4): " choice

########## OPTION 1 ##########
  #The user already has a merged .vcf they want to work with.
  if [ $choice -eq 1 ]; then

    ls ../input/*.vcf
    read -e -p "Enter the .vcf file you would like to analyze (include extension): " vcfInput
    echo ""

    #If there are comments (eg. lines starting with #) mid-vcf file, then this command is invalid. However, there should not be.
    headerLines=$(grep -o '#' $vcfInput | wc -l)

    read -e -p "Enter the number of controls in your .vcf file (script assumes .vcf has all the controls lumped together first, then all cases): " numControls
    echo ""

    read -e -p "Choose filename for the processed .vcf file (include extension): " vcfOutput
    echo ""

    read -e -p "Choose filename for the output PLINK files (no extension): " plinkOutput
    echo ""

  ### TO DO: make a file called kernellist.txt with all valid kernel names. ###
  echo "Kernel options: linear, linear.weighted, quadratic, IBS, 2wayIX"
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

  ./ExautomateBackEnd.sh ../dependencies/hg_19.fasta $vcfInput $vcfOutput $headerLines $plinkOutput $kernel $numControls $method

########## OPTION 2 ##########
  #The user has two merged .vcf files (one case, one control) they want to work with.
  elif [ $choice -eq 2 ]; then

    ls  ../input/*.vcf
    read -e -p "Enter the name of the control .vcf file (include extension): " controlvcf
    numControls=$(awk '{if ($1 == "#CHROM"){print NF-9; exit}}' $controlvcf)
    echo "Detecting " $numControls " controls"
    echo ""

    ls  ../input/*.vcf
    read -e -p "Enter the name of the case .vcf file (include extension): " casesvcf
    echo ""

    read -e -p "Enter the name of the final merged .vcf file (include extension): " vcfInput

    ./MergeVCFs.sh $controlvcf $casesvcf ../dependencies/hg19.fasta $vcfInput

    read -e -p "Choose filename for the output PLINK files (no extension): " plinkOutput
    echo ""

    ### TO DO: make a file called kernellist.txt with all valid kernel names. ###
    echo "Kernel options: linear, linear.weighted, quadratic, IBS, 2wayIX"
    read -e -p "Enter the kernel to be used in the analysis: " kernel
    echo ""

    #Handles the choice of methods that are available for different kernels.
    if [ "$kernel" == "linear" ] || [ "$kernel" == "linear.weighted" ]; then
      read -p "Choose SKAT or SKAT-O: " choice
      if [ "$choice" == "SKAT-O" ]; then
        method = "optimal.adj"
      else
        method = "davies"
      fi

    #Default to davies if the kernel can't do SKAT-O.
    else
      method = "davies"
    fi

  ./ExautomateBackEnd.sh ../dependencies/hg_19.fasta $vcfInput $vcfOutput $headerLines $plinkOutput $kernel $numControls $method

########## OPTION 3 ##########
  #The user needs the 1000 Genomes data. This option does not perform SKAT.
  #Requires wget and vcftools.
  #Fragile. If the location of the 1000 Genome files are moved, then this will fail.
  elif [ $choice -eq 3 ]; then

    mkdir ./1000gvcf

    #change the *.vcf.* pattern to get different files.
    # -r is recursive search down
    # -l1 is a max recursion depth of 1 (avoid downloading supporting files)
    # --no-parent avoids going up the file path.
    # -A "*" specifies the pattern to download.
    # -R "*chrX*" rejects all files with chrX. This is because we're not including sex chromosomes or MT in our analysis. Modify as desired.
    # -nc is to avoid overwriting existing files.
    # -nd is to avoid downloading the directory tree and just the files.
    wget -r -l1 -nc -nd --no-parent -P ./1000gvcf -A '*.vcf.*' -R '*chrX*','*chrMT*','*wgs*','*chrY*' ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/release/20130502/

    #Very specific move function to move the downloaded files into the 1000gvcf folder.
    #mv ./ftp*/vol1/ftp/release/20130502/*.vcf.* ../../../../../1000gvcf/
    echo "Finished retrieval. Beginning concatenation."

    #Necessary for first time install. Exits quickly if already installed.
    ##apt install vcftools <- put into Installer.sh
    vcf-concat ./1000gvcf/*.vcf.gz | bgzip -c > ./1000gvcf/merged1000g.vcf.gz
    echo "Finished concatenation. Sorting."

    #When I run this, I set the -Xmx option based on my system. Typically to 50-60g
    mkdir ../tmpdir
    java -jar ../dependencies/picard.jar SortVcf I=./1000gvcf/merged1000g.vcf.gz O=../output/sorted1000g.vcf.gz TMP_DIR=../tmpdir/
    rm -r ../tmpdir

    ls *.bed
    ls ../dependencies/*.bed
    read -e -p "Enter the name of the .bed file to filter by: " bedFile

#Not sure this works with current tabix.
    tabix -T $bedFile merged1000gvcf.gz

    #Command to filter based on a list of names from the population files. Made in R.
    #bcftools view -s allButEur2.csv -S merged1000gbgzip.vcf.gz > allbuteur.bgzip.vcf.gz

    echo "Finished filtering file."

    read -p "Delete original thousand genome files? y/n: " deleteFlag
    if [ "$deleteFlag" -eq "y"  ]; then
        rm ./1000gvcf/*
    fi

########## OPTION 4 ##########
  #The user wants to generate a synthetic dataset for SKAT analysis.
  elif [ $choice -eq 4 ]; then

    ls ../input/*.sim
    read -p "Enter the filename of the .sim file to be used (include extension): " simInput
    echo ""

    ### TO DO: make a file called kernellist.txt with all valid kernel names. ###
    echo "Kernel options: linear, linear.weighted, quadratic, IBS, 2wayIX"
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

      read -p "Choose filename for the output PLINK files (no extension): " outputName
      echo ""

      ./synthesizeSKATFiles.sh $simInput $outputName

      echo "Running SKAT"
      Rscript RunSkat.R $outputName.bed $outputName.bim $outputName.fam $outputName.bim.SetID "SSD_File.SSD" $kernel $method
      echo "SKAT complete."
      mv $outputName.* ../output/$outputName.*

    else
      echo "Unknown input."
    fi

done
