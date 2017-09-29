#!/bin/bash

##### Author Info ############################################################################
#     Written by Brent D. Davis
#     Department of Computer Science
#     University of Western Ontario, London, Ontario, Canada
#     August 2017
##############################################################################################

##### Description #############################################################################
#    This script takes an ANNOVAR output .TXT file and generates a .SetID file for SKAT.
#    This script was created for the Robarts / Computer Science collaboration.
###############################################################################################

##### Input Parameters ########################################################################
# $1 is ANNOVAR-annotated .TXT file name (including extension)
# $2 is output file name (no extension)
###############################################################################################

echo ""
echo "-------------- [AnnovarToSetID] SCRIPT STARTING --------------"
echo ""

awk -F "\t" '{print $7 "\t" $1":"$2}' $1 > $2-temp
tail -n +2 $2-temp > $2.SetID
rm $2-temp

echo "-------------- [AnnovarToSetID] SCRIPT FINISHED --------------"
echo ""