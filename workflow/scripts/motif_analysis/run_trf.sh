#!/bin/sh
#SBATCH --job-name=run_trf
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=10g
#SBATCH --time=5:00:00
#SBATCH --output=results/motif_analysis/conserved_anchors_11_06_2024/logs/job-%j.out
#SBATCH --error=results/motif_analysis/conserved_anchors_11_06_2024/logs/job-%j.error

# print start time message
start_time=$(date "+%Y.%m.%d.%H.%M")
echo "Start time: $start_time"

# print start message
echo "Started: run_trf"

# run bash in strict mode
set -euo pipefail
IFS=$'\n\t'

# make sure to work starting from the github base directory for this script 
cd $SLURM_SUBMIT_DIR
work_dir=$SLURM_SUBMIT_DIR

# source tool paths
source workflow/source_paths.sh

cell_type="${1}" # all, non-immune, or immune
loop_type="${2}" # no_mergefilt_01.27.2025 or mergefilt

# set paths
outdir_sea="results/motif_analysis/conserved_anchors_11_06_2024/sea/${cell_type}/${loop_type}"
outdir_anchors="results/motif_analysis/conserved_anchors_11_06_2024/conserved_anchor_results/${cell_type}/${loop_type}"

# run TRF
genome="/mnt/BioAdHoc/Groups/vd-ay/Database_HiChIP_eQTL_GWAS/Data/RefGenome/fasta/hg38/hg38.fa"
bed2fasta -o $outdir_sea/input_fasta.fa -both "${outdir_anchors}/conserved_anchors.bed" $genome
cd ${outdir_sea}
trf input_fasta.fa 2 7 7 80 10 50 500 -f -h -m

cd ${SLURM_SUBMIT_DIR}
bed2fasta -o $outdir_anchors/bkgd_nonconserved_all.fa -both "${outdir_anchors}/nonconserved_anchors.bed" $genome
cd ${outdir_anchors}
trf bkgd_nonconserved_all.fa 2 7 7 80 10 50 500 -f -h -m
