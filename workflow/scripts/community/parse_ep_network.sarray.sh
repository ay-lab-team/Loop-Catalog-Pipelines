#!/bin/sh
#SBATCH --job-name=parse_ep_network
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=5g
#SBATCH --time=10:00:00
#SBATCH --output=results/comm_detect/logs/job-parse_ep_network-%j.out
#SBATCH --error=results/comm_detect/logs/job-parse_ep_network-%j.error

# TO RUN: sbatch --array=<index> workflow/scripts/community/parse_ep_network.sarray.sh

# print start time message
start_time=$(date "+%Y.%m.%d.%H.%M")
echo "Start time: $start_time"

# print start message
echo "Started: parse_ep_network"

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

# wrapper function for python script
run_cytoscape_conversion() {
    sample_dir=$1
    chrom=$2
    comm=$3
    network_file="${sample_dir}/${chrom}/network.annotated.txt"
    subcomm_file="${sample_dir}/${chrom}/${comm}/community.txt"
    cytoscape_json_file="${sample_dir}/${chrom}/${comm}/network.annotated.cytoscape.json"


    if [[ -e "$network_file" ]] && [[ -e "$subcomm_file" ]];
    then
        # message
        echo
        echo "Now Running:"
        echo "network_file: ${network_file}"
        echo "subcomm_file: ${subcomm_file}"
        echo "cytoscape_json_file: ${cytoscape_json_file}"
        echo

        # run command
        cmd="/mnt/bioadhoc-temp/Groups/vd-ay/kfetter/packages/mambaforge/envs/hichip-db/bin/python3 \
                workflow/scripts/community/parse_ep_network.py \
                    --network-file $network_file \
                    --subcomm-file $subcomm_file \
                    --cytoscape-json-file ${sample_dir}/${chrom}/${comm}/network.annotated.cytoscape.json"
        echo $cmd
        eval $cmd
    fi
}

# run python script across all chromosomes and communities
sample_dir="results/comm_detect/louvain/All_Samples/${sample_name}/S5/"

# cycle through the chromosome dirs
for chrom in $(ls $sample_dir | grep "^chr");
do
    # get the dir for the current chromosome
    sample_chrom_dir="${sample_dir}/${chrom}/"

    # cycle through the comm dirs
    for comm in $(ls $sample_chrom_dir/ | grep "^comm");
    do
        run_cytoscape_conversion $sample_dir $chrom $comm
    done
done

# print end message
echo
echo "# Ended: parse_ep_network"

# print end time message
end_time=$(date "+%Y.%m.%d.%H.%M")
echo "End time: $end_time"