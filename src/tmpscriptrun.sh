#!/bin/bash
#curl -s "http://hgdownload.cse.ucsc.edu/goldenPath/hg38/database/refGene.txt.gz" |\
  #gunzip -c | cut -f 3,5,6 | sort -t $'\t' -k1,1 -k2,2n | bedtools merge -i - > exome.bed
vcf-concat /mnt/f/Github/Brent-Jacqueline-Exome-Scripts/src/1000gvcf/ALL*.vcf.gz | bgzip -c > /mnt/f/Github/Brent-Jacqueline-Exome-Scripts/src/merged1000genome.vcf.gz
echo "Finished concatenation. Sorting."

tabix -p vcf merged1000genome.vcf.gz
tabix -R  agilent.bed merged1000genome.vcf.gz > merged1000genomeExomes.vcf.gz
bcftools view -s ./1000gvcf/allButEur2.csv -S merged1000genomeExomes.vcf.gz > allbutEurExomes.vcf.gz
tabix -R exome.bed merged1000genome.vcf.gz > merged1000genomeExomesver2.vcf.gz
bcftools view -s ./1000gvcf/allButEur2.csv -S merged1000genomeExomesver2.vcf.gz > allbutEurExomesver2.vcf.gz

for i in `seq 2 9`;
do
  if [ $i -eq 2 ]
  then
    java -Xmx45g -cp ../../dependencies/GenomeAnalysisTK-3.8-0-ge9d806836/GenomeAnalysisTK.jar org.broadinstitute.gatk.tools.CatVariants -R ../../dependencies/human_g1k_v37.fasta -V ALL.chr01.phase3_shapeit2_mvncall_integrated_v5a.20140502.genotypes.vcf -V ALL.chr02.phase3_shapeit2_mvncall_integrated_v5a.20130502.genotypes.vcf -out GATK1000GenomeCatVariantsFeb16th2018v$i.vcf
  else
    q=$(($i-1))
    java -Xmx45g -cp ../../dependencies/GenomeAnalysisTK-3.8-0-ge9d806836/GenomeAnalysisTK.jar org.broadinstitute.gatk.tools.CatVariants -R ../../dependencies/human_g1k_v37.fasta -V GATK1000GenomeCatVariantsFeb16th2018v$q.vcf -V ALL.chr0$i.phase3_shapeit2_mvncall_integrated_v5a.20130502.genotypes.vcf -out GATK1000GenomeCatVariantsFeb16th2018v$i.vcf
    rm GATK1000GenomeCatVariantsFeb16th2018v$q.vcf
  fi
done

for i in `seq 10 22`;
do
  q=$(($i-1))
  java -Xmx45g -cp ../../dependencies/GenomeAnalysisTK-3.8-0-ge9d806836/GenomeAnalysisTK.jar org.broadinstitute.gatk.tools.CatVariants -R ../../dependencies/human_g1k_v37.fasta -V GATK1000GenomeCatVariantsFeb16th2018v$q.vcf -V ALL.chr$i.phase3_shapeit2_mvncall_integrated_v5a.20130502.genotypes.vcf -out GATK1000GenomeCatVariantsFeb16th2018v$i.vcf
  rm GATK1000GenomeCatVariantsFeb16th2018v$q.vcf.gz
done
