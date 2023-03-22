#!/bin/sh
#SBATCH --mem=4G
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --output=results/shortcuts/logs/interactions_to_longrange/%x.%A.%a.out
#SBATCH --error=results/shortcuts/logs/interactions_to_longrange/%x.%A.%a.err
#SBATCH --job-name=interactions_to_longrange.fithichip_cp

set -euo pipefail
IFS=$'\n\t'

# to run the code from bash use:
# bash workflow/scripts/visualizations/longrange/interactions_to_longrange.fithichip_cp.qarray.sh 8

# to run the code from Slurm use:
# sbatch --array=8 workflow/scripts/visualizations/longrange/interactions_to_longrange.fithichip_cp.slurm-array.sh 

# to run ALL samples with slurm use (have to run in 1000 chunks):
# sbatch --array=1-1000 workflow/scripts/visualizations/longrange/interactions_to_longrange.fithichip_cp.slurm-array.sh 
# sbatch --array=10001-2000 workflow/scripts/visualizations/longrange/interactions_to_longrange.fithichip_cp.slurm-array.sh 
# sbatch --array=2001-2868 workflow/scripts/visualizations/longrange/interactions_to_longrange.fithichip_cp.slurm-array.sh 

sbatch --array=1-1000 workflow/scripts/visualizations/longrange/interactions_to_longrange.fithichip_cp.slurm-array.sh 
sbatch --array=10001-2000 workflow/scripts/visualizations/longrange/interactions_to_longrange.fithichip_cp.slurm-array.sh 
sbatch --array=2001-2868 workflow/scripts/visualizations/longrange/interactions_to_longrange.fithichip_cp.slurm-array.sh 


#squeue -u username
# scancel <job_id>


# allow this script to be run without qsub by assigning PBS_ARRAYID from
# # the command line using $1
if [ -z "${SLURM_ARRAY_TASK_ID+x}" ]
then
  SLURM_ARRAY_TASK_ID=$1
  SLURM_SUBMIT_DIR="."
fi

cd $SLURM_SUBMIT_DIR

# source tool paths
source workflow/source_paths.sh

# extracting the input file name
info=$(sed -n ${SLURM_ARRAY_TASK_ID}p workflow/scripts/visualizations/samplesheets/samplesheet.fithichip_cp.wc.txt)
input=$(echo $info | cut -d " " -f 1)
num_loops=$(echo $info | cut -d " " -f 2)

if [[ $num_loops -lt 1 ]]
then
  echo "No loops found for $input"
  exit 0
fi

# defining a list of input variables
output=$(echo $input | sed 's/bed$/longrange.bed.gz/')
prefix=$(echo $input | sed 's/\.bed$//')

echo "input: $input"
echo "output: $output"


# helper function to convert from fithichip to longrange
function fithichip_to_longrange() {

    input=$1
    prefix=$2
    temp="${prefix}.longrange.bed"

    # convert to longrange format
    awk 'BEGIN{OFS="\t"}; {score=-log($26)/log(10); if (NR > 1) {print $1, $2, $3, $4 ":" $5 "-" $6, score "\n" $4, $5, $6, $1 ":" $2 "-" $3, score}}' $input | sort -k1,1 -k2,2n > $temp

    # compress and index the output 
    $bgzip -f $temp
    $tabix -f -p bed "${temp}.gz"

}

# running the interact_to_bigbed.py script
echo 'running the fithichip_to_longrange function'
cmd="fithichip_to_longrange $input $prefix"
echo "Running: $cmd"
eval $cmd
echo "Done."