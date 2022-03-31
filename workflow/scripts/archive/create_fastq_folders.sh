#!/bin/bash

tracker="results/samplesheets/hicpro/2022.3.21.HiChIP_Tracker_names_for_folders.tsv"
for srr_path in "results/fastqs/raw/"*.fastq.gz
do
    srr=$(basename $srr_path)
    foldername=$(awk -v srr_id=${srr%_*} -F["\t"] '{if(srr_id ==$4) {print $9}}' $tracker)
    
    mkdir -p "results/fastqs/raw/$foldername"
    mv $srr_path "results/fastqs/raw/$foldername"
done
