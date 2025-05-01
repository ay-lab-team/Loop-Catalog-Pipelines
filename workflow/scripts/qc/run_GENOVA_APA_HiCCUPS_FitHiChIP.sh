#!/bin/sh
#SBATCH --job-name=GENOVA_APA
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=20g
#SBATCH --time=01:00:00
#SBATCH --output=results/revisions/fithichip_vs_hiccups/logs/job-%j.out
#SBATCH --error=results/revisions/fithichip_vs_hiccups/logs/job-%j.error

# run bash in strict mode
set -euo pipefail
IFS=$'\n\t'

cd $SLURM_SUBMIT_DIR
source workflow/source_paths.sh

Rscript="/mnt/bioadhoc-temp/Groups/vd-ay/kfetter/packages/mambaforge/envs/hichip-db/lib/R/bin/Rscript"
APA=${SLURM_SUBMIT_DIR}/workflow/scripts/qc/GENOVA_APA.R

# extract the sample information
samplesheet="results/samplesheets/hicpro/revisions.top_45.hicpro.samplesheet.all.without_header.tsv"
sample_info=( $(cat $samplesheet | sed -n "${SLURM_ARRAY_TASK_ID}p") )
sample_name="${sample_info[0]}"
merged="${sample_info[5]}"

# resolution for APA
res=5000
loop_type="hiccups" # fithichip_random, fithichip_topsig, hiccups

# printing sample information
echo
echo "Processing"
echo "----------"
echo "sample_name: $sample_name"
echo "res: $res"
echo "loop type: $loop_type"
echo

# create output directory
outdir="results/revisions/fithichip_vs_hiccups/${sample_name}"
mkdir -p ${outdir}

# determine loops file
if [[ "$loop_type" == "fithichip_random" ]]; 
then
	loops="${outdir}/FitHiChIP-S5.interactions_FitHiC_Q0.01_MergeNearContacts.sorted.downsampled.bed"
elif [[ "$loop_type" == "fithichip_topsig" ]];
then
	loops="${outdir}/FitHiChIP-S5.interactions_FitHiC_Q0.01_MergeNearContacts.sorted.downsampled.top_significant.bed"
elif [[ "$loop_type" == "hiccups" ]];
then
	loops="${outdir}/postprocessed_pixels_5000.sorted.bedpe"
fi
echo "using loops file: ${loops}"

# determine (or create) hicpro dir
if [[ "$merged" == "unmerged" ]]; 
then
	sig_file="results/hicpro/${sample_name}/hic_results/matrix/${sample_name}/iced/${res}/${sample_name}_${res}_iced.matrix"
	indicies_file="results/hicpro/${sample_name}/hic_results/matrix/${sample_name}/raw/${res}/${sample_name}_${res}_abs.bed"
elif [[ "$merged" == "merged" ]];
then
	sig_file="results/biorep_merged/results/hicpro/${sample_name}/hic_results/matrix/${sample_name}/iced/${res}/${sample_name}_${res}_iced.matrix"
	indicies_file="results/biorep_merged/results/hicpro/${sample_name}/hic_results/matrix/${sample_name}/raw/${res}/${sample_name}_${res}_abs.bed"
fi
echo "using hicpro matrix file: ${sig_file}"

min=0
max=30

outfile="${outdir}/${sample_name}_${loop_type}_${res}_mincolor${min}_maxcolor${max}.pdf"
touch $outfile

echo
echo "# Running Genova APA"

# run Genova APA
$Rscript $APA --loops $loops --signal_type matrix --signal_file $sig_file --indicies_file $indicies_file --chr_name_contacts 0 --chr_name_loops 0 --resolution $res --min_lim $min --max_lim $max --outfile $outfile

echo "done"
echo