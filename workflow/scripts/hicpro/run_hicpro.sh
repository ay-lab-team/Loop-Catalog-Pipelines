#PBS -l nodes=1:ppn=4
#PBS -l mem=20gb
#PBS -l walltime=200:00:00
#PBS -e results/fastqs/parallel/logs/
#PBS -o results/fastqs/parallel/logs/
#PBS -N download_srr_fastqs
#PBS -V

# dummy pbs array environment values
PBS_ARRAYID=42 # Ramos sample (only 6 million reads)
PBS_O_WORKDIR="/mnt/BioAdHoc/Groups/vd-ay/hichip-db-loop-calling"
#PBS_ARRAYID=$1

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
samplesheet="results/samplesheets/hicpro/2022.03.30-hichip-hicpro.without_header.tsv"
sample_info=( $(cat $samplesheet | sed -n "${PBS_ARRAYID}p") )
sample_name="${sample_info[0]}"
geo_id="${sample_info[1]}"
re=$(echo ${sample_info[4]} | tr '[:upper:]' '[:lower:]')

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
echo "# submit job 2 with dependency on job 1"
step2_qids=$(qsub -W depend=afterokarray:$step1_qids HiCPro_step2_.sh)
echo "HiCPro Step2 is running with qsub ID: $step2_qids"

# print end message
echo "Ended: run_hicpro"