#!/bin/sh
#SBATCH --job-name=get_hiccups_normalization_convergence
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=150g
#SBATCH --time=150:00:00
#SBATCH --output=results/loops/hiccups/logs/job-%j.out
#SBATCH --error=results/loops/hiccups/logs/job-%j.error

# print start time message
start_time=$(date "+%Y.%m.%d.%H.%M")
echo "Start time: $start_time"

# print start message
echo "Started: get_hiccups_normalization_convergence"

# run bash in strict mode
set -euo pipefail
IFS=$'\n\t'

# make sure to work starting from the github base directory for this script 
cd $SLURM_SUBMIT_DIR

# source tool paths
source workflow/source_paths.sh

echo "# run python script"

${fithichip_python} workflow/scripts/loops/get_hiccups_normalization_convergence.py

echo "done"
echo

# print end message
echo "Ended: get_hiccups_normalization_convergence"
echo

# print end time message
end_time=$(date "+%Y.%m.%d.%H.%M")
echo "End time: $end_time"