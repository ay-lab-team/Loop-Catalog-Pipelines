#!/bin/bash
#SBATCH --job-name=organize_fastqs
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=1gb
#SBATCH --time=10:00:00
#SBATCH --output=results/peaks/chipline_v2/logs/liftover/job-%j.out
#SBATCH --error=results/peaks/chipline_v2/logs/liftover/job-%j.err

# activate correct mamba env
source ~/.bashrc
mamba activate crossmap

# run bash in strict mode
set -euo pipefail
IFS=$'\n\t'

#====================
# get  samples of donors 1800, 1814, 1815, 1816, 1829, 1831
#====================

cell="NK"

BaseDir="/mnt/NGSAnalyses/ChIP-Seq/Mapping/003939_Log7_DY_R24_NK_ChIP_Merged/All_Uniquely_Mapped_BAM_Files"

OutBaseDir="/mnt/BioAdHoc/Groups/vd-ay/kfetter/hichip-db-loop-calling/results/peaks/chipline_v2/${cell}_merged_donors.phs001703v3p1.Homo_Sapiens.H3K27ac.b1"
mkdir -p $OutBaseDir

chain="/mnt/BioAdHoc/Groups/vd-ay/kfetter/genome/chains/hg19ToHg38.over.chain.gz"

echo "# Use CrossMap to liftover donor-wise BAMs from hg19 to hg38"

donor=${1}

echo "Lifting Over: ${donor}"
echo
CrossMap bam ${chain} ${BaseDir}/${donor}.bam ${OutBaseDir}/${donor}.hg38
echo

#echo "# Merge donor-wise lifted-over BAMS into one BAM file"

#samtools merge ${OutBaseDir}/${cell}_merged.bam ${OutBaseDir}*.hg38.bam
