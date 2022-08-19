#PBS -l nodes=1:ppn=1
#PBS -l mem=10gb
#PBS -l walltime=5:00:00
#PBS -e results/visualizations/logs/
#PBS -o results/visualizations/logs/
#PBS -N peaks_to_washu.sh
#PBS -V

# print start time message
start_time=$(date "+%Y.%m.%d.%H.%M")
echo "Start time: $start_time"

# print start message
echo "Started: peaks_to_washu"

# run bash in strict mode
set -euo pipefail
IFS=$'\n\t'

# make sure to work starting from the github base directory for this script 
cd $PBS_O_WORKDIR

# source tool paths
source workflow/source_paths.sh

# extract the sample information using the PBS ARRAYID
samplesheet="results/samplesheets/post-hicpro/current-post-hicpro-without-header.tsv"
sample_info=( $(cat $samplesheet | sed -n "${PBS_ARRAYID}p") )
sample_name="${sample_info[0]}"

# printing sample information
echo
echo "Processing"
echo "----------"
echo "sample_name: $sample_name"
echo

# identify all peaks files for one sample, then bgzip and tabix
file_samplesheet="results/samplesheets/post-hicpro/peaks_files.samplesheet_1.without_header.tsv"
unset IFS
sample_info=( $(grep "${sample_name}" ${file_samplesheet}) )

# HiChIP-Peaks peaks
if [ -f "${sample_info[2]}" ]; then
    echo "hichip-peaks peaks found"
    peaks_file=${sample_info[2]}
    outfile="results/visualizations/washu/hichip-peaks_peaks/${sample_name}.hichip-peaks.peaks.txt"
    
    cat $peaks_file | sort -k1,1 -k2,2n > $outfile
    bgzip $outfile
    tabix -f -p bed $outfile'.gz'
else
    echo "no valid hichip-peaks peaks file found"
fi

# FitHiChIP peaks
if [ -f "${sample_info[3]}" ]; then
    echo "fithichip peaks found"
    peaks_file=${sample_info[3]}
    outfile="results/visualizations/washu/fithichip_peaks/${sample_name}.fithichip.peaks.txt"
    
    cat $peaks_file | sort -k1,1 -k2,2n > $outfile
    bgzip $outfile
    tabix -f -p bed $outfile'.gz'
else
    echo "no valid fithichip peaks file found"
fi

# Chip-Seq Peaks
if [ -f "${sample_info[4]}" ]; then
    echo "chip-seq peaks found"
    peaks_file=${sample_info[4]}
    outfile="results/visualizations/washu/chipseq_peaks/${sample_name}.chipseq.peaks.txt"
    
    cat $peaks_file | sort -k1,1 -k2,2n > $outfile
    bgzip $outfile
    tabix -f -p bed $outfile'.gz'
else
    echo "no valid chip-seq peaks file found"
fi

# print end message
echo "Ended: peaks_to_washu"

# print end time message
end_time=$(date "+%Y.%m.%d.%H.%M")
echo "End time: $end_time"