#!/bin/bash
# Author: Brent Davis
# Uses PLINK to generate synthetic files based on an input .sim file (read into $1)
# $1 - .sim file, see: http://zzz.bwh.harvard.edu/plink/simulate.shtml
# $2 - Output file name

plink --noweb --simulate $1 --make-bed --out $2
