#!/bin/sh
#SBATCH --mem=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --output=results/visualizations/logs/washu/fithichip_hp_to_washu/fithichip_hp_to_washu.job_%A.task_%a.out
#SBATCH --error=results/visualizations/logs/washu/fithichip_hp_to_washu/fithichip_hp_to_washu.job_%A.task_%a.err
#SBATCH --job-name=fithichip_hp_to_washu
#SBATCH --array 2

# sbatch workflow/scripts/visualizations/longrange/fithichip_hp_to_washu.sarray.sh

# print start time message
start_time=$(date "+%Y.%m.%d.%H.%M")
echo "Start time: $start_time"

# print start message
echo "Started: to_washu"

# run bash in strict mode
set -euo pipefail
IFS=$'\n\t'

# make sure to work starting from the github base directory for this script 
#cd $SLURM_SUBMIT_DIR

# make useable from the command line as well
if [[ ! -v "SLURM_ARRAY_TASK_ID" ]];
then 
    SLURM_ARRAY_TASK_ID=$1
fi

# source tool paths
source workflow/source_paths.sh
source workflow/source_funcs.sh

# extract the sample information using the PBS ARRAYID
samplesheet="results/samplesheets/post-hicpro/fithichip_hp_to_washu.samplesheet.txt"
sample_info=( $(cat $samplesheet | sed -n "${SLURM_ARRAY_TASK_ID}p") )
sample_name="${sample_info[0]}"

# printing sample information
echo
echo "Processing"
echo "----------"
echo "sample_name: $sample_name"
echo

# function to convert from fithichip_hp to washu, has created specifically for this
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
                            score=-log($26)/log(10); \

                            # print the left anchor 
                            left=$4 ":" $5 "-" $6 "," score; \
                            print $1, $2, $3, left \

                            # print the right anchor
                            right=$1 ":" $2 "-" $3 "," score; \
                            print $4, $5, $6, right \
                        } \
                    }' $infile | sed '1d' | sort -k1,1 -k2,2n > $prefix_file

        # compress and idnex
        bgzip -f $prefix_file
        tabix -f -p bed $prefix_file'.gz'

    else
        echo "no valid loops file found"
    fi

}

#####################################################################
# Stringency = 'S'
#####################################################################
# converting fithichip_hp files for 5000, 10000, 25000
# also adding a softlink to the correct hub location
resolutions=( "5000" "10000" "25000")
resolutions_short=( "5" "10" "25")
stringency="S"
stringency_no="1"
stringency_long="stringent"
hub_dir_tmpl="${project_dir}/results/shortcuts/hg38/loops/hichip/hichip/fithichip-utility/${stringency_long}/"
for i in "${!resolutions[@]}";
do

    res="${resolutions[i]}"
    res_short="${resolutions_short[i]}"

    # get input file
    infile="results/loops/fithichip/${sample_name}_fithichip.peaks/${stringency}${res_short}/FitHiChIP_Peak2ALL_b${res}_L20000_U2000000/P2PBckgr_${stringency_no}/Coverage_Bias/FitHiC_BiasCorr/FitHiChIP-${stringency}${res_short}.interactions_FitHiC_Q0.01.bed"

    # get output file
    prefix_file="results/visualizations/washu/fithichip_loops_fithichip/${sample_name}.${res}.${stringency_long}.fithichip_hp.longrange.bed"
    output_file="results/visualizations/washu/fithichip_loops_fithichip/${sample_name}.${res}.${stringency_long}.fithichip_hp.longrange.bed.gz"
    index_file="results/visualizations/washu/fithichip_loops_fithichip/${sample_name}.${res}.${stringency_long}.fithichip_hp.longrange.bed.gz.tbi"

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
    lc_lr_link="${hub_dir}/${sample_name}.${res}.fithichip_hp.longrange.bed.gz"
    lc_index_link="${hub_dir}/${sample_name}.${res}.fithichip_hp.longrange.bed.gz.tbi"
    if [[ -f $output_file ]];
    then
        ln -f $output_file $lc_lr_link
        ln -f $index_file $lc_index_link
    fi

done

#####################################################################
# Stringency = 'L'
#####################################################################
# converting fithichip_hp files for 5000, 10000, 25000
# also adding a softlink to the correct hub location
resolutions=( "5000" "10000" "25000")
resolutions_short=( "5" "10" "25")
stringency="L"
stringency_no="0"
stringency_long="loose"
hub_dir_tmpl="${project_dir}/results/shortcuts/ref-replace/loops/hichip/hichip/fithichip-utility/${stringency_long}/"
for i in "${!resolutions[@]}";
do

    res="${resolutions[i]}"
    res_short="${resolutions_short[i]}"

    # get input file
    infile="results/loops/fithichip/${sample_name}_fithichip.peaks/${stringency}${res_short}/FitHiChIP_Peak2ALL_b${res}_L20000_U2000000/P2PBckgr_${stringency_no}/Coverage_Bias/FitHiC_BiasCorr/FitHiChIP-${stringency}${res_short}.interactions_FitHiC_Q0.01.bed"

    # get output file
    prefix_file="results/visualizations/washu/fithichip_loops_fithichip/${sample_name}.${res}.${stringency_long}.fithichip_hp.longrange.bed"
    output_file="results/visualizations/washu/fithichip_loops_fithichip/${sample_name}.${res}.${stringency_long}.fithichip_hp.longrange.bed.gz"
    index_file="results/visualizations/washu/fithichip_loops_fithichip/${sample_name}.${res}.${stringency_long}.fithichip_hp.longrange.bed.gz.tbi"

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
    lc_lr_link="${hub_dir}/${sample_name}.${res}.fithichip_hp.longrange.bed.gz"
    lc_index_link="${hub_dir}/${sample_name}.${res}.fithichip_hp.longrange.bed.gz.tbi"
    if [[ -f $output_file ]];
    then
        ln -f $output_file $lc_lr_link
        ln -f $index_file $lc_index_link
    fi

done

# print end message
echo "Ended: converting to washu format"

# print end time message
end_time=$(date "+%Y.%m.%d.%H.%M")
echo "End time: $end_time"