#!/bin/sh
#SBATCH --job-name=GENOVA_APA
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=20g
#SBATCH --time=01:00:00
#SBATCH --output=results/revisions/hiccups/whole_genome/overlaps_09.09.24/APA/logs/job-%j.out
#SBATCH --error=results/revisions/hiccups/whole_genome/overlaps_09.09.24/APA/logs/job-%j.error

# run bash in strict mode
set -euo pipefail
IFS=$'\n\t'

cd $SLURM_SUBMIT_DIR
source workflow/source_paths.sh

Rscript="${HOME}/packages/mambaforge/envs/hichip-db/lib/R/bin/Rscript"
APA=${SLURM_SUBMIT_DIR}/workflow/scripts/qc/GENOVA_APA.R

# extract the sample information
samplesheet="results/samplesheets/hicpro/revisions.top_45.hicpro.samplesheet.all.without_header.tsv"
sample_info=( $(cat $samplesheet | sed -n "${SLURM_ARRAY_TASK_ID}p") )
sample_name="${sample_info[0]}"
merged="${sample_info[5]}"

# resolution for APA
res=5000

# printing sample information
echo
echo "Processing"
echo "----------"
echo "sample_name: $sample_name"
echo "res: $res"
echo

# create output directory
outdir="results/revisions/hiccups/whole_genome/overlaps_09.09.24/APA/${sample_name}/"
mkdir -p ${outdir}

for norm in SCALE VC VC_SQRT SHARED; do

	echo "# create APA for sample using norm: ${norm}"

	# determine loops file
	loops="results/revisions/hiccups/whole_genome/top_loops_${res}/${sample_name}/${norm}_top*_fdrdonut.bedpe"
	echo "using loops file: ${loops}"

	# determine (or create) hicpro dir
	if [[ "$merged" == "unmerged" ]]; 
	then
		sig_file="results/hicpro/${sample_name}/hic_results/matrix/${sample_name}/iced/${res}/${sample_name}_${res}_iced.matrix"
		indicies_file="results/hicpro/${sample_name}/hic_results/matrix/${sample_name}/raw/${res}/${sample_name}_${res}_abs.bed"
		echo "using hicpro matrix file: ${sig_file}"
	elif [[ "$merged" == "merged" ]];
	then
		echo "# merged sample"
	fi

	min=0
	max=40
	
	outfile="${outdir}/${sample_name}_${res}_${norm}_top_mincolor${min}_maxcolor${max}.pdf"
	touch $outfile

	echo
	echo "# Running Genova APA"

	# run Genova APA
	$Rscript $APA --loops $loops --signal_type matrix --signal_file $sig_file --indicies_file $indicies_file --chr_name_contacts 0 --chr_name_loops 1 --resolution $res --min_lim $min --max_lim $max --outfile $outfile

	echo "done"
	echo

done