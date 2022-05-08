#PBS -l nodes=1:ppn=4
#PBS -l mem=60gb
#PBS -l walltime=200:00:00
#PBS -e results/fastqs/chipseq/logs/
#PBS -o results/fastqs/chipseq/logs/
#PBS -N download_srr_fastqs_chipseq
#PBS -V

# example run:
# 1) qsub -t <index1>,<index2>,... workflow/scripts/download_srr_fastqs_chipseq.sh
# 2) qsub -t <index-range> workflow/scripts/download_srr_fastqs_chipseq.sh
# 3) qsub -t <index1>,<index2>,<index-range1> workflow/scripts/download_srr_fastqs_chipseq.sh
# 4) qsub -t <index-range1>,<index-range2>,... workflow/scripts/download_srr_fastqs_chipseq.sh
# 5) qsub -t <any combination of index + ranges> workflow/scripts/download_srr_fastqs_chipseq.sh

# dummy pbs array environment values
#PBS_ARRAYID=1
#PBS_O_WORKDIR="/mnt/BioAdHoc/Groups/vd-ay/hichip-db-loop-calling"

# print start time message
start_time=$(date "+%Y.%m.%d.%H.%M")
echo "Start time: $start_time"

# print start message
echo "Started: download_srr_fastqs_chipseq"

# run bash in strict mode
set -euo pipefail
IFS=$'\n\t'

# make sure to work starting from the base directory for this project 
cd $PBS_O_WORKDIR

# source tool paths
source workflow/source_paths.sh

# extract the sample information using the PBS ARRAYID
IFS=$'\t'
samplesheet="results/samplesheets/fastq/2022.05.08.chipseq_tracker.tsv"
sample_info=( $(cat $samplesheet | sed -n "${PBS_ARRAYID}p") )

# construct the name of the sample using the naming scheme:
# {sample_name}.{gse_id}.{organism}.{target of antibody}.b{biological_rep}
name="${sample_info[0]}"
gse_id="${sample_info[2]}"
organism="${sample_info[11]}"
target_of_antibody="${sample_info[15]}"
biological_rep="${sample_info[13]}"

# create convert to lowercase and replace spaces with underscores
sample_name="$name.$gse_id.$organism.$target_of_antibody.b$biological_rep"
sample_name=( echo "${sample_name,,}" )
sample_name="${sample_name// /_}"

srr_id="${sample_info[3]}"

# printing sample information
echo
echo "Processing"
echo "----------"
echo "sample_name: $sample_name"
echo "srr_id: $srr_id"
echo

# make the output directory 
outdir="results/fastqs/chipseq/$sample_name/"
mkdir -p $outdir

# run grabseqs
echo "# running grabseqs"
retries=8
threads=4
$grabseqs sra -o $outdir -r $retries -t $threads $srr_id

# print end message
echo "Ended: download_srr_fastqs_chipseq"

# print end time message
end_time=$(date "+%Y.%m.%d.%H.%M")
echo "End time: $end_time"