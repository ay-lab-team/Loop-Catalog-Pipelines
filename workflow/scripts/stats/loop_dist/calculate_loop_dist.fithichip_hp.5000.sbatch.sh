#!/bin/sh
#SBATCH --job-name=loop_dists.fithichip_hp.5000
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=4g
#SBATCH --time=20:00:00
#SBATCH --output=results/loops/logs/loop_dists/%x.job-%A.array-%a.out
#SBATCH --error=results/loops/logs/loop_dists/%x.job-%A.array-%a.error

# example run with slurm:
# sbatch --array=1-1000 --export=start=1 workflow/scripts/stats/loop_dist/calculate_loop_dist.fithichip_hp.5000.sbatch.sh
# sbatch --array=1-1050 --export=start=1000 workflow/scripts/stats/loop_dist/calculate_loop_dist.fithichip_hp.5000.sbatch.sh


# example run with bash:
# bash workflow/scripts/loops/loop_dist/calculate_loop_dist.fithichip_hp.5000.sbatch.sh 1 1 

# setting global vars
samplesheet="results/samplesheets/loops/fithichip_hp.samples.tsv"
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
sample_name=$(sed -n "${sample_idx}p" $samplesheet)

# input file
fn="results/loops/fithichip/${sample_name}_hichip-peaks.peaks/S5/"
fn+="FitHiChIP_Peak2ALL_b${res}_L20000_U2000000/P2PBckgr_1/Coverage_Bias/FitHiC_BiasCorr/"
fn+="FitHiChIP-S5.interactions_FitHiC_Q0.01.bed"

# output file
outfn="results/loops/fithichip/${sample_name}_hichip-peaks.peaks/S5/"
outfn+="FitHiChIP_Peak2ALL_b${res}_L20000_U2000000/P2PBckgr_1/Coverage_Bias/FitHiC_BiasCorr/"
outfn+="FitHiChIP-S5.interactions_FitHiC_Q0.01.loop_dist.txt"

# run the cmd
cmd="sed '1d' ${fn} | awk '{print \$5 - \$2}' > ${outfn}"
echo "Running: ${cmd}"
eval $cmd

# print end message
echo
echo "Ended: loop_dists"
echo

# print end time message
end_time=$(date "+%Y.%m.%d.%H.%M")
echo "End time: $end_time"
