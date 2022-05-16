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

# run bash in strict mode
set -euo pipefail
IFS=$'\n\t'

# make sure to work starting from the base directory for this project 
cd $PBS_O_WORKDIR

PATH=/mnt/BioAdHoc/Groups/vd-ay/nrao/hichip_database/chipline/software/sambamba:$PATH #sambamba


IFS=$'\t'
samplesheet="results/samplesheets/fastq/2022.05.13.chipseq_tracker.tsv"

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

    target_of_antibody="${sample_info[15]}"
    biological_rep="${sample_info[13]}"
    
    sample_name="$name.$gse_id.$organism.$target_of_antibody.b$biological_rep"
    sample_name="${sample_name// /_}"
    
    # add the sample name to array of samples to merge
    samples_to_merge+=($sample_name)
done

inputfolder1=${samples_to_merge[0]}
inputfolder2=${samples_to_merge[1]}

# outputfoldername=$( awk 'BEGIN{FS=OFS="."} NF--' <<< "$inputfolder1" ) # remove the biological replicate from the name
outputfoldername=$inputfolder1


# check whether the input rows are replicates
if [ $( awk 'BEGIN{FS=OFS="."} NF--' <<< "$inputfolder1" ) != $( awk 'BEGIN{FS=OFS="."} NF--' <<< "$inputfolder2" ) ]
then
    echo "Input rows are not replicates!"
    exit 1
fi

mkdir -p "results/peaks/merged_chipline/$outputfoldername"
outputfolder=$( realpath "results/peaks/merged_chipline/$outputfoldername" )


inputfile1="$inputfolder1/MACS2_Ext_with_Control/$inputfolder1.macs2_peaks.narrowPeak_Q0.01filt"
inputfile1=$( realpath "results/peaks/chipline/$inputfile1" )

inputfile2="$inputfolder2/MACS2_Ext_with_Control/$inputfolder2.macs2_peaks.narrowPeak_Q0.01filt"
inputfile2=$( realpath "results/peaks/chipline/$inputfile2" )


# ChIPLine script base directory
ChIPLineDir=/mnt/BioAdHoc/Groups/vd-ay/nrao/hichip_database/chipline/software/ChIPLine

# main executable of IDR script
# when peak files are used as input
IDRScript="$ChIPLineDir/IDR_Codes/IDRMain.sh"

# path containing the IDRCode package by Anshul Kundaje et. al.
IDRCodePackage=/mnt/BioAdHoc/Groups/vd-ay/nrao/hichip_database/chipline/software/IDRCode/idrCode/


$IDRScript \
    -I $inputfile1 \
    -I $inputfile2 \
    -d $outputfolder \
    -P $IDRCodePackage




