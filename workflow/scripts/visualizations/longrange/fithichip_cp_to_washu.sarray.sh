#!/bin/sh
#SBATCH --mem=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --output=results/visualizations/logs/washu/hiccups_to_washu/hiccups_to_washu.job_%A.task_%a.out
#SBATCH --error=results/visualizations/logs/washu/hiccups_to_washu/hiccups_to_washu.job_%A.task_%a.err
#SBATCH --job-name=hiccups_to_washu
#SBATCH --array 1-176

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
source workflow/source_funcs.sh

# extract the sample information using the PBS ARRAYID
samplesheet="results/samplesheets/post-hicpro/hiccups_to_washu.samplesheet.txt" # CHANGE THIS
sample_info=( $(cat $samplesheet | sed -n "${SLURM_ARRAY_TASK_ID}p") )
sample_name="${sample_info[0]}"

# printing sample information
echo
echo "Processing"
echo "----------"
echo "sample_name: $sample_name"
echo

# function to convert from hiccups to washu
function convert(){
    infile=$1
    prefix_file=$2

    # convert if file exists 
    if [ -s "${infile}" ]; then
        echo "loops file found"

        # conversion using fdrDonut (col-index = 18)
        awk -F['\t'] 'BEGIN{FS=OFS="\t"} \
                    { \
                        if ($0 !~ /^#/) { \
                            score=-log($18)/log(10); \

                            # print the left anchor 
                            left="chr" $4 ":" $5 "-" $6 "," score; \
                            print "chr" $1, $2, $3, left \

                            # print the right anchor
                            right="chr" $1 ":" $2 "-" $3 "," score; \
                            print "chr" $4, $5, $6, right \
                        } \
                    }' $infile | sort -k1,1 -k2,2n > $prefix_file

        # compress and idnex
        bgzip -f $prefix_file
        tabix -f -p bed $prefix_file'.gz'

    else
        echo "no valid loops file found"
    fi

}

# converting hiccups files for 5000, 10000, 25000 and merged
# also adding a softlink to the correct hub location
hub_dir_tmpl="/mnt/BioAdHoc/Groups/vd-ay/hichip-db-loop-calling/results/shortcuts/ref-replace/loops/hichip/hiccups/" # CHANGE THIS
resolutions=( "5000" "10000" "25000" )
for res in "${resolutions[@]}";
do

    # get input file
    if [[ $res == "merged" ]];
    then
        infile="results/loops/hiccups/whole_genome/${sample_name}/merged_loops.bedpe"
    else
        infile="results/loops/hiccups/whole_genome/${sample_name}/postprocessed_pixels_${res}.bedpe"
    fi

    # get output file
    prefix_file="results/visualizations/washu/hiccups_loops_all/${sample_name}.${res}.hiccups.longrange.bed"
    output_file="results/visualizations/washu/hiccups_loops_all/${sample_name}.${res}.hiccups.longrange.bed.gz"
    index_file="results/visualizations/washu/hiccups_loops_all/${sample_name}.${res}.hiccups.longrange.bed.gz.tbi"

    # do the conversion
    echo
    echo "Working on the conversion for ${res}:"
    echo "infile: ${infile}"
    echo "output_file: ${output_file}"
    echo
    convert $infile $prefix_file

    # softlink longrange and index to the LC hub
    # only softlink if the output file was generated
    ref=$(get_ref_from_sample_name $sample_name)
    hub_dir=$( echo $hub_dir_tmpl | sed "s/ref-replace/${ref}/g")
    lc_lr_link="${hub_dir}/${sample_name}.${res}.hiccups.longrange.bed.gz"
    lc_index_link="${hub_dir}/${sample_name}.${res}.hiccups.longrange.bed.gz.tbi"
    if [[ -f $output_file ]];
    then
        ln -frs $output_file $lc_lr_link
        ln -frs $index_file $lc_index_link
    fi

done

# print end message
echo "Ended: converting to washu format"

# print end time message
end_time=$(date "+%Y.%m.%d.%H.%M")
echo "End time: $end_time"