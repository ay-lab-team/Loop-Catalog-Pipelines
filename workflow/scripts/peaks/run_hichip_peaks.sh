#!/bin/bash -ex
#PBS -l nodes=1:ppn=4
#PBS -l mem=200GB
#PBS -l walltime=12:00:00
#PBS -m ae
#PBS -j eo
#PBS -V

# Usage:
# ./workflow/scripts/run_hichip_peaks.sh <HiCPro output for this sample> <sample name> <restriction fragment file>

source ~/.bashrc
hostname
TMPDIR=/scratch
cd $PBS_O_WORKDIR

source activate hichip-peaks

# input directory containing HiC-pro output
HiCProDir=$1

# sample name
sample_name=$2

# output directory to contain the results
baseoutdir="results/peaks/hichip-peaks/$sample_name"
mkdir -p $baseoutdir

tempdir=$baseoutdir'/tempDir'
mkdir -p $tempdir

peak_call -i $HiCProDir -o $baseoutdir -r $3 -p 'hichip_peaks_out_' -f 0.01 -a '/mnt/BioAdHoc/Groups/vd-ay/Database_HiChIP_eQTL_GWAS/Data/RefGenome/chrsize/hg38.chrom.sizes' -t $tempdir -w 4 -k -d