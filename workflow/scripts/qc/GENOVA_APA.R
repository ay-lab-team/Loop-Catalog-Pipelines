# change R package library to bioadhoc-temp (as opposed to BioAdHoc), where GENOVA is installed
.libPaths("/mnt/bioadhoc-temp/Groups/vd-ay/kfetter/packages/mambaforge/envs/hichip-db/lib/R/library")
library(optparse)
library(GENOVA)
library(ggplot2)
options(scipen=999)
options("GENOVA.colour.palette" = "whitered")

option_list = list(
	make_option(c("-l", "--loops"), default=NA, type='character', help='loops (chr1 start1 end1 chr2 start2 end2'),
	#make_option(c("-q", "--qval"), default=NA, type='character', help='Name of column with significance value'),
	#make_option(c("-a", "--hic_file"), default=NA, type='character', help='.hic file from juicer'),
	make_option(c("-s", "--signal_file"), default=NA, type='character', help='.matrix file from HiC-Pro; can be ice normalized'),
	make_option(c("-i", "--indicies_file"), default=NA, type='character', help='.bed file for from HiC-Pro'),
	make_option(c("-c", "--chr_name"), default=NA, type='numeric', help='1 for "chrX" format or 0 for "X" format'),
	make_option(c("-r", "--resolution"), default=NA, type='numeric', help='.matrix or .hic file resolution (ex. 10000)'),
	make_option(c("-n", "--min_lim"), default=NA, type='numeric', help='Min value for color range'),
	make_option(c("-m", "--max_lim"), default=NA, type='numeric', help='Max value for color range'),
	make_option(c("-o", "--outfile"), default=NA, type='character', help='Outfile name')
)
opt_parser <- OptionParser(option_list = option_list, description = "")
opt <- parse_args(opt_parser)
print(opt)

loops <- read.delim(opt$loops, header=FALSE, sep="\t")
#hicfile <- opt$hic_file
signalfile <- opt$signal_file
indicesfile <- opt$indicies_file
chr_name <- opt$chr_name
res <- opt$resolution
min_limit <- opt$min_lim
max_limit <- opt$max_lim
outFile <- opt$outfile
#sig_val <- opt$qval

# APA score: the value of the center pixel divided by the mean of pixels 15–30 kb downstream of the upstream loci and 15–30 kb upstream (http://boylelab.org/pubs/Bioinformatics_2015_Phanstiel.pdf)
APA_score <- function(APA_Matrix, binsize){
	
	# dimension of output matrix
	nelem <- ncol(APA_Matrix)

	#the middle position of the matrix, corresponding to the interaction region
	Central_row <- as.integer((nelem - 1) / 2) + 1
	Central_col <- Central_row

	# in the MANGO paper, 15-30 Kb (or in general the low and high thresholds provided in this command line option)
	# in positive X and Y directions are used for computing the APA score
	low_pixel_offset <- as.integer(15000 / binsize)
	high_pixel_offset <- as.integer(30000 / binsize)

	APA_score_MANGO_paper <- (APA_Matrix[Central_col, Central_row] * 1.0) / mean(APA_Matrix[(Central_col + low_pixel_offset):(Central_col + high_pixel_offset), (Central_row - low_pixel_offset):(Central_row - high_pixel_offset)])

	return(round(APA_score_MANGO_paper, 2))
}

# APA ratio: compute the ratio of central bin to the remaining matrix
APA_ratio <- function(APA_Matrix){
	
	# dimension of output matrix
	nelem <- ncol(APA_Matrix)

	#the middle position of the matrix, corresponding to the interaction region
	Central_row <- as.integer((nelem - 1) / 2) + 1
	Central_col <- Central_row
	
	APA_Ratio_Central_Rest <- (APA_Matrix[Central_col, Central_row] * 1.0) / mean(c(mean(APA_Matrix[1:(Central_col - 1), 1:(Central_row - 1)]), mean(APA_Matrix[(Central_col + 1):nelem, 1:(Central_row - 1)]), mean(APA_Matrix[1:(Central_col - 1), (Central_row + 1):nelem]), mean(APA_Matrix[(Central_col + 1):nelem, (Central_row + 1):nelem])))

	return(round(APA_Ratio_Central_Rest, 2))
}

#workdir <- "/mnt/BioAdHoc/Groups/vd-ay/dsfigueroa/projects/IKAROS"
#hicfile <- paste0(workdir, "/datasets/DNAnexus_JUICER_HIC/HIC/NOVASEQ_JUICER_HIC_STDST_mergedRPL/HIC_WT7001_851_Merge_allValidPairsMBOI.hic")
#hicfile <- paste0(workdir, "/March2022/Data/Juicer_hic_files_NOVA_AVP/Merged._his_files/HICHIP_H3K27AC_WT.851.7001_AVP.hic")
#loops <- read.delim(paste0(workdir, "/March2022/Figure1/Data/H3K27ac_WT_851_7001_FITHICHIP.10K.P2AS.NOVA.interactions_Q0.001.txt"))
#sig_val <- "Q.Value_Bias"
#outFile <- paste0(workdir, "/March2022/Figure1/Results/APA_plots/H3K27Ac_WT_851_7001_HICHIP_APA.pdf")
#res <- 10000


# Dani's function to read a .hic file
#contacts <- load_contacts(hicfile, 
					#resolution = res,
					#balancing = TRUE,
					#sample_name = "")

# read HiC-Pro input: ice normalized 
contacts <- load_contacts(
					signal_path = signalfile,
					indices_path = indicesfile,
					resolution = res,
					sample_name = ""
)

# Keep loops with distance > 150000 & the 10,000 top according to significance 
if("start1" %in% colnames(loops)){
	loops$size <- loops$start2-loops$start1
} else{
	#loops$size <- loops$s2-loops$s1
	loops$size <- loops$V5-loops$V2
}

loops_plot <- loops[loops$size > 150000,]

# commented this out to keep all loops since I have so few (<< 10,000)
#loops_plot <- loops_plot[head(order(loops_plot[,sig_val], decreasing=F), 10000),]

# Edit name of chromosmes
if(chr_name==0){
	contacts$IDX$V1 <- paste0("chr", contacts$IDX$V1)
}

# size_bin = 11 for 50kb window in each side (at 10kb)
# size_bin = 21 for 50kb window in each side (at 5kb)
apa <- APA(contacts, bedpe = loops_plot, size_bin = 21)
apa_score <- APA_score(apply(apa$signal, 2, c), res)
apa_ratio <- APA_ratio(apply(apa$signal, 2, c))

My_Theme = theme(text=element_text(size=25), plot.title = element_text(hjust = 0.5)) 

if(is.na(max_limit)){
	p1 <- visualise(apa) + 
		ggtitle(paste0("\nAPA score = ", apa_score, "\nAPA ratio = ", apa_ratio, "\nnum_loops = ", nrow(loops_plot))) + 
		My_Theme
}else{
	p1 <- visualise(apa, colour_lim=c(min_limit, max_limit)) + 
			ggtitle(paste0("\nAPA score = ", apa_score, "\nAPA ratio = ", apa_ratio)) + 
			My_Theme
}

#new_ylabs <- rev(ggplot_build(p1)$layout$panel_params[[1]]$y$get_labels())

pdf(outFile)
print(p1)
dev.off()

#scale_y_continuous(breaks = c(-25000, 0, 25000), labels = c("25 kb", "5'", "-25 kb" ))