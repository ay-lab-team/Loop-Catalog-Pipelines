old_dir="results/misc/rename_samples/archive/"
new_dir="results/"
renames_samplesheet="results/misc/rename_samples/copy_and_rename.samplesheet.txt"

# create the naming mapper between the input_sample and output_sample
declare -A rename_mapper 
while read -r line; do

    # get the input and output samples
    input_sample=$(echo $line | cut -d " " -f 1)
    output_sample=$(echo $line | cut -d " " -f 2)

    # add to the mapper
    rename_mapper["$input_sample"]="$output_sample"

done < $renames_samplesheet

#for input_sample in "${!rename_mapper[@]}"
#do
#    # getting the output sample
#    output_sample="${rename_mapper[$input_sample]}"
#
#    # performing the renamess
#    echo $input_sample $output_sample
#
#done 
#

############################# Renaming #############################

# helper function to format the input and output
function format_output {
    output_sample=$1
    main_dir=$2
    loop_suffix=$3

    if [[ $main_dir == "loops/fithichip/" ]];
    then
        output_sample_dir="${new_dir}/${main_dir}/${output_sample}${loop_suffix}"
    else
        output_sample_dir="${new_dir}/${main_dir}/${output_sample}"
    fi

    echo $output_sample_dir
}

# perform the renaming using function
function check_dir {
    main_dir=$1
    loop_suffix=$2

    for input_sample in "${!rename_mapper[@]}"
    do
        # getting the output sample
        output_sample="${rename_mapper[$input_sample]}"

        # setting up the dirs
        output_sample_dir=$(format_output $output_sample $main_dir $loop_suffix)

        # performing the renames
        if [[ -d $output_sample_dir ]];
        then
            echo "$output_sample_dir	found"
        else
            echo "$output_sample_dir	lost"
        fi

    done 
    echo
}

# create the check file
check_fn="results/misc/rename_samples/archive/check_samples.renamed.txt"
echo "" > $check_fn

# check the different directories
check_dir "hicpro/" >> $check_fn
check_dir "fastqs/stats/" >> $check_fn
check_dir "loops/hiccups/whole_genome/" >> $check_fn
check_dir "qc/fastqc/" >> $check_fn
check_dir "loops/fithichip/" "_fithichip.peaks" >> $check_fn
check_dir "loops/fithichip/" "_hichip-peaks.peaks" >> $check_fn














