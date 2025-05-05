#!/bin/sh
#SBATCH --job-name=run_fimo
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=10g
#SBATCH --time=100:00:00
#SBATCH --output=results/motif_analysis/conserved_anchors_11_06_2024/logs/job-%j.out
#SBATCH --error=results/motif_analysis/conserved_anchors_11_06_2024/logs/job-%j.error

# print start time message
start_time=$(date "+%Y.%m.%d.%H.%M")
echo "Start time: $start_time"

# print start message
echo "Started: run_fimo"

# run bash in strict mode
set -euo pipefail
IFS=$'\n\t'

# make sure to work starting from the github base directory for this script 
cd $SLURM_SUBMIT_DIR
work_dir=$SLURM_SUBMIT_DIR

# source tool paths
source workflow/source_paths.sh

database="jaspar"
#database="hocomoco"

# printing sample information
echo
echo "Processing"
echo "----------"
echo

cell_type="${1}" # all, non-immune, or immune
loop_type="${2}" # no_mergefilt or mergefilt

# make the output directory 
#outdir="results/motif_analysis/fimo/${sample_name}"
sea_dir="results/motif_analysis/conserved_anchors_11_06_2024/sea/${cell_type}/${loop_type}"
outdir="results/motif_analysis/conserved_anchors_11_06_2024/fimo/${cell_type}/${loop_type}"
mkdir -p $outdir

# run sea
echo
echo "# running sea"

if [[ $database == "jaspar" ]]; then
    motifs="${LOOP_CATALOG_DIR}/data/motifs/motif_databases/Jaspar_CORE_2022_latest_human.meme"
fi
if [[ $database == "hocomoco" ]]; then
    motifs="${LOOP_CATALOG_DIR}/data/motifs/motif_databases/HUMAN/HOCOMOCOv11_core_HUMAN_mono_meme_format.meme"
fi

fimo --oc $outdir/${database}_conserved_masked_q0.1 --parse-genomic-coord --qv-thresh --thresh ​0.1 $motifs $sea_dir/input_fasta.fa.2.7.7.80.10.50.500.mask

# print end message
echo
echo "# Ended: fimo"

# print end time message
end_time=$(date "+%Y.%m.%d.%H.%M")
echo "End time: $end_time"