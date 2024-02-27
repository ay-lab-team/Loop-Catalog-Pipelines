#!/bin/bash -ex

#PBS -l nodes=1:ppn=16
#PBS -l mem=100GB
#PBS -l walltime=40:00:00
#PBS -o results/peaks/merged_chipline/logs/
#PBS -e results/peaks/merged_chipline/logs/
#PBS -N run_merge_chipline
#PBS -m ae
#PBS -j oe
#PBS -V

# Usage:
# qsub workflow/scripts/chipseq/run_merge_chipline.sh -F "<row 1 of ChIP-seq tracker> <row 2 of ChIP-seq tracker> <...>"

# print start time message
start_time=$(date "+%Y.%m.%d.%H.%M")
echo "Start time: $start_time"

# print start message
echo "Started: run_merge_chipline"


# run bash in strict mode
set -euo pipefail
IFS=$'\n\t'

# make sure to work starting from the base directory for this project 
cd $PBS_O_WORKDIR

PATH=/mnt/BioAdHoc/Groups/vd-ay/nrao/hichip_database/chipline/software/sambamba:$PATH #sambamba


IFS=$'\t'
samplesheet="results/samplesheets/fastq/chipseq_tracker.tsv"

samples_to_merge=()

for row in $@
do
    sample_info=( $(cat $samplesheet | sed -n "${row}p") )
    
    # construct the name of the sample using the naming scheme:
    # {sample_name}.{gse_id}.{organism}.{target of antibody}.b{biological_rep}
    name="${sample_info[0]}"
    gse_id="${sample_info[2]}"

    organism="${sample_info[11]}"
    organism=$(echo "$organism" | awk '{print tolower($0)}') # convert string to lowercase
    organism=$(echo "$organism" | awk '{for (i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2)} 1') # Capitalize each word

    target_of_antibody="${sample_info[14]}"
    biological_rep="${sample_info[13]}"
    
    sample_name="$name.$gse_id.$organism.$target_of_antibody.b$biological_rep"
    sample_name="${sample_name// /_}"
    
    # add the sample name to array of samples to merge
    samples_to_merge+=($sample_name)
done


# check whether the input rows are replicates
sample1=$( awk 'BEGIN{FS=OFS="."} NF--' <<< "${samples_to_merge[0]}" ) # remove biological replicate name from sample name
for sample in ${samples_to_merge[@]}; do
    if [[ $sample1 != $( awk 'BEGIN{FS=OFS="."} NF--' <<< "$sample" ) ]]; then
        echo "Input rows are not replicates!"
        exit 1
    fi
done

# create the output folder
outputfoldername=${samples_to_merge[0]}
mkdir -p "results/peaks/merged_chipline/$outputfoldername"
outputfolder=$( realpath "results/peaks/merged_chipline/$outputfoldername" )

# create the portion of the command that takes the samples to merge
inputfilecommand=""
for sample in ${samples_to_merge[@]}; do
    inputfile="results/peaks/chipline/$sample/MACS2_Ext"*"/$sample.macs2_peaks.narrowPeak_Q0.01filt"
    inputfile=$( realpath $inputfile )
    
    inputfilecommand="$inputfilecommand -I $inputfile"
done


# ChIPLine script base directory
ChIPLineDir=/mnt/BioAdHoc/Groups/vd-ay/nrao/hichip_database/chipline/software/ChIPLine

# main executable of IDR script
# when peak files are used as input
IDRScript="$ChIPLineDir/IDR_Codes/IDRMain.sh"

# path containing the IDRCode package by Anshul Kundaje et. al.
IDRCodePackage=/mnt/BioAdHoc/Groups/vd-ay/nrao/hichip_database/chipline/software/IDRCode/idrCode/


eval "$IDRScript $inputfilecommand -d $outputfolder -P $IDRCodePackage"


# print end message
echo "Ended: run_merge_chipline"

# print end time message
end_time=$(date "+%Y.%m.%d.%H.%M")
echo "End time: $end_time"

