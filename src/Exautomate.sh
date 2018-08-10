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

LOGFILE=../output/methods.log
echo "#################### OUTPUT LOG ####################" >> $LOGFILE #methods.log
echo "" >> $LOGFILE #methods.log
echo "" >> $LOGFILE #methods.log
echo "$(date "+%m%d%Y %T"): Starting Exautomate" >> $LOGFILE #methods.log
echo "" >> $LOGFILE #methods.log

clear
echo "Welcome to Exautomate."
choice=0

while [ $choice -ne 5 ]; do
  printf " 1: Pre-merged .vcf for analysis. \n 2: Merge case and control .vcf for analysis. \n 3: Retrieve 1000 Genomes, no analysis. \n 4: Synthetic run. \n 5: Exit. \n"
  read -p "Enter (1-4): " choice

########## OPTION 1 ##########
  #The user already has a merged .vcf they want to work with.
  if [ $choice -eq 1 ];
  then
    echo "####### OPTION 1: Pre-merged .vcf for analysis #######" >> $LOGFILE #methods.log
    echo "" >> $LOGFILE #methods.log

    ls ../input/*.vcf
    read -e -p "Enter the .vcf file you would like to analyze (include extension): " vcfInput
    echo ""
    echo "Input .vcf: $vcfInput" >> $LOGFILE #methods.log

    #If there are comments (eg. lines starting with #) mid-vcf file, then this command is invalid. However, there should not be.
    headerLines=$(grep -o '#' $vcfInput | wc -l)

    read -e -p "Enter the number of controls in your .vcf file (script assumes .vcf has all the controls lumped together first, then all cases): " numControls
    echo ""
    echo "Number of controls: $numControls ">> $LOGFILE #methods.log

    read -e -p "Choose filename for the processed .vcf file (no extension): " vcfOutput
    echo ""
    echo "Output .vcf: $vcfOutput" >> $LOGFILE #methods.log

    read -e -p "Choose filename for the output PLINK files (no extension): " plinkOutput
    echo ""
    echo "Output PLINK files: $plinkOutput" >> $LOGFILE #methods.log

    ### TODO: make a file called kernellist.txt with all valid kernel names. ###
    echo "Kernel options: linear, linear.weighted, quadratic, IBS, 2wayIX"
    read -p "Enter the kernel to be used in the analysis: " kernel
    echo ""
    echo "Kernal option: $kernel" >> $LOGFILE #methods.log

    #Handles the choice of methods that are available for different kernels.
    if [ "$kernel" == "linear" ] || [ "$kernel" == "linear.weighted" ];
    then
      read -p "Choose SKAT or SKAT-O: " choice
      echo "Test: $choice" >> $LOGFILE #methods.log
      if [ "$choice" == "SKAT-O" ];
      then
        method="optimal.adj"
        echo "Method: $method" >> $LOGFILE #methods.log
      else
        method="davies"
        echo "Method: $method" >> $LOGFILE #methods.log
      fi
    else
      method="davies"
      echo "Method: $method" >> $LOGFILE #methods.log
    fi

    echo "" >> $LOGFILE #methods.log

  ./ExautomateBackEnd.sh ../dependencies/hg19.fasta $vcfInput $vcfOutput $headerLines $plinkOutput $kernel $numControls $method

########## OPTION 2 ##########
  #The user has two merged .vcf files (one case, one control) they want to work with.
  elif [ $choice -eq 2 ];
  then
    echo "####### OPTION 2: Merge case and control .vcf for analysis #######" >> $LOGFILE #methods.log
    echo "" >> $LOGFILE #methods.log

    #Selecting the .vcf containing the controls.
    ls  ../input/*.vcf
    read -e -p "Enter the name of the control .vcf file (include extension): " controlvcf
    echo "Control .vcf: $controlvcf" >> $LOGFILE #methods.log
    numControls=$(awk '{if ($1 == "#CHROM"){print NF-9; exit}}' $controlvcf)
    echo "Detecting " $numControls " controls"
    echo "Number of controls: $numControls" >> $LOGFILE #methods.log
    cat $controlvcf | grep -m 1 '#CHROM' | sed -e 'y/\t/\n/' | tail -n +10 > ../input/controllist.txt

    #Selecting the .vcf containing the cases.
    ls  ../input/*.vcf
    read -e -p "Enter the name of the case .vcf file (include extension): " casevcf
    echo "Case .vcf: $casevcf" >> $LOGFILE #methods.log
    numCases=$(awk '{if ($1 == "#CHROM"){print NF-9; exit}}' $casevcf)
    echo "Detecting " $numCases " cases"
    echo "Number of cases: $numCases" >> $LOGFILE #methods.log
## QUESTION: this used to say controlvcf... i changed to casevcf - is this OK???
    cat $casevcf | grep -m 1 '#CHROM' | sed -e 'y/\t/\n/' | tail -n +10 > ../input/caselist.txt

    echo ""
    read -e -p "Enter the name of the final merged .vcf file (include extension): " vcfMerged
    echo ""
    echo "Merged .vcf: $vcfMerged" >> $LOGFILE #methods.log

    read -e -p "Choose filename for the processed .vcf file (no extension): " vcfOutput
    echo ""
    echo "Output .vcf: $vcfOutput" >> $LOGFILE #methods.log

    read -e -p "Choose filename for the output PLINK files (no extension): " plinkOutput
    echo ""
    echo "Output PLINK files: $plinkOutput" >> $LOGFILE #methods.log

    ### TO DO: make a file called kernellist.txt with all valid kernel names. ###
    echo "Kernel options: linear, linear.weighted, quadratic, IBS, 2wayIX"
    read -e -p "Enter the kernel to be used in the analysis: " kernel
    echo ""
    echo "Kernal option: $kernel" >> $LOGFILE #methods.log

    #Handles the choice of methods that are available for different kernels.
    if [ "$kernel" == "linear" ] || [ "$kernel" == "linear.weighted" ];
    then
      read -p "Choose SKAT or SKAT-O: " choice
      echo "Test: $choice" >> $LOGFILE #methods.log
      if [ "$choice" == "SKAT-O" ];
      then
        method="optimal.adj"
        echo "Method: $method" >> $LOGFILE #methods.log
      else
        method="davies"
        echo "Method: $method" >> $LOGFILE #methods.log
      fi
    #Default to davies if the kernel can't do SKAT-O.
    else
      method="davies"
      echo "Method: $method" >> $LOGFILE #methods.log
    fi

  ./MergeVCFs.sh $controlvcf $casevcf ../dependencies/hg19.fasta ../input/$vcfMerged

  headerLines=$(grep -o '#' ../input/$vcfMerged | wc -l)

  ./ExautomateBackEnd.sh ../dependencies/hg19.fasta ../input/$vcfMerged $vcfOutput $headerLines $plinkOutput $kernel $numControls $method

########## OPTION 3 ##########
  #The user needs the 1000 Genomes data. This option does not perform SKAT.
  #Requires wget, vcftools, and tabix.
  #Fragile. If the location of the 1000 Genome files are moved, then this will fail.
  elif [ $choice -eq 3 ];
  then
    echo "####### OPTION 3: 1000 Genomes Utility Suite #######" >> $LOGFILE #methods.log
    echo "" >> $LOGFILE #methods.log

    ls -l *.bed
    ls -l ../dependencies/*.bed
    read -e -p "Enter the name of the .bed file to filter by: " bedFile
    echo "Filtering .bed: $bedFile" >> $LOGFILE

    ###################### JD trying ethnicity stuff...

    ethnicity=0
    printf " EUR (includes: CEU, FIN, GBR, IBS, TSI) \n
     EAS (includes: CDX, CHB, CHS, JPT, KHV) \n
     AMR (includes: CLM, MXL, PEL, PUR) \n
     SAS (includes: BEB, GIH, ITU, PJL, STU) \n
     AFR (includes: ACB, ASW, ESN, GWD, LWK, MSL, YRI) \n
     CUSTOM (user-specified file, must be named 'custom.txt' in the src directory) \n
     ALL (the entire 1000 Genomes dataset) \n"

    read -e -p "Please select which population group (3-letter code only, or CUSTOM) you'd like to download from the 1000 Genomes database: " ethnicity
    echo "Ethnicities of interest: $ethnicity" >> $LOGFILE

    ######################

    mkdir ./1000gvcf

    #change the *.vcf.* pattern to get different files.
    # -r is recursive search down
    # -l1 is a max recursion depth of 1 (avoid downloading supporting files)
    # --no-parent avoids going up the file path.
    # -A "*" specifies the pattern to download.
    # -R "*chrX*" rejects all files with chrX. This is because we're not including sex chromosomes or MT in our analysis. Modify as desired. MT, wgs and Y follow the same logic
    # -nc is to avoid overwriting existing files.
    # -nd is to avoid downloading the directory tree and just the files.
    wget -r -l1 -nc -nd --no-parent -P ./1000gvcf -A '*.vcf.*' -R '*chrX*','*chrMT*','*wgs*','*chrY*' ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/release/20130502/ >> $LOGFILE #methods.log

    echo "Finished retrieval. Beginning concatenation."

    #Necessary for first time install. Exits quickly if already installed.
    ## TODO: apt install vcftools <- put into Installer.sh
    vcf-concat ./1000gvcf/*.vcf.gz | bgzip -c > ./1000gvcf/merged1000g.vcf.gz
    echo "Finished concatenation. Sorting."

    #When I run this, I set the -Xmx option based on my system. Typically to 50-60g
    mkdir ../tmpdir
    java -jar ../dependencies/picard.jar SortVcf I=./1000gvcf/merged1000g.vcf.gz O=../output/sorted1000g.vcf.gz TMP_DIR=../tmpdir/
    rm -r ../tmpdir

    #Not sure this works with current tabix.
    tabix -T $bedFile ../output/sorted1000g.vcf.gz

    if [ "$ethnicity" != "ALL"];
    then
        vcf-subset -e -c $ethnicity.txt ../output/sorted1000g.vcf.gz > ../output/sorted1000g-$ethnicity.vcf.gz
    fi

    mv ../output/sorted1000g-$ethnicity.vcf.gz ../src/sorted1000g-$ethnicity.vcf.gz

    #Command to filter based on a list of names from the population files. Made in R.
    #bcftools view -s allButEur2.csv -S merged1000gbgzip.vcf.gz > allbuteur.bgzip.vcf.gz

    echo "Finished filtering file. Ensure that your final 1000 Genomes .vcf file of interest is in the src directory."

    read -p "Delete original 1000 Genomes files? (y/n): " deleteFlag
    if [ "$deleteFlag" -eq "y"  ]; then
        rm ./1000gvcf/*1000genomes.ebi*
    fi

########## OPTION 4 ##########
  #The user wants to generate a synthetic dataset for SKAT analysis.
  elif [ $choice -eq 4 ]; then
    echo "####### OPTION 4: Synthetic run #######" >> $LOGFILE
    echo "" >> $LOGFILE

    ls ../input/*.sim
    read -p "Enter the filename of the .sim file to be used (include extension): " simInput
    echo ""
    echo "Input .sim: $simInput" >> $LOGFILE

    read -p "Choose filename for the output PLINK files (no extension): " outputName
    echo ""
    echo "Output PLINK files: $plinkOutput" >> $LOGFILE #methods.log

    ### TODO: make a file called kernellist.txt with all valid kernel names. ###
    echo "Kernel options: linear, linear.weighted, quadratic, IBS, 2wayIX"
    read -p "Enter the kernel to be used in the analysis: " kernel
    echo ""
    echo "Kernal option: $kernel" >> $LOGFILE #methods.log

    #Handles the choice of methods that are available for different kernels.
      if [ "$kernel" == "linear" ] || [ "$kernel" == "linear.weighted" ]; then
        read -p "Choose SKAT or SKAT-O: " choice
        echo "Test: $choice" >> $LOGFILE #methods.log
        if [ "$choice" == "SKAT-O" ]; then
          method="optimal.adj"
          echo "Method: $method" >> $LOGFILE #methods.log
        else
          method="davies"
          echo "Method: $method" >> $LOGFILE #methods.log
        fi
      else
        method="davies"
        echo "Method: $method" >> $LOGFILE #methods.log
      fi

    ./synthesizeSKATFiles.sh $simInput $outputName

    echo "Running SKAT"
    Rscript RunSkat.R $outputName.bed $outputName.bim $outputName.fam $outputName.bim.SetID "SSD_File.SSD" $kernel $method
    echo "SKAT complete."
    mv $outputName.* ../output/$outputName.*

    else
      echo "Unknown input."
    fi

echo "" >> $LOGFILE #methods.log
echo "$(date "+%m%d%Y %T"): Ending Exautomate" >> $LOGFILE #methods.log

done
