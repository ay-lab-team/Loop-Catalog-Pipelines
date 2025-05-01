#!/bin/sh
#SBATCH --job-name=run_fithichip_loopcalling_S5_v11.0
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=100g
#SBATCH --time=80:00:00
#SBATCH --output=results/revisions/alignment_comparison/loops/logs/job-%j.out
#SBATCH --error=results/revisions/alignment_comparison/loops/logs/job-%j.error

# print start time message
start_time=$(date "+%Y.%m.%d.%H.%M")
echo "Start time: $start_time"

# print start message
echo "Started: run_fithichip_loopcalling_S5"

# run bash in strict mode
set -euo pipefail
IFS=$'\n\t'

# make sure to work starting from the base directory for this project 
cd $SLURM_SUBMIT_DIR

# source tool paths
source workflow/scripts/loops/fithichip_source_paths_v11.0.sh

# extract the sample information using the PBS ARRAYID
samplesheet="results/samplesheets/hicpro/revisions.top_45.hicpro.samplesheet.unmerged.all_batches.without_header.tsv"
#samplesheet="results/samplesheets/hicpro/current.hicpro.samplesheet.merged.all_batches.without_header.tsv"
#samplesheet="results/samplesheets/post-hicpro/human_011023_0434.peaks_files.samplesheet.without_header.tsv"
sample_info=( $(cat $samplesheet | sed -n "${SLURM_ARRAY_TASK_ID}p") )
sample_name="${sample_info[0]}"
org="${sample_info[2]}"

# printing sample information
echo
echo "Processing"
echo "----------"
echo "sample_name: $sample_name"
echo "org: $org"
echo

# identify hicpro validpairs file if avaliable
file_samplesheet="results/samplesheets/post-hicpro/2024.08.15.16.32.peaks_files_chipseq.all_batches.samplesheet.without_header.tsv"
#file_samplesheet="results/samplesheets/post-hicpro/2024.2.1.10.52.peaks_files_fithichip.all_batches.samplesheet.without_header.tsv"
#file_samplesheet="results/samplesheets/post-hicpro/human_011023_0434.peaks_files.samplesheet.without_header.tsv"

unset IFS

# get peaks information
if [[ "$(cut -d'.' -f5 <<< $sample_name)" == "biorep_merged" ]] || [[ "$(cut -d'.' -f6 <<< $sample_name)" == "biorep_merged" ]]; then
    sample_info=( $(grep $(echo ${sample_name} | awk '{ print substr( $0, 1, length($0)-14 ) }') ${file_samplesheet}) )
else
    sample_info=( $(grep "${sample_name}" ${file_samplesheet}) )
fi

tool="hicpro"
#pairs_file="${SLURM_SUBMIT_DIR}/results/revisions/alignment_comparison/loops/${sample_name}/distiller.mincisdist_1000.UU.UR.5000.cool" # juicer.mincisdist_1000.5000.cool, hicpro.mincisdist_1000.allValidPairs
#pairs_file="${SLURM_SUBMIT_DIR}/results/revisions/alignment_comparison/loops/${sample_name}/juicer.mincisdist_1000.5000.cool" # juicer.mincisdist_1000.5000.cool, hicpro.mincisdist_1000.allValidPairs
pairs_file="${SLURM_SUBMIT_DIR}/results/revisions/alignment_comparison/loops/${sample_name}/hicpro.mincisdist_1000.allValidPairs" # juicer.mincisdist_1000.5000.cool, hicpro.mincisdist_1000.allValidPairs
echo ${pairs_file}

# identify peaks file depending on the peak mode selected
# peak mode
# 1 -> HiChIP-Peaks peaks
# 2 -> FitHiChIP peaks
# 3 -> ChIP-Seq peaks
peak_mode=3
echo 
echo "1: HiChIP-Peaks peaks"
echo "2: FitHiChIP peaks"
echo "3: ChIP-Seq peaks"
echo "Selected Peak Mode: $peak_mode"
echo
echo "# finding peaks file"

# HiChIP-Peaks peaks
if [ $peak_mode -eq 1 ]; then
    if [ -f "${sample_info[2]}" ]; then
        echo "hichip-peaks peaks found and will be used to call loops"
        peaks_file=${sample_info[2]}

        # make the output directory
        outdir_S5="${SLURM_SUBMIT_DIR}/results/loops/fithichip/${sample_name}_hichip-peaks.peaks/S5"
        mkdir -p $outdir_S5
    else
        echo "no valid hichip-peaks peaks file found"
        exit 2
    fi
fi

# FitHiChIP peaks
peaks="${sample_info[2]}"
if [ $peak_mode -eq 2 ]; then
    if [ -f "${peaks}" ]; then
        echo "fithichip peaks found and will be used to call loops"
        peaks_file=${peaks}

        # make the output directory
        outdir_S5="${SLURM_SUBMIT_DIR}/results/loops/fithichip/${sample_name}_fithichip.peaks/S5/"
        mkdir -p $outdir_S5
    else
        echo "no valid fithichip peaks file found"
        exit 2
    fi
fi

# Chip-Seq Peaks
if [ $peak_mode -eq 3 ]; then
    if [ -f "${sample_info[2]}" ]; then
        echo "chip-seq peaks found and will be used to call loops"
        peaks_file=${sample_info[2]}

        # make the output directory
        outdir_S5="${SLURM_SUBMIT_DIR}/results/revisions/alignment_comparison/loops/${sample_name}/S5_${tool}/"
        #outdir_S5="${SLURM_SUBMIT_DIR}/results/pieqtl_ncm_rep_combined_donorwise/fithichip/${sample_name}/S5/"
        mkdir -p $outdir_S5
    else
        echo "no valid chip-seq peaks file found"
        exit 2
    fi
