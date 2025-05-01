#!/bin/sh
#SBATCH --job-name=run_generate_site_positions
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=10g
#SBATCH --time=10:00:00
#SBATCH --output=results/revisions/juicer/logs/job-%j.out
#SBATCH --error=results/revisions/juicer/logs/job-%j.error

# # run bash in strict mode
set -euo pipefail
IFS=$'\n\t'

# print start message
echo "Started: run_generate_site_positions"

# run bash in strict mode
set -euo pipefail
IFS=$'\n\t'

# make sure to work starting from the base directory for this project 
cd $SLURM_SUBMIT_DIR

# source tool paths
source workflow/source_paths.sh

# extract the sample information using the PBS ARRAYID
org="${1}"
re=${2}
IFS=$'\n\t'

# printing run/sample information
echo
echo "Processing"
echo "----------"
echo "re: $re"
echo "org: $org"
echo

# the output directory 
final_dir="results/revisions/juicer/restriction_sites/kyra"
cd $final_dir

# run generate site positions
juicer_dir="/mnt/BioAdHoc/Groups/vd-ay/kfetter/hichip-db-loop-calling/results/revisions/juicer"

python ${juicer_dir}/misc/generate_site_positions.py $re $org 

# print end message
echo "Ended: run_generate_site_positions"