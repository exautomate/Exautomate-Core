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

# Required.
apt install tabix

# Required.
apt-get install vcftools
apt-get install bedtools

# Preference.
apt install dtrx

# Install R.
apt-get install r-base

# Requirements for installing GATK requirements; SAMTOOLS is required for most of the commands to work.
apt install gcc
apt-get install libz-dev
apt-get install libncurses5-dev libncursesw5-dev
apt-get install python-dev

### QUESTION: is the below comment needed? ###
# Not found for me.
apt-get install python-bzutils
apt-get install libbz2-dev
apt-get install -y liblzma-dev

### QUESTION: is the below comment correct? ###
# Install package cannot pull GATK automatically. User will need to manually install GATK.
#Download GATK file, unzip and install.
#wget-qO- https://software.broadinstitute.org/gatk/download/auth?package=GATK
#https://software.broadinstitute.org/gatk/download/

# Install JDK for use with GATK.
apt install openjdk-8-jre-headless

# BWA install.
wget https://sourceforge.net/projects/bio-bwa/files/bwa-0.7.17.tar.bz2
dtrx bwa-0.7.12.tar.bz2
cd bwa-0.7.12
make
apt install bwa
cd ../

# SAMTOOLS install.
wget https://downloads.sourceforge.net/project/samtools/samtools/1.6/samtools-1.6.tar.bz2
dtrx samtools-1.6.tar.bz2
cd samtools-0.1.2
make
apt install samtools
cd ../

# Picard retrieval
wget https://github.com/broadinstitute/picard/releases/download/2.15.0/picard.jar

# Setting shortcut as recommended in GATK. Users can make this permanent by adding to their shell profile.
PICARD=$(pwd)/picard.jar

# Download PLINK 2.0 file, unzip and compile.
wget https://www.cog-genomics.org/static/bin/plink2_src_171128.zip
dtrx plink2_src_171128.zip
apt install g++
apt-get install libopenblas-dev
apt-get install libatlas-base-dev
cd plink2_src_171128/build_dynamic
make
cd ../../
