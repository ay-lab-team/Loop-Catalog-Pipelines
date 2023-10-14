#!/bin/sh
#SBATCH --mem=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --output=results/visualizations/logs/washu/hiccups_to_washu/hiccups_to_washu.job_%A.task_%a.out
#SBATCH --error=results/visualizations/logs/washu/hiccups_to_washu/hiccups_to_washu.job_%A.task_%a.err
#SBATCH --job-name=hiccups_to_washu

# print start time message
start_time=$(date "+%Y.%m.%d.%H.%M")
echo "Start time: $start_time"

# print start message
echo "Started: to_washu"

# run bash in strict mode
set -euo pipefail
IFS=$'\n\t'

# make sure to work starting from the github base directory for this script 
cd $SLURM_SUBMIT_DIR

# source tool paths
source workflow/source_paths.sh

# extract the sample information using the PBS ARRAYID
samplesheet= "results/samplesheets/post-hicpro/hiccups_to_wash.samplesheet.txt "
sample_info=( $(cat $samplesheet | sed -n "${SLURM_ARRAY_TASK_ID}p") )
sample_name="${sample_info[0]}"

# printing sample information
echo
echo "Processing"
echo "----------"
echo "sample_name: $sample_name"
echo

def convert(){
    infile=$1
    prefix_file=$2

    # convert if file exists 
    if [ -s "${infile}" ]; then
        echo "loops file found"

        # conversion
        awk -F['\t'] '{if (NR > 2) {print "chr"$1"\t"$2"\t"$3"\tchr"$4":"$5"-"$6",10\nchr"$4"\t"$5"\t"$6"\tchr"$1":"$2"-"$3",10"}}' $infile | sort -k1,1 -k2,2n > $prefix_file

        # compress and idnex
        bgzip $prefix_file
        tabix -f -p bed $prefix_file'.gz'

    else
        echo "no valid loops file found"
    fi

}

resolutions=( "5000" "10000" "25000" )
for res in "${resolutions[@]}";
do

    # get input file
    if [[ $res == "merged"]];
    then
        infile="results/loops/hiccups/${sample_name}/merged_loops.bedpe"
    else
        infile="results/loops/hiccups/${sample_name}/postprocessed_pixels_${res}.bedpe"
    fi

    # get output file
    prefix_file="results/visualizations/washu/hiccups_loops_all/${sample_name}.hiccups.${res}.longrange.bed"
    output_file="results/visualizations/washu/hiccups_loops_all/${sample_name}.hiccups.${res}.longrange.bed.gz"

    # do the conversion
    echo
    echo "infile: ${infile}"
    echo "output_file: ${output_file}"
    echo
    convert $infile $prefix_file
done

# print end message
echo "Ended: converting to washu format"

# print end time message
end_time=$(date "+%Y.%m.%d.%H.%M")
echo "End time: $end_time"