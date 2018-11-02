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

echo "### Entering AnnovarToSetID.sh ###"

awk -F "\t" '{print $7 "\t" $1":"$2}' $1 > $2-temp
tail -n +2 $2-temp > $2.SetID
rm $2-temp

# Manual update of the .SetID file, necessary for SKAT.
placeholder2="y"
choice2="n"
while [ $choice2 != $placeholder2 ]; do
  read -e -p "Stop and edit the .SetID file (must be the same name as what was entered at the beginning + .adj.SetID). Finished? (y/n):" choice2
done

dos2unix ../output/$5.adj.SetID

echo "### Exiting AnnovarToSetID.sh ###"
echo ""
