#!/bin/sh
#SBATCH --job-name=run_cooler
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=10g
#SBATCH --time=1:00:00
#SBATCH --output=results/revisions/alignment_comparison/loops/logs/job-%j.out
#SBATCH --error=results/revisions/alignment_comparison/loops/logs/job-%j.error

# activate correct mamba env
source ~/.bashrc
mamba activate hichip-db

echo $(which python)

# run bash in strict mode
set -euo pipefail
IFS=$'\n\t'

# dummy slurm array environment values
# dummy value when not running with sbatch
echo
if [[ -z ${SLURM_ARRAY_TASK_ID+x} ]]
then
    echo "Running with bash, setting SLURM_ARRAY_TASK_ID=\$1=$1"
    SLURM_ARRAY_TASK_ID=$1
    SLURM_SUBMIT_DIR="/mnt/BioAdHoc/Groups/vd-ay/kfetter/hichip-db-loop-calling"
else
    echo "Running with sbatch, SLURM_ARRAY_TASK_ID=$SLURM_ARRAY_TASK_ID"
fi
echo

# print start message
echo "Started: run_cooler"

# run bash in strict mode
set -euo pipefail
IFS=$'\n\t'

# make sure to work starting from the base directory for this project 
cd $SLURM_SUBMIT_DIR

# source tool paths
source workflow/source_paths.sh

# extract the sample information using the PBS ARRAYID
IFS=$'\t'
samplesheet="results/samplesheets/hicpro/revisions.top_45.hicpro.samplesheet.unmerged.all_batches.without_header.tsv"
sample_info=( $(cat $samplesheet | sed -n "${SLURM_ARRAY_TASK_ID}p") )
sample_name="${sample_info[0]}"
org="${sample_info[2]}"
#re=$(echo ${sample_info[5]} | tr '[:upper:]' '[:lower:]')
re=${sample_info[5]}
IFS=$'\n\t'

# set genome and chrom sizes files based on org
if [[ "$org" == "Homo_Sapiens" ]];
then
    genome="hg38"
    chrom_sizes="/mnt/BioAdHoc/Groups/vd-ay/Database_HiChIP_eQTL_GWAS/Data/RefGenome/chrsize/hg38.chrom.sizes"
    ref_genome_file="/mnt/BioAdHoc/Groups/vd-ay/kfetter/hichip-db-loop-calling/results/revisions/juicer/references/hg38/hg38.fa"
elif [[ "$org" == "Mus_Musculus" ]];
then
    genome="mm10"
    chrom_sizes="/mnt/BioAdHoc/Groups/vd-ay/Database_HiChIP_eQTL_GWAS/Data/RefGenome/chrsize/mm10.chrom.sizes"
    ref_genome_file="/mnt/BioAdHoc/Groups/vd-ay/kfetter/hichip-db-loop-calling/results/revisions/juicer/references/mm10/mm10.fa"
else
    echo "org not found"
    exit
fi

tool="juicer" # distiller or juicer
bin=5000

# printing run/sample information
echo
echo "Processing"
echo "----------"
echo "sample_name: $sample_name"
echo "re: $re"
echo "org: $org"
echo

# make the output directory 
final_dir="/mnt/BioAdHoc/Groups/vd-ay/hichip-db-loop-calling/results/revisions/alignment_comparison/loops/${sample_name}"

echo "${chrom_sizes}:${bin}"

# run cooler
echo "# Running cooler"
echo 
if [[ $tool == "juicer" ]]; then
    cooler cload pairs --assembly hg38 -c1 2 -p1 3 -c2 6 -p2 7 ${chrom_sizes}:${bin} ${final_dir}/juicer.mincisdist_1000.tab_sep.pairs ${final_dir}/${tool}.mincisdist_1000.${bin}.cool
fi
if [[ $tool == "distiller" ]]; then
    cooler cload pairs --assembly hg38 -c1 2 -p1 3 -c2 4 -p2 5 ${chrom_sizes}:${bin} ${final_dir}/distiller.mincisdist_1000.UU.UR.pairs ${final_dir}/${tool}.mincisdist_1000.UU.UR.${bin}.cool
fi

# print end message
echo "Ended: run_cooler"