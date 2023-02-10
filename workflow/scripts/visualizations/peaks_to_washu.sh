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

# allow this script to be run without qsub by assigning PBS_ARRAYID from
# the command line using $1
if [ -z "${PBS_ARRAYID+x}" ]
then
  PBS_ARRAYID=$1
  PBS_O_WORKDIR="."

fi

# make sure to work starting from the github base directory for this script 
cd $PBS_O_WORKDIR

# source tool paths
source workflow/source_paths.sh

# extract the sample information using the PBS ARRAYID
#samplesheet="results/samplesheets/post-hicpro/current-post-hicpro-without-header.tsv"
samplesheet="results/samplesheets/post-hicpro/human.peaks_files.samplesheet.without_header.tsv"

sample_info=( $(cat $samplesheet | sed -n "${PBS_ARRAYID}p") )
sample_name="${sample_info[0]}"

# printing sample information
echo
echo "Processing"
echo "----------"
echo "sample_name: $sample_name"
echo

# identify all peaks files for one sample, then bgzip and tabix
file_samplesheet="results/samplesheets/post-hicpro/human.peaks_files.samplesheet.without_header.tsv"
unset IFS
sample_info=( $(grep "${sample_name}" ${file_samplesheet}) )

# determining the reference genome
if [[ "$file_samplesheet" == *human.peaks_files.samplesheet.without_header.tsv ]]; then
    ref="hg38"
    genome_sizes="/mnt/BioAdHoc/Groups/vd-ay/Database_HiChIP_eQTL_GWAS/Data/RefGenome/chrsize/hg38.chrom.sizes"
    
elif [[ "$file_samplesheet" == "*human_t2t.peaks_files.samplesheet.without_header.tsv" ]]; then
    ref="t2t-chm13-v2.0"
    genome_sizes="/mnt/BioAdHoc/Groups/vd-ay/Database_HiChIP_eQTL_GWAS/Data/RefGenome/chrsize/mm10.chrom.sizes"

elif [[ "$file_samplesheet" == "*mouse.peaks_files.samplesheet.without_header.tsv" ]]; then
    ref="mm10"
    genome_sizes="/mnt/bioadhoc-temp/Groups/vd-ay/kfetter/hichip-db-loop-calling/ref_genome/chm13_refgenome/chrsize/chm13.chrom.sizes"
else
    echo "This run will fail because the samplesheet path is not expected. Check conditions above."
fi

# function to convert from the input file to bigBed
function convert_to_bigBed() {
        
        # define the positional arguments
        input=$1
        genome_sizes=$2
        output=$3
        
        # do the conversion
        /mnt/BioAdHoc/Groups/vd-ay/kfetter/packages/ucsc_genome_browser/bedToBigBed \
            $input \
            $genome_sizes \
            $output
}

echo "ref: $ref"
echo "genome_sizes $genome_sizes"

# HiChIP-Peaks peaks
if [ -f "${sample_info[2]}" ]; then

    echo "hichip-peaks peaks found"
    peaks_file=${sample_info[2]}

    # create a sorted intermediate file (DEBUG: Requires additional parsing)
    interm_file="results/visualizations/washu/hichip-peaks_peaks/${sample_name}.hichip-peaks.peaks.txt"
    cat $peaks_file | sort -k1,1 -k2,2n | cut -f 1,2,3 > $interm_file

    echo "interm_file: $interm_file"
    
    # convert to bigBed
    outfile="results/visualizations/washu/hichip-peaks_peaks/${sample_name}.hichip-peaks.peaks.bed.bb"
    convert_to_bigBed $interm_file $genome_sizes $outfile
    
    echo "outfile: $outfile"

 
else
    echo "${sample_name} does not have an associated hichip-peaks peaks file"
fi


exit

############################ Working above; below is deprecated ##################################



# FitHiChIP peaks
if [ -f "${sample_info[3]}" ]; then
    echo "fithichip peaks found"
    peaks_file=${sample_info[3]}
    outfile="results/visualizations/washu/fithichip_peaks/${sample_name}.fithichip.peaks.txt"
    
    cat $peaks_file | sort -k1,1 -k2,2n > $outfile
    bgzip $outfile
    tabix -f -p bed $outfile'.gz'
else
    echo "${sample_name} does not have an associated fithichip peaks file"
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
    echo "${sample_name} does not have an associated chip-seq peaks file"
fi

# print end message
echo "Ended: peaks_to_washu"

# print end time message
end_time=$(date "+%Y.%m.%d.%H.%M")
echo "End time: $end_time"