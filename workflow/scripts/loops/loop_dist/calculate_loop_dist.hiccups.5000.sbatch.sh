#!/bin/sh
#SBATCH --job-name=loop_dists.hiccups.5000
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=4g
#SBATCH --time=20:00:00
#SBATCH --output=results/loops/logs/loop_dists/%x.job-%A.array-%a.out
#SBATCH --error=results/loops/logs/loop_dists/%x.job-%A.array-%a.error

# example run with slurm:
# sbatch --export=start=1,res workflow/scripts/loops/overlap_loop_files.sh

# example run with bash:
# bash workflow/scripts/loops/overlap_loop_files.sh 1 1

# setting global vars
samplesheet="results/samplesheets/hiccups/hiccups.std_sample_name.txt"
res=5000

# print start time message
start_time=$(date "+%Y.%m.%d.%H.%M")
echo "Start time: $start_time"

# print start message
echo "Started: loop_dists"

# run bash in strict mode
set -euo pipefail
IFS=$'\n\t'


# providing interface for non-slurm functions and testing
if [[ ! -v SLURM_SUBMIT_DIR ]];
then 
    start=$1
    SLURM_SUBMIT_DIR="."
    SLURM_ARRAY_TASK_ID=$2
fi

# make sure to work starting from the base directory for this project 
cd $SLURM_SUBMIT_DIR

# path of softwares 
source workflow/source_paths.sh

# current sample
sample_idx=$(expr $start - 1 + $SLURM_ARRAY_TASK_ID)
sample_name=$(sed -n "${sample_idx}p" $samplesheet | cut -f 1 | cut -d "/" -f 12 )

# input file
fn="results/loops/hiccups/whole_genome/${sample_name}/enriched_pixels_${res}.bedpe"

# output file
outfn="results/loops/hiccups/whole_genome/${sample_name}/enriched_pixels_${res}.loop_dist.txt"

# run the cmd
cmd="awk '{print \$5 - \$2}' ${fn} > ${outfn}"
echo "Running: ${cmd}"
eval $cmd

# print end message
echo
echo "Ended: loop_dists"
echo

# print end time message
end_time=$(date "+%Y.%m.%d.%H.%M")
echo "End time: $end_time"
