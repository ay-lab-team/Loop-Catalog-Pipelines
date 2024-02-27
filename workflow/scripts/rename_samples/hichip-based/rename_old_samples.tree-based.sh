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
    file_struct=$3 # options: tree, files

    for input_sample in "${!rename_mapper[@]}"
    do
        # getting the output sample
        output_sample="${rename_mapper[$input_sample]}"

        if [[ $file_struct == "tree" ]];
        then
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

        elif [[ $file_struct == "files" ]];
        then
            # setting up the dirs
            input_dir="${old_dir}/${main_dir}/"
            output_dir="${new_dir}/${main_dir}/"

            # setting up the command
            rename_cmd="bash workflow/scripts/general/symlink_and_rename_sample_files.sh \
                        $input_sample $output_sample $input_dir $output_dir"

            # performing the renames
            # only rename if the input dir exists and the output dir doesn't
            if [[ -e $input_dir ]];
            then
                if [[ ! -e $output_dir ]];
                then
                    eval $rename_cmd
                fi
            fi
        fi
    done 
}

# complete
#rename_dir "fastqs/raw/" "NaN" "tree"
#rename_dir "fastqs/parallel/" "NaN" "tree"
#rename_dir "fastqs/stats/" "NaN" "tree"
#rename_dir "hicpro/" "NaN" "tree"
#rename_dir "loops/hiccups/whole_genome/" "NaN" "tree"
#rename_dir "qc/fastqc/" "NaN" "tree"
#rename_dir "peaks/fithichip/" "NaN" "tree"
#rename_dir "peaks/hichip-peaks/" "NaN" "tree"
#rename_dir "loops/fithichip/" "_fithichip.peaks" "tree"
rename_dir "loops/fithichip/" "_hichip-peaks.peaks" "tree"
#rename_dir "loops/fithichip/" "_chipseq.peaks" "tree"
#rename_dir visualizations/washu/fithichip_loops_chipseq/ NaN tree
#rename_dir motif_analysis/meme/fimo/ NaN tree
#rename_dir pieqtl_ncm_rep_combined_donorwise/fithichip/ NaN tree
#rename_dir pieqtl_ncm_rep_combined_donorwise/validpairs/ NaN tree


# other - will not rename
#rename_dir "visualizations/igv" # data not fully generated
#rename_dir "visualizations/ucsc" # data not fully generated
