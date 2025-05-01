#!/bin/sh
#SBATCH --job-name=overlap_loop_files
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=1g
#SBATCH --time=01:00:00
#SBATCH --output=results/revisions/alignment_comparison/loops/logs/job-%j.out
#SBATCH --error=results/revisions/alignment_comparison/loops/logs/job-%j.error

# print start time message
start_time=$(date "+%Y.%m.%d.%H.%M")
echo "Start time: $start_time"

# print start message
echo "Started: overlap_loop_files"

# run bash in strict mode
set -euo pipefail
IFS=$'\n\t'

# make sure to work starting from the base directory for this project 
cd $SLURM_SUBMIT_DIR

# path of softwares 
source workflow/source_paths.sh

# extract the sample information using the PBS ARRAYID
samplesheet="results/samplesheets/hicpro/revisions.top_45.hicpro.samplesheet.all.without_header.tsv"
sample_info=( $(cat $samplesheet | sed -n "${SLURM_ARRAY_TASK_ID}p") )
sample_name="${sample_info[0]}"


# output file
outdir="results/revisions/alignment_comparison/loops/${sample_name}/bedtools_overlap"
mkdir -p ${outdir}

# find overlaps

# input files
hicpro="results/revisions/alignment_comparison/loops/${sample_name}/S5_hicpro/FitHiChIP_Peak2ALL_b5000_L20000_U2000000/P2PBckgr_1/Coverage_Bias/FitHiC_BiasCorr/FitHiChIP-S5.interactions_FitHiC_Q0.01.bed"
distiller="results/revisions/alignment_comparison/loops/${sample_name}/S5_distiller/FitHiChIP_Peak2ALL_b5000_L20000_U2000000/P2PBckgr_1/Coverage_Bias/FitHiC_BiasCorr/FitHiChIP-S5.interactions_FitHiC_Q0.01.bed"
juicer="results/revisions/alignment_comparison/loops/${sample_name}/S5_juicer/FitHiChIP_Peak2ALL_b5000_L20000_U2000000/P2PBckgr_1/Coverage_Bias/FitHiC_BiasCorr/FitHiChIP-S5.interactions_FitHiC_Q0.01.bed"

# sorted input files
hicpro_sorted="${outdir}/hicpro.FitHiChIP-S5.interactions_FitHiC_Q0.01.sorted.bed"
distiller_sorted="${outdir}/distiller.FitHiChIP-S5.interactions_FitHiC_Q0.01.sorted.bed"
juicer_sorted="${outdir}/juicer.FitHiChIP-S5.interactions_FitHiC_Q0.01.sorted.bed"

# Pre-process input loop files
grep -v "^#" ${hicpro} | awk -F["\t"] '{if (NR>1) {print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t"$6}}' | sort -k1,1 -k2,2n -k3,3n > ${hicpro_sorted}
grep -v "^#" ${distiller} | awk -F["\t"] '{if (NR>1) {print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t"$6}}' | sort -k1,1 -k2,2n -k3,3n > ${distiller_sorted}
grep -v "^#" ${juicer} | awk -F["\t"] '{if (NR>1) {print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t"$6}}' | sort -k1,1 -k2,2n -k3,3n > ${juicer_sorted}

# ### TWO WAY OVERLAP

# # get shared loops
# bedtools pairtopair -a ${hicpro_sorted} -b ${distiller_sorted} -type both > ${outdir}/S5_VC+VC_SQRT.bed
# bedtools pairtopair -a ${hicpro_sorted} -b ${juicer_sorted} -type both > ${outdir}/S5_VC+SCALE.bed

# # get vc-unqiue loops
# bedtools pairtopair -a ${hicpro_sorted} -b ${distiller_sorted} -type neither > ${outdir}/S5_VC-VC_SQRT.bed
# bedtools pairtopair -a ${hicpro_sorted} -b ${juicer_sorted} -type neither > ${outdir}/S5_VC-SCALE.bed

# # get vc_sqrt-unique loops
# bedtools pairtopair -a ${distiller_sorted} -b ${hicpro_sorted} -type neither > ${outdir}/S5_VC_SQRT-VC.bed
# bedtools pairtopair -a ${distiller_sorted} -b ${juicer_sorted} -type neither > ${outdir}/S5_VC_SQRT-SCALE.bed

# # get scale-unique loops
# bedtools pairtopair -a ${juicer_sorted} -b ${hicpro_sorted} -type neither > ${outdir}/S5_SCALE-VC.bed
# bedtools pairtopair -a ${juicer_sorted} -b ${distiller_sorted} -type neither > ${outdir}/S5_SCALE-VC_SQRT.bed

### THREE WAY OVERLAP

# get shared loops
shared=${outdir}/S5_SHARED.bedpe
bedtools pairtopair -a ${hicpro_sorted} -b ${distiller_sorted} -type both -f 1 | cut -f1-6 | bedtools pairtopair -a stdin -b ${juicer_sorted} -type both -f 1 | cut -f1-6 > ${shared}

# get vc-unqiue loops
hicpro_unique=${outdir}/S5_HICPRO.bedpe
bedtools pairtopair -a ${hicpro_sorted} -b ${distiller_sorted} -type neither -f 1 | bedtools pairtopair -a stdin -b ${juicer_sorted} -type neither -f 1 > ${hicpro_unique}
bedtools pairtopair -a ${hicpro_sorted} -b ${distiller_sorted} -type either -f 1 | bedtools pairtopair -a stdin -b ${juicer_sorted} -type either -f 1 >> ${hicpro_unique}

# get vc_sqrt-unique loops
distiller_unique=${outdir}/S5_DISTILLER.bedpe
bedtools pairtopair -a ${distiller_sorted} -b ${hicpro_sorted} -type neither -f 1 | bedtools pairtopair -a stdin -b ${juicer_sorted} -type neither -f 1 > ${distiller_unique}
bedtools pairtopair -a ${distiller_sorted} -b ${hicpro_sorted} -type either -f 1 | bedtools pairtopair -a stdin -b ${juicer_sorted} -type either -f 1 >> ${distiller_unique}

# get scale-unique loops
juicer_unique=${outdir}/S5_JUICER.bedpe
bedtools pairtopair -a ${juicer_sorted} -b ${hicpro_sorted} -type neither -f 1 | bedtools pairtopair -a stdin -b ${distiller_sorted} -type neither -f 1 > ${juicer_unique}
bedtools pairtopair -a ${juicer_sorted} -b ${hicpro_sorted} -type either -f 1 | bedtools pairtopair -a stdin -b ${distiller_sorted} -type either -f 1 >> ${juicer_unique}

# print end message
echo
echo "Ended: overlap_loop_files"
echo

# print end time message
end_time=$(date "+%Y.%m.%d.%H.%M")
echo "End time: $end_time"