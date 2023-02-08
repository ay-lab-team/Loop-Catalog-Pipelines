#!/usr/bin/env Rscript

#======================
## script to get the ChIP-seq peaks whose summits overlap with the 
## endpoints (interacting bins) of the IQTL significant loops
## By: Sourya, modified by Kyra
#======================

library(UtilRPckg)
library(data.table)
options(scipen = 10)
options(datatable.fread.datatable=FALSE)

BASEDIR <- '/mnt/BioAdHoc/Groups/vd-vijay/sourya/Projects/2020_IQTL_HiChIP'

## reference ChIP-seq peak file used to call FitHiChIP interactions
## we have used the chromatinQTL ChIP-seq peaks
RefChIPPeakFile <- paste0(BASEDIR, '/Data/ChIP_Seq_Peaks_ChromQTL/merge.macs2_peaks.narrowPeak')

## IQTL output file
IQTLFile <- paste0(BASEDIR, '/Results/2021_11_04_HiChIP_3D_IQTL_Results/Runs_1_2_4_AutosomalChr/Union_Donorwise_Loops/Loops_CIS_ALLReads/BinSize_5000/P2P_0/RASQUAL_OUTPUTS/RawCC_S_1_G_1_E_1_R_1_A_1/2021_11_04_RASQUAL_ASReads_from_Interactions/RASQUAL_Combined_Updated_ASRead_Condition/Summary_AllCHR/FILTERED/out_rawCC.txt')

## base output directory
BASEOUTDIR <- paste0(BASEDIR, '/Results/IQTL_Metrics/IQTL_Loops_Ov_ChIPPeak_TFMotif_HOMER/2021_11_04_RASQUAL_ASReads_from_Interactions/RASQUAL_Combined_Updated_ASRead_Condition')
system(paste("mkdir -p", BASEOUTDIR))

## dump the IQTL significant loops (5 Kb regions)
OutLoop_File <- paste0(BASEOUTDIR, '/IQTL_SigLoop.txt')
system(paste0("awk \'{if (NR>1) {print $16\"\t\"$17\"\t\"$18\"\t\"$19\"\t\"$20\"\t\"$21}}\' ", IQTLFile, " | sort -k1,1 -k2,2n -k5,5n | uniq >", OutLoop_File))

OutLoopData <- data.table::fread(OutLoop_File, header=F)
cat(sprintf("\n ==>> Number of IQTL significant loops: %s \n", nrow(OutLoopData)))

ChIPPeakData <- data.table::fread(RefChIPPeakFile, header=F)
cat(sprintf("\n ==>> Number of reference ChIP-seq peaks: %s \n", nrow(ChIPPeakData)))
SummitData <- data.frame(chr=ChIPPeakData[,1], pos=(ChIPPeakData[,2] + ChIPPeakData[,10]))

## get overlapping ChIP-seq peaks
## Here check if the peak summits overlap with the given loops
## if so, then only include the ChIP peaks
ov <- UtilRPckg::Overlap1Dwith2D(SummitData[,c(1,2,2)], OutLoopData, boundary=0)
idx <- sort(unique(union(ov$A_AND_B1, ov$A_AND_B2)))
cat(sprintf("\n ==>> Number of overlapping ChIP-seq peaks: %s \n", length(idx)))

OvChIPPeakFile <- paste0(BASEOUTDIR, '/ChIP_Peaks_Overlapping_IQTL_Loops.txt')
write.table(ChIPPeakData[idx, ], OvChIPPeakFile, row.names=F, col.names=F, sep="\t", quote=F, append=F)