#!/bin/sh
#SBATCH --job-name=trim_arima
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=4g
#SBATCH --time=20:00:00
#SBATCH --output=results/fastqs/raw/logs/job-%j.out
#SBATCH --error=results/fastqs/raw/logs/job-%j.error

# # run bash in strict mode
set -euo pipefail
IFS=$'\n\t'

# print start time message
start_time=$(date "+%Y.%m.%d.%H.%M")
echo "Start time: $start_time"

# print start message
echo "Started: trim_arima" 

# run bash in strict mode
set -euo pipefail
IFS=$'\n\t'

# make sure to work starting from the base directory for this project 
cd $SLURM_SUBMIT_DIR

# source tool paths
source workflow/source_paths.sh

# extract the sample information using the slurm ARRAYID
IFS=$'\t'
samplesheet="results/samplesheets/hicpro/current.hicpro.samplesheet.all_batches.without_header.tsv"
sample_info=( $(cat $samplesheet | sed -n "${SLURM_ARRAY_TASK_ID}p") )
sample_name="${sample_info[0]}"
IFS=$'\n\t' # can go back to using \n\t

# printing sample information
echo
echo "Processing"
echo "----------"
echo "sample_name: $sample_name"
echo

# make the output directory
base="results/fastqs/raw/$sample_name"
outdir="${base}/trim/"
mkdir -p $outdir

cd $base

for fq in *.fastq.gz; do
    id=$(basename $fq | cut -d'.' -f1)
    zcat ${id}.fastq.gz | awk '{ if(NR%2==0) {print substr($1,6)} else {print} }' | gzip > ${outdir}/${id}_trimmed.fastq.gz
done

# print end time message
end_time=$(date "+%Y.%m.%d.%H.%M")
echo "End time: $end_time"
