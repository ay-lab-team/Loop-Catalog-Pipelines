#PBS -l nodes=1:ppn=1
#PBS -l mem=20gb
#PBS -l walltime=10:00:00
#PBS -e results/qc/
#PBS -o results/qc/
#PBS -N check_r1_r2_lengths
#PBS -V

# run bash in strict mode
set -euo pipefail
IFS=$'\n\t'

# print start time message
start_time=$(date "+%Y.%m.%d.%H.%M")
echo "Start time: $start_time"

# print start message
echo "Started: check_r1_r2_lengths"

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

# get fastq file path for this SRR
r1="results/fastqs/raw/${sample_name}/${srr_id}_1.fastq.gz"
r2="results/fastqs/raw/${sample_name}/${srr_id}_2.fastq.gz"

# get read length by counting length of line 2 of one fastq file
r1_length=$(zcat $r1 | sed -n "2p" | awk '{print length}')
r2_length=$(zcat $r2 | sed -n "2p" | awk '{print length}')

echo "r1 length: $r1_length"
echo "r2 length: $r2_length"

# print end message
echo
echo "Ended: check_r1_r2_lengths"

# print end time message
end_time=$(date "+%Y.%m.%d.%H.%M")
echo "End time: $end_time"