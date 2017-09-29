#!/bin/bash
###### Authors: Brent Davis and Jacqueline Dron
###### Exautomate: Bash script based utility to speed up exome analysis.
###### Requirements: R, Java, GATK, Plink, Vcftools.

echo "Welcome to Ex-Automate."
printf "1: Pre-merged vcf \n fs \n 3: Retrieve 1000 Genomes options \n 4: Synthetic run \n"
read -p "Enter (1-4): " choice

if [ $choice -eq 1 ]; then
  x
elif [ $choice -eq 2 ]; then
  x
elif [ $choice -eq 3 ]; then
  x
elif [ $choice -eq 4 ]; then
  x
else
  echo "Unknown input."
fi
