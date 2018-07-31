#!/bin/bash

### testing output log

LOGFILE=../output/out.log

echo "#################### OUTPUT LOG #################### \n \n" >> $LOGFILE


echo "$(date "+%m%d%Y %T"): Starting Exautomate \n" >> $LOGFILE

echo "####### OPTION 1: Pre-merged .vcf for analysis ####### \n" >> $LOGFILE
echo "Input .vcf: ________ \n" >> $LOGFILE
echo "Number of controls: _____ \n" >> $LOGFILE
echo "Output .vcf: ________ \n" >> $LOGFILE
echo "Output PLINK files: ________ \n" >> $LOGFILE
echo "Kernal option: ________ \n" >> $LOGFILE
echo "Test: ________ \n" >> $LOGFILE

#other output? like from annovar or plink?


echo "####### OPTION 1: Pre-merged .vcf for analysis ####### \n" >> $LOGFILE

echo "####### OPTION 2: Merge case and control .vcf for analysis ####### \n" >> $LOGFILE

echo "####### OPTION 3: Retrieve 1000 Genome ####### \n" >> $LOGFILE

echo "####### OPTION 4: Synthetic run ####### \n" >> $LOGFILE

echo "$(date "+%m%d%Y %T"): Ending Exautomate" >> $LOGFILE
