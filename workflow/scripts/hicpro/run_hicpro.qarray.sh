#PBS -l nodes=1:ppn=1
#PBS -l mem=1gb
#PBS -l walltime=200:00:00
#PBS -e results/hicpro/logs/
#PBS -o results/hicpro/logs/
#PBS -N run_hicpro
#PBS -V

# Usage:
# Initially I wanted this script to work with a qsub array but 
# there are some technical issues I haven't figured out yet. For now
# we can use this script doing submitting each sample one by one:
# job_ids="1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 21 22 23 24 26 27 28 29 30 31 32 33 34 35 36 37 39 40 41 43 45 46 47 48 49 50 51 52 53 54 55"
# for i in $job_ids; do bash workflow/scripts/hicpro/run_hicpro.qarray.sh $i; done

# dummy pbs array environment values
#PBS_ARRAYID=42 # Ramos sample (only 6 million reads)
PBS_O_WORKDIR="/mnt/BioAdHoc/Groups/vd-ay/hichip-db-loop-calling"
PBS_ARRAYID=$1

# print start message
echo "Started: run_hicpro"

# run bash in strict mode
set -euo pipefail
IFS=$'\n\t'

# make sure to work starting from the base directory for this project 
cd $PBS_O_WORKDIR

# source tool paths
source workflow/source_paths.sh

# extract the sample information using the PBS ARRAYID
IFS=$'\t'
samplesheet="results/samplesheets/hicpro/current.hicpro.samplesheet.without_header.tsv"
sample_info=( $(cat $samplesheet | sed -n "${PBS_ARRAYID}p") )
sample_name="${sample_info[0]}"
geo_id="${sample_info[1]}"
re=$(echo ${sample_info[5]} | tr '[:upper:]' '[:lower:]')
IFS=$'\n\t'

# setting the config path. Make sure to include the proper reference files
# which requires:
#1) genome sizes = "results/refs/reference_genomes/RefGenome/chrsize/hg38.chrom.sizes"
#2) digestion file = ""
#3) bowtie2_indexes = "results/refs/reference_genomes/RefGenome/bowtie2_index/hg38/hg38"
config="config/hicpro/configfile.hg38.human.${re}.txt"

# printing run/sample information
echo
echo "Processing"
echo "----------"
echo "sample_name: $sample_name"
echo "geo_id: $geo_id"
echo "re: $re"
echo "config: $config"
echo

# make the output directory 
fastq_dir="results/fastqs/parallel/${sample_name}/"
data_dir="results/tmp/hicpro/${sample_name}/"
sample_dir="results/tmp/hicpro/${sample_name}/${sample_name}"
final_dir="results/hicpro/${sample_name}/"
mkdir -p $sample_dir

# softlink fastqs to a temporary directory
echo "# softlink fastqs to a temporary directory"
fastqs=$(ls $fastq_dir/*_R[12].fastq)
for fq in $fastqs;
do
    echo "Softlinking: $fq"
    ln -s -r -f $fq $sample_dir
done

# getting absolute paths for data and outdirs, required
# by HiCPro
abs_data_dir=$(readlink -f $data_dir)
abs_outdir=$(readlink -f $final_dir)
$hicpro \
    -p \
    -i $abs_data_dir/ \
    -o $abs_outdir/ \
    -c $config

# submit job 1 to the cluster
echo "# submit job 1 to the cluster"
cd $final_dir
step1_qids=$(qsub HiCPro_step1_.sh)
echo "HiCPro Step1 will run with qsub ID: $step1_qids"

# submit job 2 with dependency on job 1
# when a single fastq pair is present HiCPro won't use the array based 
# submission system for step1. This means the dependency qsub for step2
# has to be slightly changed.
echo "# submit job 2 with dependency on job 1"

if [[ "$step1_qids" == *"[]"* ]];
then
    # HiCPro with array based mode for step1
    echo "# HiCPro with array based mode for step1. qid=$step1_qids"
    step2_qids=$(qsub -W depend=afterokarray:$step1_qids HiCPro_step2_.sh)
else
    # HiCPro with single fastq pair mode for step1
    # Need to first remove host info from the step1 qid
    step1_qids_clean=$(echo $step1_qids | cut -f 1 -d .) 
    echo "# HiCPro with single fastq pair mode for step1. qid=$step1_qids_clean"
    step2_qids=$(qsub -W depend=afterok:$step1_qids_clean HiCPro_step2_.sh)
fi
echo "HiCPro Step2 is running with qsub ID: $step2_qids"

# print end message
echo "Ended: run_hicpro"
