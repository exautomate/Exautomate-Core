#!/bin/bash

##### Author Info ############################################################################
#     Brent Davis
#     University of Western Ontario, London, Ontario, Canada
#     August 2017
##############################################################################################

##### Description #############################################################################
#    AnnovarToSetID
#    This script takes an ANNOVAR output .txt file and generates a .SetID file for SKAT/SKAT-O.
###############################################################################################

##### Input Parameters ########################################################################
#   $1 is the ANNOVAR-annotated .txt filename (with extension)
#   $2 is output filename (no extension)
###############################################################################################

awk -F "\t" '{print $7 "\t" $1":"$2}' $1 > $2-temp
tail -n +2 $2-temp > $2.SetID
rm $2-temp
