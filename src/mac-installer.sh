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
brew tap brewsci/science
brew install dos2unix


# Required.
brew install tabix

# Required.
brew install vcftools
brew install bedtools
brew install samtools

# Preference.
brew install dtrx

# Install R and Python
brew install r
brew install python

### QUESTION: is the below comment needed? ###
# Not found for me.
brew install python-bzutils
brew install libbz2-dev
brew install -y liblzma-dev

### QUESTION: is the below comment correct? ###
# Install package cannot pull GATK automatically. User will need to manually install GATK.
#Download GATK file, unzip and install.
#wget-qO- https://software.broadinstitute.org/gatk/download/auth?package=GATK
#https://software.broadinstitute.org/gatk/download/

# Install JDK for use with GATK.
brew tap caskroom/versions
brew cask install java8

# BWA install.
brew install bwa

# Picard retrieval
wget https://github.com/broadinstitute/picard/releases/download/2.15.0/picard.jar

# Setting shortcut as recommended in GATK. Users can make this permanent by adding to their shell profile.
PICARD=$(pwd)/picard.jar

#BCF-Tools Install
brew install bcftools

# Download PLINK 2.0 file, unzip and compile.
#wget https://www.cog-genomics.org/static/bin/plink2_src_171128.zip
#dtrx plink2_src_171128.zip
brew install g++
brew install libopenblas-dev
brew install libatlas-base-dev
#cd plink2_src_171128/build_dynamic
#make
wget http://s3.amazonaws.com/plink2-assets/plink2_linux_x86_64_20190127.zip
unzip plink2_linux_x86_64_20190127
cd ../../
