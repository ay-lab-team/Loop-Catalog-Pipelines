#!/bin/sh
#SBATCH --job-name=run_community_annotation
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=5g
#SBATCH --time=10:00:00
#SBATCH --output=results/community/logs/job-%j.out
#SBATCH --error=results/community/logs/job-%j.error

# TO RUN: sbatch --array=<index> workflow/scripts/community/community_annotation.sh

# print start time message
start_time=$(date "+%Y.%m.%d.%H.%M")
echo "Start time: $start_time"

# print start message
echo "Started: community_annotation"

# run bash in strict mode
set -euo pipefail
IFS=$'\n\t'

# make sure to work starting from the github base directory for this script 
cd $SLURM_SUBMIT_DIR
work_dir=$SLURM_SUBMIT_DIR

# source tool paths
source workflow/source_paths.sh

# get sample list
samplesheet="/mnt/bioadhoc-temp/Groups/vd-ay/kfetter/Community-Detection/results/communities_temp/louvain/All_Samples/community_samplesheet.txt"
sample_info=( $(cat $samplesheet | sed -n "${SLURM_ARRAY_TASK_ID}p") )
sample_name="${sample_info[0]}"
echo "Sample: $sample_name"

# run python script
/mnt/bioadhoc-temp/Groups/vd-ay/kfetter/packages/mambaforge/envs/hichip-db/bin/python3 workflow/scripts/community/community_annotation.py ${sample_name}

# print end message
echo
echo "# Ended: community_annotation"

# print end time message
end_time=$(date "+%Y.%m.%d.%H.%M")
echo "End time: $end_time"