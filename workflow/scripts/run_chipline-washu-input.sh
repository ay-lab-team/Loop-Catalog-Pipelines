#!/bin/bash

# Usage:
# workflow/scripts/run_chipline-washu-input.sh <name of ChIPLine output folder>

inputfoldername=$1
inputfile="results/peaks/chipline/$inputfoldername/MACS2_Ext_with_Control/$inputfoldername.macs2_peaks.narrowPeak_Q0.01filt"

outputfolder="results/peaks/chipline_visuals/$inputfoldername"
mkdir -p $outputfolder

PATH=/mnt/BioApps/bedtools/bin/bedtools:$PATH # bedtools
PATH=/mnt/BioApps/tabix/tabix-0.2.6/:$PATH # bgzip, tabix

# create the output bedgraph file
cat $inputfile | awk 'BEGIN{OFS="\t"}; {print $1, $2, $3, $5};' | bedtools sort -i - > "$outputfolder/$inputfoldername.bedgraph"

# create file.bedgraph.gz (input bedgraph file must be sorted)
bgzip "$outputfolder/$inputfoldername.bedgraph"

# create file.bedgraph.gz.tbi
tabix -p bed "$outputfolder/$inputfoldername.bedgraph.gz"