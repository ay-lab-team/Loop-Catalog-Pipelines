#PBS -l nodes=1:ppn=1
#PBS -l mem=20gb
#PBS -l walltime=10:00:00
#PBS -e results/qc/fastqc/logs/
#PBS -o results/qc/fastqc/logs/
#PBS -N fastqc_report
#PBS -V

#########################################################################################

# This script uses Babraham Bioinformatics' fastqc tool to generate a QC report for raw,
# unprocessed fastq files (https://www.bioinformatics.babraham.ac.uk/projects/fastqc/) 

# qsub -t <indicies from fastq samplesheet>%50 workflow/scripts/qc/fastqc_report.sh

########################################################################################

# run bash in strict mode
set -euo pipefail
IFS=$'\n\t'

# print start time message
start_time=$(date "+%Y.%m.%d.%H.%M")
echo "Start time: $start_time"

# print start message
echo "Started: fastqc_report"

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
outdir="results/qc/fastqc/$sample_name/"
mkdir -p $outdir

# get fastq file path for this SRR
r1="results/fastqs/raw/${sample_name}/${srr_id}_1.fastq.gz"
r2="results/fastqs/raw/${sample_name}/${srr_id}_2.fastq.gz"

# prefetch sra file
echo "# running fastqc"
fastqc $r1 $r2 -o $outdir --noextract

# print end message
echo
echo "Ended: fastqc_report"

# print end time message
end_time=$(date "+%Y.%m.%d.%H.%M")
echo "End time: $end_time"