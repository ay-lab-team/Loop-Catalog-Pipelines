#!/bin/sh
#SBATCH --job-name=run_homer
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=20g
#SBATCH --time=100:00:00
#SBATCH --output=biorep_merged/results/motif_analysis/logs/job-%j.out
#SBATCH --error=biorep_merged/results/motif_analysis/logs/job-%j.error

# print start time message
start_time=$(date "+%Y.%m.%d.%H.%M")
echo "Start time: $start_time"

# print start message
echo "Started: run_homer"

# run bash in strict mode
set -euo pipefail
IFS=$'\n\t'

# make sure to work starting from the github base directory for this script 
cd $SLURM_SUBMIT_DIR
work_dir=$SLURM_SUBMIT_DIR

# source tool paths
source workflow/source_paths.sh

# extract the sample information using the PBS ARRAYID
# samplesheet="results/samplesheets/hicpro/current.hicpro.samplesheet.without_header.tsv"
# sample_info=( $(cat $samplesheet | sed -n "${PBS_ARRAYID}p") )
# sample_name="${sample_info[0]}"
# org="${sample_info[2]}"

# # printing sample information
# echo
# echo "Processing"
# echo "----------"
# echo "sample_name: $sample_name"
# echo

# make the output directory 
outdir="biorep_merged/results/motif_analysis/homer/conserved_anchors/${1}"
mkdir -p $outdir

# # create input bed file
# echo "# one-dimensionalizing loop BEDPE file"
# config="S10"
# echo "# config: $config"
# loop_file="results/loops/fithichip/${sample_name}_fithichip.peaks/${config}/FitHiChIP_Peak2ALL_b10000_L20000_U2000000/P2PBckgr_1/Coverage_Bias/FitHiC_BiasCorr/FitHiChIP-S10.interactions_FitHiC_Q0.01.bed"
# peak_file="results/peaks/fithichip/${sample_name}/MACS2_ExtSize/out_macs2_peaks.narrowPeak"
# input="results/motif_analysis/homer/$sample_name/input.bed"

# # one-dimensionalize bedpe + get unique anchors 
# awk -F["\t"] '{if (NR > 1) {print $1"\t"$2"\t"$3"\tloop_"NR-1"_anchor_1\t.\t+\n"$4"\t"$5"\t"$6"\tloop_"NR-1"_anchor_2\t.\t+"}}' $loop_file | sort -k1,1 -k2,2n -k3,3n -u > "$outdir/anchors.txt"

# # overlap unique anchors with peak file such that all overlapping peaks for a given anchor are listed for that one anchor
# bedtools intersect -a "$outdir/anchors.txt" -b ${peak_file} -wa -wb > "$outdir/anchors_overlap_peaks.txt"

# # sort the peaks for a given anchor from smallest to largest in regard to p-value
# sort -k1,1 -k2,2n -k3,3n -k14,14n "$outdir/anchors_overlap_peaks.txt" > "$outdir/anchors_overlap_peaks_sorted.txt"

# # keep the peak with the greatest score for a given anchor, discard the rest
# tac "$outdir/anchors_overlap_peaks_sorted.txt" | sort -k1,1 -k2,2n -k3,3n -u > "$outdir/anchors_overlap_peaks_sorted_best_peak.txt"

# # print input file composed of the best peaks 
# awk -F["\t"] '{print $7"\t"$8"\t"$9"\t"$4"\t"$10"\t"$6}' "$outdir/anchors_overlap_peaks_sorted_best_peak.txt" > $input

# run homer
echo
echo "# running homer"

input="biorep_merged/results/motif_analysis/homer/conserved_anchors/${1}/conserved_anchors.sorted.full.bed"
findMotifsGenome.pl $input hg38 $outdir -size given -mask

# print end message
echo
echo "# Ended: homer"

# print end time message
end_time=$(date "+%Y.%m.%d.%H.%M")
echo "End time: $end_time"