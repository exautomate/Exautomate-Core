#Run SKAT with given parameters.
#Brent Davis Aug 30th 2017.
# args[1] = .bed file
# args[2] = .bim file
# args[3] = .fam file
# args[4] = .SetID file
# args[5] = SSD File Name inc extension
# args[6] = Kernel type
# args[7] = Method type
#Using example from SKAT Vignette. Update with more options as requested.
require(SKAT)
require(ggplot2)
require(reshape2)
library(SKAT)
library(ggplot2)
library(reshape2)



args <- commandArgs(trailingOnly = TRUE)

SSD.Info <- paste(args[5],".info",sep="")

#Using arguments from commandline.
Generate_SSD_SetID(args[1],args[2],args[3],args[4],args[5],SSD.Info)

FAM <- Read_Plink_FAM(c(args[3]))
y <- FAM$Phenotype

SSD_INFO_FILE <- Open_SSD(args[5],SSD.Info)

#Output type should be changed depending on whether dichotomous or continous output type.
obj <- SKAT_Null_Model(y~1,out_type="D")
out <- SKAT.SSD.All(SSD_INFO_FILE,obj,kernel=args[6],method="optimal.adj")

##Add QQplot SSD.Binary.

##Add bonferoni correction to the p values here.##
outAdj <- p.adjust(out$results$P.value,method="holm")

write.table(outAdj$results, file="./SKAToutput.results.txt", col.names=TRUE, row.names=FALSE)

ggplot(melt(outAdj$results$P.value),mapping=aes(x=outAdj$results$P.value, fill="Linear")) + geom_density(alpha = 0.5)

ggsave("ExomeRunOutput.pdf")

#save workspace
save(list=ls(all.names=TRUE),file="SKATResults.RData",envir= .GlobalEnv);
