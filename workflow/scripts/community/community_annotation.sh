#!/bin/sh
#SBATCH --job-name=community_annotation
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=5g
#SBATCH --time=10:00:00
#SBATCH --output=results/community/logs/community_annotation/community_annotation.%A.%a.out
#SBATCH --error=results/community/logs/community_annotation/community_annotation.%A.%a.err

# TO RUN: sbatch --array=1-151 workflow/scripts/community/community_annotation.sh

# print start time message
start_time=$(date "+%Y.%m.%d.%H.%M")
echo "Start time: $start_time"

# print start message
echo "Started: community_annotation"

# run bash in strict mode
set -euo pipefail
IFS=$'\n\t'

# make sure to work starting from the github base directory for this script 
if [[ ! -v "SLURM_ARRAY_TASK_ID" ]];
then
    SLURM_ARRAY_TASK_ID=$1
    SLURM_SUBMIT_DIR="./"
fi
    
cd $SLURM_SUBMIT_DIR
work_dir=$SLURM_SUBMIT_DIR

# source tool paths
source workflow/source_paths.sh
source workflow/source_funcs.sh

# get sample list
script="workflow/scripts/community/community_annotation.sh"
samplesheet="results/samplesheets/comm_detect/samples.with_cytoscape.txt"
sample_info=( $(cat $samplesheet | sed -n "${SLURM_ARRAY_TASK_ID}p") )
sample_name="${sample_info[0]}"
echo "script: $script"
echo "samplesheet: $samplesheet"
echo "Sample: $sample_name"

# run python script
${fithichip_python} workflow/scripts/community/community_annotation.py ${sample_name}

# print end message
echo
ended_job_message "# Ended: community_annotation"
