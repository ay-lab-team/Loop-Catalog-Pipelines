#!/bin/bash -ex
#PBS -l nodes=1:ppn=4
#PBS -l mem=200GB
#PBS -l walltime=200:00:00
#PBS -m ae
#PBS -j eo
#PBS -V

# Example run:
# qsub -F "SRR1234567 SRR7890123" grabseqs.sh

source ~/.bashrc
hostname
TMPDIR=/scratch
cd $PBS_O_WORKDIR

source activate grabseqs

outdir="results/fastqs/raw/"
retries=4
threads=4

grabseqs sra -o $outdir -r $retries -t $threads $@