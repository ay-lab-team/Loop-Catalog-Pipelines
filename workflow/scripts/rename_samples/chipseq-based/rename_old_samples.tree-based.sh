old_dir="results/misc/rename_samples/archive/"
new_dir="results/"
renames_samplesheet="results/misc/rename_samples/rename-info/chipseq-based/copy_and_rename.samplesheet.txt"

############################# Loading Mapper #############################
# create the naming mapper between the input_sample and output_sample
declare -A rename_mapper 
while read -r line; do

    # get the input and output samples
    input_sample=$(echo $line | cut -d " " -f 1)
    output_sample=$(echo $line | cut -d " " -f 2)

    # add to the mapper
    rename_mapper["$input_sample"]="$output_sample"

done < $renames_samplesheet

############################# Renaming #############################

# helper functions to format the input and output
function format_input_output_dir {
    input_sample=$1
    output_sample=$2
    main_dir=$3
    loop_suffix=$4

    if [[ $main_dir == "loops/fithichip/" ]];
    then
        input_sample_dir="${old_dir}/${main_dir}/${input_sample}${loop_suffix}"
        output_sample_dir="${new_dir}/${main_dir}/${output_sample}${loop_suffix}"
    else
        input_sample_dir="${old_dir}/${main_dir}/${input_sample}"
        output_sample_dir="${new_dir}/${main_dir}/${output_sample}"
    fi

    echo "${input_sample_dir} ${output_sample_dir}"
}

# perform the renaming using function
function rename_dir {
    main_dir=$1
    loop_suffix=$2

    for input_sample in "${!rename_mapper[@]}"
    do
        # getting the output sample
        output_sample="${rename_mapper[$input_sample]}"

        # setting up the dirs
        format_res=$(format_input_output_dir $input_sample $output_sample $main_dir $loop_suffix)
        input_sample_dir=$(echo $format_res | cut -f 1 -d " " )
        output_sample_dir=$(echo $format_res | cut -f 2 -d " ")

        # setting up the command
        rename_cmd="bash workflow/scripts/general/symlink_and_rename_sample_trees.sh \
                    $input_sample $output_sample $input_sample_dir $output_sample_dir"

        # performing the renames
        # only rename if the input dir exists and the output dir doesn't
        if [[ -e $input_sample_dir ]];
        then
            if [[ ! -e $output_sample_dir ]];
            then
                eval $rename_cmd
            fi
        fi

    done 
}

# complete
rename_dir "peaks/chipline/" "NaN"
rename_dir "peaks/merged_chipline/" "NaN"
 
