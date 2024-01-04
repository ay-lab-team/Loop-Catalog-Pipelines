#!/bin/sh
#SBATCH --job-name=link_ep_network_to_hub
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=1g
#SBATCH --time=20:00:00
#SBATCH --output=results/comm_detect/logs/link_ep_network_to_hub.task_%a.job_%A.out
#SBATCH --error=results/comm_detect/logs/link_ep_network_to_hub.task_%a.job_%A.err

# TO RUN: sbatch --array=<index> workflow/scripts/community/link_ep_network_to_hub.sarray.sh

# print start time message
start_time=$(date "+%Y.%m.%d.%H.%M")
echo "Start time: $start_time"

# print start message
echo "Started: link_ep_network_to_hub"

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

# get sample list
samplesheet="/mnt/bioadhoc-temp/Groups/vd-ay/kfetter/Community-Detection/results/communities_temp/louvain/All_Samples/community_samplesheet.txt"
sample_info=( $(cat $samplesheet | sed -n "${SLURM_ARRAY_TASK_ID}p") )
sample_name="${sample_info[0]}"
echo "Sample: $sample_name"


################################################################################
# link the data for compression
################################################################################
# set the dirs
sample_main_dir="results/comm_detect/louvain/All_Samples/${sample_name}/S5/"
sample_compressed_dir="results/comm_detect/louvain/All_Samples_Compressed/${sample_name}/S5/"
mkdir -p $sample_compressed_dir

# link the crank file
crank_fn="${sample_main_dir}/crank_scores.final.txt"
new_crank_fn="${sample_compressed_dir}/crank_scores.txt"
ln -srf $crank_fn $new_crank_fn

# link the chromosome/community based files
comm_glob="${sample_main_dir}/chr*/comm*/network.annotated.cytoscape.json"
for fn in $(ls $comm_glob);
do
    chrom=$(echo $fn | cut -f 8 -d "/")
    comm=$(echo $fn | cut -f 9 -d "/")
    new_fn="${sample_compressed_dir}/${sample_name}.${chrom}.${comm}.network.annotated.cytoscape.json"
    if [[ ! -e $new_fn ]];
    then
        ln -srf $fn $new_fn
    fi
done

################################################################################
# tar compress the whole folder
################################################################################
# make the tar file
curr_dir=$(pwd -P)
cd results/comm_detect/louvain/All_Samples_Compressed/
hub_tar_file="${sample_name}.tar"
tar -chf $hub_tar_file $sample_name

# move the tar file for processing
cd $curr_dir
curr_tar_path="results/comm_detect/louvain/All_Samples_Compressed/${sample_name}.tar"
final_tar_path="results/shortcuts/hg38/comm_detect/louvain/${sample_name}.tar"
mv $curr_tar_path $final_tar_path 

# print end message
echo
echo "# Ended: link_ep_network_to_hub"

# print end time message
end_time=$(date "+%Y.%m.%d.%H.%M")
echo "End time: $end_time"