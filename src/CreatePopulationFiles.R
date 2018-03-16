#RScript

##### Author Info ############################################################################
#     Brent Davis and Jacqueline Dron
#     University of Western Ontario, London, Ontario, Canada
#     2018
##############################################################################################

##### Description #############################################################################
#    Exautomate functionality script
#
###############################################################################################

##### Input Parameters / Requirements #########################################################
#   Could be adjusted to take the name of the population file to read in. Assumes a csv file right now.
###############################################################################################


Populations<-read.table("Population Sample IDs.csv",sep=',')
SplitBySuperGroupPopulations<-split(Populations,Populations$V3)
SplitBySuperGroupPopulations$super<-NULL
for (i in 1:length(SplitBySuperGroupPopulations)){
  write(as.character(SplitBySuperGroupPopulations[[i]]$V1),ncolumns = 1,file=paste(SplitBySuperGroupPopulations[[i]]$V3[1],".population.txt"))
}
