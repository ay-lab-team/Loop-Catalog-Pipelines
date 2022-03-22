#!/bin/bash -ex
#PBS -l nodes=1:ppn=4
#PBS -l mem=1600GB
#PBS -l walltime=200:00:00
#PBS -m ae
#PBS -j eo
#PBS -V

# Example run:
# qsub -F "GSE178598 2022.03.18.HiChIP_Tracker.tsv" results/samplesheets/hicpro/download_srr_fastqs.sh

source ~/.bashrc
hostname
TMPDIR=/scratch
cd $PBS_O_WORKDIR

source activate grabseqs

gse=$1
tracker=$2

srr_array=($(python workflow/scripts/extract-srr-ids.py $gse $tracker))

outdir="results/fastqs/raw/"
retries=4
threads=4

grabseqs sra -o $outdir -r $retries -t $threads ${srr_array[@]}