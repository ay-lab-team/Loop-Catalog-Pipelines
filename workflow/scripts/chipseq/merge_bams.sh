#!/bin/bash
#SBATCH --job-name=organize_fastqs
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=1gb
#SBATCH --time=10:00:00
#SBATCH --output=results/fastqs/chipseq_pieqtl/job-%j.out
#SBATCH --error=results/fastqs/chipseq_pieqtl/job-%j.err

# run bash in strict mode
set -euo pipefail
IFS=$'\n\t'

cell="NK"

BaseDir="${SLURM_SUBMIT_DIR}/results/peaks/chipline_v2"

OutBaseDir="${BaseDir}/${cell}_merged_donors.phs001703v3p1.Homo_Sapiens.H3K27ac.b1"
#mkdir -p $OutBaseDir

samtools merge ${OutBaseDir}/${cell}_merged.bam ${OutBaseDir}/*.hg38.bam