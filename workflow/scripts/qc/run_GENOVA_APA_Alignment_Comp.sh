#!/bin/sh
#SBATCH --job-name=GENOVA_APA
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=20g
#SBATCH --time=01:00:00
#SBATCH --output=results/revisions/alignment_comparison/loops/logs/job-%j.out
#SBATCH --error=results/revisions/alignment_comparison/loops/logs/job-%j.error

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
tool="juicer" # distiller, juicer
bkgd="juicer"
res=5000

# genova arguments for plotting
min=0
max=30

# printing sample information
echo
echo "Processing"
echo "----------"
echo "sample_name: $sample_name"
echo "tool: $tool"
echo "background: $bkgd"
echo

# create output directory
outdir="results/revisions/alignment_comparison/loops/${sample_name}/apa"
mkdir -p ${outdir}

outfile="${outdir}/${tool}_frgd_${bkgd}_bkgd_allloops_mincolor${min}_maxcolor${max}.pdf"
touch $outfile

loops="results/revisions/alignment_comparison/loops/${sample_name}/apa/${tool}_FitHiChIP-S5.interactions_FitHiC_Q0.01.bed" # all loops
#loops="results/revisions/alignment_comparison/loops/${sample_name}/apa/${tool}_FitHiChIP-S5.interactions_FitHiC_Q0.01.top10000sig.bed" # top sig loops
echo "using loops file: ${loops}"
echo

# determine (or create) hicpro dir
if [[ "$bkgd" == "hicpro" ]]; 
then
	if [[ "$merged" == "unmerged" ]]; 
	then
		sig_file="results/hicpro/${sample_name}/hic_results/matrix/${sample_name}/iced/${res}/${sample_name}_${res}_iced.matrix"
		indicies_file="results/hicpro/${sample_name}/hic_results/matrix/${sample_name}/raw/${res}/${sample_name}_${res}_abs.bed"
	elif [[ "$merged" == "merged" ]];
	then
		sig_file="results/biorep_merged/results/hicpro/${sample_name}/hic_results/matrix/${sample_name}/iced/${res}/${sample_name}_${res}_iced.matrix"
		indicies_file="results/biorep_merged/results/hicpro/${sample_name}/hic_results/matrix/${sample_name}/raw/${res}/${sample_name}_${res}_abs.bed"
	fi
	echo "using signal file: ${sig_file}"

	# run genova apa
	echo
	echo "# Running Genova APA"
	$Rscript $APA --loops $loops --signal_type matrix --signal_file $sig_file --indicies_file $indicies_file --chr_name_contacts 0 --chr_name_loops 0 --resolution ${res} --min_lim $min --max_lim $max --outfile $outfile
fi
if [[ "$bkgd" == "distiller" ]];
then
	sig_file="results/revisions/alignment_comparison/loops/${sample_name}/distiller.mincisdist_1000.UU.UR.${res}.cool"
	echo "using signal file: ${sig_file}"
	
	# run genova apa
	echo
	echo "# Running Genova APA"
	$Rscript $APA --loops $loops --signal_type cooler --signal_file $sig_file --chr_name_contacts 0 --chr_name_loops 0 --resolution ${res} --min_lim $min --max_lim $max --outfile $outfile
fi
if [[ "$bkgd" == "juicer" ]];
then
	sig_file="results/revisions/alignment_comparison/loops/${sample_name}/juicer.mincisdist_1000.${res}.cool"
	echo "using signal file: ${sig_file}"

	# run genova apa
	echo
	echo "# Running Genova APA"
	$Rscript $APA --loops $loops --signal_type cooler --signal_file $sig_file --chr_name_contacts 0 --chr_name_loops 0 --resolution ${res} --min_lim $min --max_lim $max --outfile $outfile
fi

echo "done"
echo