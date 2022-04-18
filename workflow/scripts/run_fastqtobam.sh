#!/bin/bash -ex

#PBS -l nodes=1:ppn=16
#PBS -l mem=100GB
#PBS -l walltime=40:00:00
#PBS -m ae
#PBS -j oe
#PBS -V

# Usage:
# qsub -F "<input fastq file>" workflow/scripts/run_fastqtobam.sh

source ~/.bashrc
hostname
TMPDIR=/scratch
cd $PBS_O_WORKDIR

source activate chipline

outpath=$(dirname $1)

outfile=$(basename $1)
outfile=${outfile%%.*}

bowtie2 -x /mnt/BioAdHoc/Groups/vd-ay/Database_HiChIP_eQTL_GWAS/Data/RefGenome/bowtie2_index/hg38/hg38 -U $1 | samtools view -bS - > "$outpath/$outfile.bam"