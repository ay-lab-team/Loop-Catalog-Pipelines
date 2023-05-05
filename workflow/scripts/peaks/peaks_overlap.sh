#PBS -l nodes=1:ppn=1
#PBS -l mem=1gb
#PBS -l walltime=0:10:00
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
file_samplesheet="results/samplesheets/post-hicpro/human_updated_0314.peaks_files.samplesheet.without_header.tsv"
unset IFS
sample_info=( $(grep "${sample_name}" ${file_samplesheet}) )

genome="hg38"
chr_sizes="/mnt/BioAdHoc/Groups/vd-ay/Database_HiChIP_eQTL_GWAS/Data/RefGenome/chrsize/${genome}.chrom.sizes"

# call overlaps if necessary peak files present
if [ -f "${sample_info[4]}" ]; then

    cs_file=${sample_info[4]}
    cs_file_s="results/peaks/overlaps/04_25_2023/${sample_name}.chipseq.$genome.bed"
    awk -F["\t"] '{print $1"\t"$2"\t"$3}' $cs_file | sort -k1,1 -k2,2n -k3,3n -u > $cs_file_s

    if [ -f "${sample_info[2]}" ]; then

        hp_file=${sample_info[2]}
        hp_file_s="results/peaks/overlaps/04_25_2023/${sample_name}.hp.sorted.bed"
        hp_file_slop="results/peaks/overlaps/04_25_2023/${sample_name}.hp.sorted.slop.bed"
        outfile="results/peaks/overlaps/04_25_2023/${sample_name}.overlaps.chipseq.hichip_peaks.$genome.txt"
        outfile_no_dups="results/peaks/overlaps/04_25_2023/${sample_name}.chipseq.hichip_peaks.uniq.$genome.txt"
        awk -F["\t"] 'substr($1,1,1) ~ /c/ {print $1"\t"$2"\t"$3}' $hp_file | sort -k1,1 -k2,2n -k3,3n -u > $hp_file_s

        bedtools slop -i $hp_file_s -g $chr_sizes -b 1000 > $hp_file_slop

        bedtools intersect -wa -a $cs_file_s -b $hp_file_slop -sorted > $outfile

        cat $outfile | uniq > $outfile_no_dups

        rm $hp_file_s
        rm $hp_file_slop
        rm $outfile
    
    fi

    if [ -f "${sample_info[3]}" ]; then

        f_file=${sample_info[3]}
        f_file_s="results/peaks/overlaps/04_25_2023/${sample_name}.f.sorted.bed"
        f_file_slop="results/peaks/overlaps/04_25_2023/${sample_name}.f.sorted.slop.bed"
        outfile="results/peaks/overlaps/04_25_2023/${sample_name}.overlaps.chipseq.fithichip.$genome.txt"
        outfile_no_dups="results/peaks/overlaps/04_25_2023/${sample_name}.chipseq.fithichip.uniq.$genome.txt"
        awk -F["\t"] 'substr($1,1,1) ~ /c/ {print $1"\t"$2"\t"$3}' $f_file | sort -k1,1 -k2,2n -k3,3n -u > $f_file_s

        bedtools slop -i $f_file_s -g $chr_sizes -b 1000 > $f_file_slop

        bedtools intersect -wa -a $cs_file_s -b $f_file_slop -sorted > $outfile

        cat $outfile | uniq > $outfile_no_dups

        rm $f_file_s
        rm $f_file_slop
        rm $outfile

    fi
    
else
    echo "missing chipseq peaks file"
fi

# print end message
echo "Ended: peaks_overlap"

# print end time message
end_time=$(date "+%Y.%m.%d.%H.%M")
echo "End time: $end_time"