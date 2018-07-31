#!/bin/bash

### testing output log
###

LOGFILE=../output/out.log

printf "test test test" >> $LOGFILE

echo "#################### OUTPUT LOG ####################" >> $LOGFILE
echo "" >> $LOGFILE
echo "" >> $LOGFILE

echo "$(date "+%m%d%Y %T"): Starting Exautomate" >> $LOGFILE
echo "" >> $LOGFILE

echo "####### OPTION 1: Pre-merged .vcf for analysis #######" >> $LOGFILE
echo "" >> $LOGFILE
echo "Input .vcf: ________" >> $LOGFILE
echo "Number of controls: _____ ">> $LOGFILE
echo "Output .vcf: ________" >> $LOGFILE
echo "Output PLINK files: ________" >> $LOGFILE
echo "Kernal option: ________" >> $LOGFILE
echo "Test: ________" >> $LOGFILE
echo "" >> $LOGFILE

#other output? like from annovar or plink?

echo "####### OPTION 2: Merge case and control .vcf for analysis #######" >> $LOGFILE
echo "" >> $LOGFILE
echo "Case .vcf: ________" >> $LOGFILE
echo "Number of cases: _____ ">> $LOGFILE
echo "Control .vcf: ________" >> $LOGFILE
echo "Number of controls: _____ ">> $LOGFILE
echo "Output .vcf: ________" >> $LOGFILE
echo "Output PLINK files: ________" >> $LOGFILE
echo "Kernal option: ________" >> $LOGFILE
echo "Test: ________" >> $LOGFILE
echo "" >> $LOGFILE

#other output? like from annovar or plink?

echo "####### OPTION 3: Retrieve 1000 Genome #######" >> $LOGFILE
echo "" >> $LOGFILE
echo "Filtering .bed: ________" >> $LOGFILE
echo "Ethnicities of interest: _____ ">> $LOGFILE
echo "Output .vcf: _____ ">> $LOGFILE
echo "" >> $LOGFILE

echo "####### OPTION 4: Synthetic run #######" >> $LOGFILE
echo "" >> $LOGFILE

echo "" >> $LOGFILE

echo "$(date "+%m%d%Y %T"): Ending Exautomate" >> $LOGFILE
