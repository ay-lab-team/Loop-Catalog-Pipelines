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
#samplesheet="results/samplesheets/post-hicpro/human.peaks_files.samplesheet.without_header.tsv"
#samplesheet="results/samplesheets/post-hicpro/mouse.peaks_files.samplesheet.without_header.tsv"
samplesheet="results/samplesheets/post-hicpro/human_t2t.peaks_files.samplesheet.without_header.tsv"

sample_info=( $(cat $samplesheet | sed -n "${PBS_ARRAYID}p") )
sample_name="${sample_info[0]}"

# printing sample information
echo
echo "Processing"
echo "----------"
echo "sample_name: $sample_name"
echo

# identify all peaks files for one sample, then bgzip and tabix

# determining the reference genome
if [[ "$samplesheet" == *human.peaks_files.samplesheet.without_header.tsv ]]; then
    ref="hg38"
    genome_sizes="/mnt/BioAdHoc/Groups/vd-ay/Database_HiChIP_eQTL_GWAS/Data/RefGenome/chrsize/hg38.chrom.sizes"
    
elif [[ "$samplesheet" == *mouse.peaks_files.samplesheet.without_header.tsv ]]; then
    ref="mm10"
    genome_sizes="/mnt/BioAdHoc/Groups/vd-ay/Database_HiChIP_eQTL_GWAS/Data/RefGenome/chrsize/mm10.chrom.sizes"

elif [[ "$samplesheet" == *human_t2t.peaks_files.samplesheet.without_header.tsv ]]; then
    ref="t2t-chm13-v2.0"
    genome_sizes="/mnt/bioadhoc-temp/Groups/vd-ay/kfetter/hichip-db-loop-calling/ref_genome/chm13_refgenome/chrsize/chm13.chrom.sizes"
else
    echo "This run will fail because the samplesheet path is not expected. Check conditions above."
fi
echo "ref: $ref"
echo "genome_sizes: $genome_sizes"

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
        genome_sizes=$4   
        
        # skip if merged (currently these are being debugged)
        if [[ "$peaks_file" == *merged_chipline* ]] && [[ "$peak_type" == "chipseq" ]]; then
            echo -e "\033[0;91m***** ${peak_type} peaks skipped *****\033[0m"
            echo "Currently skipped merged peaks due to chromosome size issues"
            return
        fi
        
        # convert the samples to bigBed
        if [ -f "$peaks_file" ]; then
        
            echo -e "\033[0;92m***** ${peak_type} peaks found *****\033[0m"

            echo "peaks_file: $peaks_file"
            
            # create a sorted intermediate file
            echo -e "\n# create a sorted intermediate file"

            interm_file="results/visualizations/washu/${peak_type}_peaks/${sample_name}.${peak_type}.peaks.txt"
            cat $peaks_file | grep ^chr | sort -k1,1 -k2,2n | cut -f 1,2,3 > $interm_file

            echo "interm_file: $interm_file"

            # convert to bigBed
            echo -e "\n# convert to bigBed"
            outfile="results/visualizations/washu/${peak_type}_peaks/${sample_name}.${peak_type}.peaks.bed.bb"
            convert_to_bigBed $interm_file $genome_sizes $outfile

            echo "outfile: $outfile"
            
            # remove the interm file
            rm $interm_file
            
        else
            echo -e "\033[0;91m***** ${peak_type} peaks NOT found *****\033[0m"
            echo "${sample_name} does not have an associated ${peak_type} peaks file"
        fi
}

echo 

# Convert HiChIP-Peaks peaks
hp_peaks_file=${sample_info[2]}
convert_to_bigBed_runner $sample_name "hichip-peaks" $hp_peaks_file $genome_sizes

echo 
  
# Convert FitHiChIP peaks
fp_peaks_file=${sample_info[3]}
convert_to_bigBed_runner $sample_name "fithichip" $fp_peaks_file $genome_sizes

echo 

# Convert Chip-Seq Peaks
cp_peaks_file=${sample_info[4]}
convert_to_bigBed_runner $sample_name "chipseq" $cp_peaks_file $genome_sizes


# print end message
echo "Ended: peaks_to_washu"

# print end time message
end_time=$(date "+%Y.%m.%d.%H.%M")
echo "End time: $end_time"
