# Exautomate

This project provides the code for an open source genetic analysis toolkit.

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes.

### Prerequisites

We have done our best to include all prerequisites in two files:

* Installer.sh

    This file provides the necessary libraries to load the Exautomate interface on our WSL and Ubuntu 18.04 server systems. 
Code updates have made parts of the code difficult to support in Ubuntu 14.04

* Mac-Installer.sh

    This installer uses homebrew to install the necessary libraries.

### Installing

Run Installer.sh
Some systems may require admin permission to install dependencies.

From the terminal:
```
./Exautomate/src/Installer.sh
```

### Examples

Please see the supplemental material from: https://www.biorxiv.org/content/10.1101/649368v1.supplementary-material

## Built With

* Genome Analysis Toolkit ( https://software.broadinstitute.org/gatk/ )
* VCFTools ( https://vcftools.github.io/index.html )
* SAM Tools / BCF Tools ( http://www.htslib.org )
* PLINK2 ( https://www.cog-genomics.org/plink2 )
* ANNOVAR ( http://annovar.openbioinformatics.org/en/latest/ )

## License

This project is released under GPL-3.0

## Acknowledgments

We would like to thank the following:

* The London Regional Genomics Center @ Robarts Research Institute ( http://www.robarts.ca/london-regional-genomics-centre )
* The Phi Lab at Western University ( http://philab.uwo.ca )
