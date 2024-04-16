#!/bin/sh
#SBATCH --job-name=peaks_to_washu
#SBATCH --mem=10gb
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --output=results/visualizations/logs/peaks_to_washu.%A.%a.out
#SBATCH --error=results/visualizations/logs/peaks_to_washu.%A.%a.err

# print start time message
start_time=$(date "+%Y.%m.%d.%H.%M")
echo "Start time: $start_time"

# print start message
echo "Started: peaks_to_washu"

# run bash in strict mode
set -euo pipefail
IFS=$'\n\t'

# allow this script to be run without qsub by assigning SLURM_ARRAY_TASK_ID from
# the command line using $1
if [ -z "${SLURM_ARRAY_TASK_ID+x}" ]
then
  samplesheet=$1
  ref=$2
  SLURM_ARRAY_TASK_ID=$3
  SLURM_SUBMIT_DIR="."
fi

# make sure to work starting from the github base directory for this script 
cd $SLURM_SUBMIT_DIR

# source tool paths
source workflow/source_paths.sh
source workflow/source_funcs.sh

###############################################################################
# Helper functions 
###############################################################################

# function to convert from the input file to bigBed
function convert_to_bigBed() {
        
        # define the positional arguments
        input=$1
        genome_sizes=$2
        output=$3
        
        # do the conversion
        $bedToBigBed $input $genome_sizes $output
}

# wrapper function that completes all the conversion steps
function convert_to_bigBed_runner(){

        # define the positional arguments
        sample_name=$1
        peak_type=$2
        peaks_file=$3
        output_file=$4
        genome_sizes=$5
        
        # convert the samples to bigBed
        if [ "$peaks_file" ]; then

            echo "***** ${peak_type} peaks found *****"
            echo "peaks_file: $peaks_file"

            num_peaks=$(wc -l $peaks_file | cut -f 1 -d ' ')
            echo "num_peaks: $num_peaks"

            # only convert if the main file has peaks
            if [ "$num_peaks" -eq 0 ];
            then
                echo "Peak file has 0 lines. Skipping."
            else
                # create a sorted intermediate file
                echo -e "\n# create a sorted intermediate file"

                interm_file="results/visualizations/washu/${peak_type}/${sample_name}.${peak_type}.${ref}.peaks.txt"
                cat $peaks_file | $bedtools sort -i - | grep ^chr | grep -v chrM | cut -f 1,2,3 > $interm_file
                echo "interm_file: $interm_file"

                # only convert if the interm has peaks
                num_interm=$(wc -l $interm_file | cut -f 1 -d ' ')
                if [ $num_interm == 0 ];
                then
                    echo "Interm file has 0 lines. Skipping."
                else
                    # convert to bigBed
                    echo -e "\n# convert to bigBed"
                    convert_to_bigBed $interm_file $genome_sizes $output_file
                fi

                # remove the interm file
                rm $interm_file
            fi
            
        else
            echo "${sample_name} does not have an associated ${peak_type} peaks file"
        fi
}

###############################################################################
# Extracting sample information
###############################################################################
sample_name=$(cat $samplesheet | sed -n "${SLURM_ARRAY_TASK_ID}p")

# determining the genome_sizes fiel 
genome_sizes=$(get_genomesizes_from_ref $ref)

# printing sample information
echo
echo "Processing"
echo "----------"
echo "sample_name: $sample_name"
echo "ref: $ref"
echo "genome_sizes: $genome_sizes"
echo

###############################################################################
# Conversion 
###############################################################################

# Convert FitHiChIP peaks
echo 
peak_type="fh_peaks"
peaks_file="results/peaks/fithichip/${sample_name}/MACS2_ExtSize/out_macs2_peaks.narrowPeak"
output_file="results/visualizations/washu/${peak_type}/${sample_name}.${peak_type}.${ref}.peaks.bed.bb"
convert_to_bigBed_runner $sample_name $peak_type $peaks_file $output_file $genome_sizes

# soflinking
lcsd_file="results/lji_lcsd_hub/release-0.1/hub/${ref}/peaks/hichip/fithichip-utility/${sample_name}.peaks.bed.bb"
abs_output_file=$(readlink -f "results/visualizations/washu/${peak_type}/${sample_name}.${peak_type}.${ref}.peaks.bed.bb")
if [ ! -e $lcsd_file ];
then
    ln -s -f $abs_output_file $lcsd_file
fi 

# Convert Chip-Seq Peaks
# echo 
# cp_peaks_file=${sample_info[4]}
# convert_to_bigBed_runner $sample_name "chipseq" $cp_peaks_file $genome_sizes


# print end message
echo "Ended: fh_peaks_to_washu"

# print end time message
end_time=$(date "+%Y.%m.%d.%H.%M")
echo "End time: $end_time"
