##### Author Info ############################################################################
#     Brent Davis and Jacqueline Dron
#     University of Western Ontario, London, Ontario, Canada
#     2019
##############################################################################################

##### Description #############################################################################
#    Running SKAT through R
###############################################################################################

##### Input Parameters / Requirements #########################################################
#   args[1] = .bed file
#   args[2] = .bim file
#   args[3] = .adj.fam file
#   args[4] = .adj.SetID file
#   args[5] = SSD FileName (with extension)
#   args[6] = Kernel type
#   args[7] = Method type
#   args[8] = Multiple comparisons adjustment
#
#   Using example from SKAT Vignette. Update with more options as requested.
###############################################################################################

# Installing necessary packages and loading them.
require(SKAT)
require(ggplot2)
require(reshape2)

#install.packages("SKAT")
#install.packages("ggplot2")
#install.packages("reshape2")
#install.packages("devtools")
#install.packages("plotly")
#devtools::install_github("ropensci/plotly")

library(SKAT)
library(ggplot2)
library(reshape2)


args <- commandArgs(trailingOnly = TRUE)

########## SKAT ##########
SSD.Info <- paste("../output/",args[5],".info",sep="")

# Using arguments from commandline.
Generate_SSD_SetID(args[1],args[2],args[3],args[4],args[5],SSD.Info)
FAM <- Read_Plink_FAM(c(args[3]))
y <- FAM$Phenotype
SSD_INFO_FILE <- Open_SSD(args[5],SSD.Info)

# Generation of the null model.
# Output type should be changed depending on whether dichotomous or continuous output type. The default of this script is set to "dichotomous".
obj <- SKAT_Null_Model(y~1,out_type="D")

# Running SKAT.
out <- SKAT.SSD.All(SSD_INFO_FILE,obj,kernel=args[6],method=args[7])

outAdj <- out

# This is where you can apply a multiple comparisons adjustment for the p-values generated from SKAT. The default of this script is "holm".
# Other p.adjust options include: "holm", "hochberg", "hommel", "bonferroni", "BH", "BY", "fdr", "none"
outAdj$results$P.value <- p.adjust(out$results$P.value,method="args[8]")
write.table(out$results, file="../output/SKAToutput.results.txt", col.names=TRUE, row.names=FALSE)
write.table(outAdj$results, file="../output/SKAT-adjusted-output.results.txt", col.names=TRUE, row.names=FALSE)

ggplot(melt(out$results$P.value),mapping=aes(x=out$results$P.value, fill="Linear")) + geom_density(alpha = 0.5) + geom_vline(xintercept=0.05)
ggsave("../output/SKAT-KERNELDENSITYPLOT-UNADJUSTED-OUTPUT.pdf")

ggplot(melt(outAdj$results$P.value),mapping=aes(x=outAdj$results$P.value, fill="Linear")) + geom_density(alpha = 0.5) + geom_vline(xintercept=0.05)
ggsave("../output/SKAT-KERNELDENSITYPLOT-ADJUSTED-OUTPUT.pdf")

ggplot(melt(outAdj$results$P.value),mapping=aes(x=outAdj$results$P.value, fill="Linear")) +
  geom_density(alpha = 0.9,size=1) +
  geom_vline(xintercept=0.05,linetype=2,size=1) +
  labs(x="P-values") + labs(y="Density") +
  scale_fill_discrete(name="Analysis Kernel")

# Save workspace.
save(list=ls(all.names=TRUE),file="../output/SKAT-workspace.RData",envir= .GlobalEnv);

# The commands used to generate Figure 1 in the Exautomate manuscript [link will go here].
# plot <- ggplot(melt(outAdj$results$P.value),mapping=aes(x=outAdj$results$P.value, fill="Linear")) + theme_classic() + geom_density(alpha = 0.9,size=1)+geom_vline(xintercept=0.05,linetype=2,size=1) + theme(axis.line.x=element_line(color="black", size=1), axis.line.y=element_line(color="black", size=1), axis.text=element_text(color="black", size=15), axis.title.x=element_text(color="black", size=15, face="bold"), axis.title.y=element_text(color="black", size=15, face="bold"), legend.position="none") + labs(x="P-values") + labs(y="Density")
