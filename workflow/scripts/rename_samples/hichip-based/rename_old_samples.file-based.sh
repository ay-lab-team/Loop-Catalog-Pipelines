old_dir="results/misc/rename_samples/archive/"
new_dir="results/"
renames_samplesheet="results/misc/rename_samples/rename-info/hichip-based/copy_and_rename.samplesheet.txt"

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
function symlink_file() {

    input_file=$1
    output_file=$2

    # only rename if the input file exists and the output file doesn't
    if [[ -e $input_file ]];
    then
        if [[ ! -e $output_file ]];
        then
            ln -rs $input_file $output_file
        fi
    fi
}

# perform the renaming using function
function rename_files {
    main_dir=$1

    for input_sample in "${!rename_mapper[@]}"
    do
        # getting the output sample
        output_sample="${rename_mapper[$input_sample]}"

        # setting up the dirs
        input_dir="${old_dir}/${main_dir}/"
        output_dir="${new_dir}/${main_dir}/"

        for input_file in $(ls ${input_dir}/${input_sample}*);
        do
            # performing the renames
            output_file=$(basename $input_file | sed "s/${input_sample}/${output_sample}/g")
            output_file="${output_dir}/${output_file}"
            symlink_file $input_file $output_file
        done
    done 
}

# complete
#rename_files shortcuts/hg38/loops/hichip/chip-seq/macs2/loose/
#rename_files shortcuts/hg38/loops/hichip/chip-seq/macs2/stringent/
#rename_files shortcuts/hg38/loops/hichip/hiccups/
#rename_files shortcuts/hg38/loops/hichip/hichip/fithichip-utility/loose/
#rename_files shortcuts/hg38/loops/hichip/hichip/fithichip-utility/stringent/
#rename_files shortcuts/hg38/loops/hichip/hichip/hichip-peaks/loose/
#rename_files shortcuts/hg38/loops/hichip/hichip/hichip-peaks/stringent/
#rename_files shortcuts/hg38/peaks/hichip/fithichip-utility/
#rename_files shortcuts/hg38/peaks/hichip/hichip-peaks/
#rename_files peaks/overlaps/no_slop_recall/
