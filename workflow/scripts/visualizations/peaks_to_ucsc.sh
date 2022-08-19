#PBS -l nodes=1:ppn=1
#PBS -l mem=10gb
#PBS -l walltime=5:00:00
#PBS -e results/visualizations/logs/
#PBS -o results/visualizations/logs/
#PBS -N peaks_to_ucsc.sh
#PBS -V

# print start time message
start_time=$(date "+%Y.%m.%d.%H.%M")
echo "Start time: $start_time"

# print start message
echo "Started: peaks_to_ucsc"

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
file_samplesheet="results/samplesheets/post-hicpro/peaks_files.samplesheet.without_header.tsv"
unset IFS
sample_info=( $(grep "${sample_name}" ${file_samplesheet}) )

# identify chrom sizes file
chrom_sizes="/mnt/BioAdHoc/Groups/vd-ay/Database_HiChIP_eQTL_GWAS/Data/RefGenome/chrsize/hg38.chrom.sizes"
bignarrow="/mnt/BioAdHoc/Groups/vd-ay/kfetter/packages/ucsc_genome_browser/bigNarrowPeak.as"

# HiChIP-Peaks peaks
if [ -f "${sample_info[2]}" ]; then
    echo "hichip-peaks peaks found"
    peaks_file=${sample_info[2]}
    sorted_bed="results/visualizations/ucsc/hichip-peaks_peaks/${sample_name}.hichip-peaks.peaks.sorted.bed"
    bigbed="results/visualizations/ucsc/hichip-peaks_peaks/${sample_name}.hichippeaks.peaks.bb"
    
    awk -F['\t'] '{ if (NR > 0) { print $1"\t"$2"\t"$3 } }' $peaks_file | sort -k1,1 -k2,2n > $sorted_bed
    bedToBigBed -tab $sorted_bed $chrom_sizes $bigbed
    #rm $sorted_bed
else
    echo "no valid hichip-peaks peaks file found"
fi

# FitHiChIP peaks
if [ -f "${sample_info[3]}" ]; then
    echo "fithichip peaks found"
    peaks_file=${sample_info[3]}
    sorted_np="results/visualizations/ucsc/fithichip_peaks/${sample_name}.fithichip.peaks.sorted.narrowPeak"
    bignp="results/visualizations/ucsc/fithichip_peaks/${sample_name}.fithichip.peaks.bb"
    
    cat $peaks_file | sort -k1,1 -k2,2n > $sorted_np
    bedToBigBed -type=bed6+4 -tab -as=$bignarrow $sorted_np $chrom_sizes $bignp
    #rm $sorted_np
else
    echo "no valid fithichip peaks file found"
fi

# Chip-Seq Peaks
if [ -f "${sample_info[4]}" ]; then
    echo "chip-seq peaks found"
    peaks_file=${sample_info[4]}

    filename=$(basename -- "$peaks_file")
    extension="${filename##*.}"
    echo $extension

    if [[ $extension == "txt" ]]; then
        sorted_bed="results/visualizations/ucsc/chipseq_peaks/${sample_name}.chipseq.peaks.sorted.bed"
        bigbed="results/visualizations/ucsc/chipseq_peaks/${sample_name}.chipseq.peaks.bb"
        
        cat $peaks_file | sort -k1,1 -k2,2n > $sorted_bed
        bedToBigBed -tab $sorted_bed $chrom_sizes $bigbed
        #rm $sorted_bed
    fi

    if [[ $extension == *"filt" ]]; then
        sorted_np="results/visualizations/ucsc/chipseq_peaks/${sample_name}.chipseq.peaks.sorted.narrowPeak"
        bignp="results/visualizations/ucsc/chipseq_peaks/${sample_name}.chipseq.peaks.bb"
        
        cat $peaks_file | sort -k1,1 -k2,2n > $sorted_np
        bedToBigBed -type=bed6+4 -tab -as=$bignarrow $sorted_np $chrom_sizes $bignp
        #rm $sorted_np
    fi

else
    echo "no valid chip-seq peaks file found"
fi

# print end message
echo "Ended: peaks_to_ucsc"

# print end time message
end_time=$(date "+%Y.%m.%d.%H.%M")
echo "End time: $end_time"