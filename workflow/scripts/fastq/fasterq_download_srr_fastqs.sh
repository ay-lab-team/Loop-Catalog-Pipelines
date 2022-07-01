#PBS -l nodes=1:ppn=4
#PBS -l mem=80gb
#PBS -l walltime=100:00:00
#PBS -e results/fastqs/raw/logs/
#PBS -o results/fastqs/raw/logs/
#PBS -N fasterq_download_srr_fastqs
#PBS -V

#########################################################################################

# This script uses NCBI's SRA Toolkit utilities to download fastq files. No additional
# materials are needed except for the most current fastq samplesheet. 

# qsub -t <indicies from fastq samplesheet>%4 workflow/scripts/fastqs/fasterq_download_srr_fastqs.sh

########################################################################################

# run bash in strict mode
set -euo pipefail
IFS=$'\n\t'

# print start time message
start_time=$(date "+%Y.%m.%d.%H.%M")
echo "Start time: $start_time"

# print start message
echo "Started: fasterq_download_srr_fastqs"

# run bash in strict mode
set -euo pipefail
IFS=$'\n\t'

# make sure to work starting from the base directory for this project 
cd $PBS_O_WORKDIR

# source tool paths
source workflow/source_paths.sh

# extract the sample information using the PBS ARRAYID
IFS=$'\t'
samplesheet="results/samplesheets/fastq/Current-HiChIP-SRR-Samplesheet-Without-Header.tsv"
sample_info=( $(cat $samplesheet | sed -n "${PBS_ARRAYID}p") )
sample_name="${sample_info[0]}"
srr_id="${sample_info[3]}"

# printing sample information
echo
echo "Processing"
echo "----------"
echo "sample_name: $sample_name"
echo "srr_id: $srr_id"
echo

# make the output directory 
outdir="results/fastqs/raw/$sample_name/"
mkdir -p $outdir

# prefetch sra file
echo "# prefetching .sra file"
$prefetch $srr_id --max-size u -O $outdir

# use fasterq-dump to extract the fastq file
echo "# extracting fastqs via fasterq-dump"
cd $outdir
$fasterq_dump $srr_id

# zip fastq files
echo "# zipping fastq files"
$pigz ${srr_id}_1.fastq
$pigz ${srr_id}_2.fastq

# remove SRR folder created by prefetch
echo "# removing SRR folder created by prefetch"
rm -r "${srr_id}/"

# print end message
echo
echo "Ended: fasterq_download_srr_fastqs"

# print end time message
end_time=$(date "+%Y.%m.%d.%H.%M")
echo "End time: $end_time"