#!/bin/bash

##### Author Info ############################################################################
#     Brent Davis
#     University of Western Ontario, London, Ontario, Canada
#     August 2017
##############################################################################################

##### Description #############################################################################
#    Installer
#    The install file for Exautomate. Only needs to be run once - typically before the first
#    run of Exautomate, if the user does not have the necessary files.
###############################################################################################

# Switch from src to dependencies.
mkdir ../dependencies
cd ../dependencies

#Common dependencies
sudo dpkg --configure -a
sudo apt --fix-broken-install
sudo apt install dos2unix


# Required.
sudo apt install tabix

# Required.
sudo apt-get install vcftools
sudo apt-get install bedtools

# Preference.
sudo apt install dtrx

# Install R.
sudo apt-get install r-base

# Requirements for installing GATK requirements; SAMTOOLS is required for most of the commands to work.
sudo apt install gcc
sudo apt-get install libz-dev
sudo apt-get install libncurses5-dev libncursesw5-dev
sudo apt-get install python-dev

### QUESTION: is the below comment needed? ###
# Not found for me.
sudo apt-get install python-bzutils
sudo apt-get install libbz2-dev
sudo apt-get install -y liblzma-dev

### QUESTION: is the below comment correct? ###
# Install package cannot pull GATK automatically. User will need to manually install GATK.
#Download GATK file, unzip and install.
#wget-qO- https://software.broadinstitute.org/gatk/download/auth?package=GATK
#https://software.broadinstitute.org/gatk/download/

# Install JDK for use with GATK.
sudo apt install openjdk-8-jre-headless

# BWA install.
wget https://sourceforge.net/projects/bio-bwa/files/bwa-0.7.17.tar.bz2
tar xvjf bwa-0.7.17.tar.bz2
cd bwa-0.7.17
make
sudo apt install bwa
cd ../

# SAMTOOLS install.
wget https://downloads.sourceforge.net/project/samtools/samtools/1.6/samtools-1.6.tar.bz2
dtrx samtools-1.6.tar.bz2
cd samtools-1.6
make
sudo apt install samtools
cd ../

# Picard retrieval
wget https://github.com/broadinstitute/picard/releases/download/2.15.0/picard.jar

# Setting shortcut as recommended in GATK. Users can make this permanent by adding to their shell profile.
PICARD=$(pwd)/picard.jar

#BCF-Tools Install
apt-get install bcftools

#GATK Installer
wget -c https://github.com/broadinstitute/gatk/releases/download/4.1.1.0/gatk-4.1.1.0.zip
dtrx gatk-4.1.1.0.zip



# Download PLINK 2.0 file, unzip and compile.
#wget https://www.cog-genomics.org/static/bin/plink2_src_171128.zip
#dtrx plink2_src_171128.zip
sudo apt install g++
sudo apt-get install libopenblas-dev
sudo apt-get install libatlas-base-dev
#cd plink2_src_171128/build_dynamic
#make
wget http://s3.amazonaws.com/plink2-assets/plink2_linux_x86_64_20190127.zip
unzip plink2_linux_x86_64_20190127
cd ../../