fi

## determine correct chrsize file
#ChrSizeFile="/mnt/BioAdHoc/Groups/vd-ay/Database_HiChIP_eQTL_GWAS/Data/RefGenome/chrsize/hg38.chrom.sizes"
#ChrSizeFile="/mnt/BioAdHoc/Groups/vd-ay/Database_HiChIP_eQTL_GWAS/Data/RefGenome/chrsize/mm10.chrom.sizes"
if [[ "$org" == "Homo_Sapiens" ]]; then
    ChrSizeFile="/mnt/BioAdHoc/Groups/vd-ay/Database_HiChIP_eQTL_GWAS/Data/RefGenome/chrsize/hg38.chrom.sizes"
    echo "chrsizes: $ChrSizeFile"
elif [[ "$org" == "Mus_Musculus" ]]; then
    ChrSizeFile="/mnt/BioAdHoc/Groups/vd-ay/Database_HiChIP_eQTL_GWAS/Data/RefGenome/chrsize/mm10.chrom.sizes"
    echo "chrsizes: $ChrSizeFile"
else
    echo "org not found"
    exit    
fi

####################################################################################################################

# generate config file for L, 5kb
configfile_S5="${outdir_S5}configfile_S5_${tool}"
touch $configfile_S5
cat <<EOT >> $configfile_S5
##********
##***** parameters to provide the input HiChIP alignment files
##********

##============
## option 1: provide the valid pairs from HiC-Pro pipeline - can be gzipped as well
##============
ValidPairs=${pairs_file}

##============
## option 2: provide the bin interval and contact matrix files from HiC-Pro pipeline
##============

## bin interval file (of the format *_abs.bed from HiC-pro output)
Interval=

## matrix file (of the format *.matrix from HiC-pro output)
Matrix=

##============
## option 3: If HiChIP was processed by aligners other than HiC-Pro
## a) provide the locus pairs as a .bed formatted file with the following format (7 fields): 
## chr1 	start1	end1 	chr2 	start2 	end2 	contactcounts
##============
Bed=

##============
## option 4: If HiChIP data is provided in .hic format
## Make sure that the .hic file contains the target resolution which is provided in the BINSIZE parameter (below)
##============
HIC=

##============
## option 5: If HiChIP data is provided in .cool / .mcool format
## Make sure that the .cool or .mcool file contains the target resolution which is provided in the BINSIZE parameter (below)
##============
COOL=


##********
## File containing chromomosome size information corresponding to the reference genome.
##********
ChrSizeFile=${ChrSizeFile}

##********
## Mandatory parameter - Reference ChIP-seq / HiChIP peaks (in .bed format) - can be gzipped as well
## We recommend using reference ChIP-seq peaks (if available)
## Otherwise, peaks can be computed from HiChIP data. 
## See the documentation: https://ay-lab.github.io/FitHiChIP/usage/Utilities.html#inferring-peaks-from-hichip-data-for-use-in-the-hichip-pipeline
##********
PeakFile=${peaks_file}


##********
## Mandatory parameter - Output directory to contain all the results
##********
OutDir=${outdir_S5}


##********
## Mandatory parameter - Boolean variable indicating if the reference genome is circular
## 0, by default. If 1 (circular genome), calculation of genomic distance is slightly different
##********
CircularGenome=0


##********
##***** Various FitHiChIP loop calling related parameters
##********

##Interaction type
## 1: peak to peak 
## 2: peak to non peak 
## 3: peak to all (default - both peak-to-peak and peak-to-nonpeak) 
## 4: all to all (similar to Hi-C)
## 5: All of the modes 1 to 4 are computed.
IntType=3

## Bin size, in bases, for the interactions. Default = 5000 (5 Kb).
BINSIZE=5000

## Lower distance threshold of loops - default = 20000 (20 Kb)
LowDistThr=20000

## Upper distance threshold of loops - default = 2000000 (2 Mb)
UppDistThr=2000000

## Values 0/1 - Applicable if IntType = 3 (peak to all output interactions)
## 1 indicates FitHiChIP(S) model - uses only peak to peak loops for background modeling
## 0 corresponds to FitHiChIP(L) - uses both peak to peak and peak to nonpeak loops for background modeling
UseP2PBackgrnd=1

## type of bias - values: 1 / 2
## 1: coverage bias regression
## 2: ICE bias regression
BiasType=1

## if 1 (default), merge filtering (corresponding to either FitHiChIP(L+M) or FitHiChIP(S+M) 
## depending on the parameter UseP2PBackgrnd) is enabled
MergeInt=1

## FDR (q-value) threshold for loop significance
QVALUE=0.01

## prefix string of all the output files (Default = 'FitHiChIP').
PREFIX=FitHiChIP-S5

## Binary variable 1/0: 
## if 1, overwrites any existing output file. 
## otherwise (0), does not overwrite any output file.
OverWrite=1
EOT

#####################################################################################################################

# run fithichip
echo
echo "running fithichip"
echo
$fithichip_call_loops -C $configfile_S5

# print end message
echo
echo "Ended: fithichip loop calling for S5"
echo

# print end time message
end_time=$(date "+%Y.%m.%d.%H.%M")
echo "End time: $end_time"