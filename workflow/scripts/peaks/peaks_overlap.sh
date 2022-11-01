#PBS -l nodes=1:ppn=1
#PBS -l mem=5gb
#PBS -l walltime=1:00:00
#PBS -e results/peaks/logs/
#PBS -o results/peaks/logs/
#PBS -N peaks_overlap.sh
#PBS -V

# print start time message
start_time=$(date "+%Y.%m.%d.%H.%M")
echo "Start time: $start_time"

# print start message
echo "Started: peaks_overlap"

# run bash in strict mode
set -euo pipefail
IFS=$'\n\t'

# make sure to work starting from the github base directory for this script 
cd $PBS_O_WORKDIR

# source tool paths
source workflow/source_paths.sh

# extract the sample information using the PBS ARRAYID
samplesheet="results/samplesheets/hicpro/current.hicpro.samplesheet.without_header.tsv"
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

# call overlaps if necessary peak files present
if [ -f "${sample_info[4]}" ]; then

    cs_file=${sample_info[4]}
    cs_file_s="results/peaks/overlaps/no_slop_recall/${sample_name}.cs.bed"
    cat $cs_file | sort -k1,1 -k2,2n > $cs_file_s

    if [ -f "${sample_info[2]}" ]; then

        hp_file=${sample_info[2]}
        hp_file_s="results/peaks/overlaps/no_slop_recall/${sample_name}.hp.bed"
        outfile="results/peaks/overlaps/no_slop_recall/${sample_name}.overlaps.chipseq.hp.txt"
        outfile_no_dups="results/peaks/overlaps/no_slop_recall/${sample_name}.overlaps.chipseq.hp.nodups.txt"
        cat $hp_file | sort -k1,1 -k2,2n > $hp_file_s

        bedtools intersect -wa -a $cs_file_s -b $hp_file_s -sorted > $outfile

        cat $outfile | uniq > $outfile_no_dups

        rm $hp_file_s 
    
    fi

    if [ -f "${sample_info[3]}" ]; then

        f_file=${sample_info[3]}
        f_file_s="results/peaks/overlaps/no_slop_recall/${sample_name}.f.bed"
        outfile="results/peaks/overlaps/no_slop_recall/${sample_name}.overlaps.chipseq.f.txt"
        outfile_no_dups="results/peaks/overlaps/no_slop_recall/${sample_name}.overlaps.chipseq.f.nodups.txt"
        cat $f_file | sort -k1,1 -k2,2n > $f_file_s

        bedtools intersect -wa -a $cs_file_s -b $f_file_s -sorted > $outfile

        cat $outfile | uniq > $outfile_no_dups

        rm $f_file_s

    fi

    rm $cs_file_s
    
else
    echo "missing chipseq peaks file"
fi

# print end message
echo "Ended: peaks_overlap"

# print end time message
end_time=$(date "+%Y.%m.%d.%H.%M")
echo "End time: $end_time"