#!/bin/sh
#SBATCH --job-name=run_juicer
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=1g
#SBATCH --time=1:00:00
#SBATCH --output=results/revisions/juicer/logs/job-%j.out
#SBATCH --error=results/revisions/juicer/logs/job-%j.error

# # run bash in strict mode
set -euo pipefail
IFS=$'\n\t'

# dummy slurm array environment values
# dummy value when not running with sbatch
echo
if [[ -z ${SLURM_ARRAY_TASK_ID+x} ]]
then
    echo "Running with bash, setting SLURM_ARRAY_TASK_ID=\$1=$1"
    SLURM_ARRAY_TASK_ID=$1
    SLURM_SUBMIT_DIR="/mnt/BioAdHoc/Groups/vd-ay/kfetter/hichip-db-loop-calling"
else
    echo "Running with sbatch, SLURM_ARRAY_TASK_ID=$SLURM_ARRAY_TASK_ID"
fi
echo

# print start message
echo "Started: run_juicer"

# run bash in strict mode
set -euo pipefail
IFS=$'\n\t'

# make sure to work starting from the base directory for this project 
cd $SLURM_SUBMIT_DIR

# source tool paths
source workflow/source_paths.sh

# extract the sample information using the PBS ARRAYID
IFS=$'\t'
samplesheet="results/samplesheets/hicpro/revisions.top_45.hicpro.samplesheet.unmerged.all_batches.without_header.tsv"
sample_info=( $(cat $samplesheet | sed -n "${SLURM_ARRAY_TASK_ID}p") )
sample_name="${sample_info[0]}"
org="${sample_info[2]}"
#re=$(echo ${sample_info[5]} | tr '[:upper:]' '[:lower:]')
re=${sample_info[5]}
IFS=$'\n\t'

# set genome and chrom sizes files based on org
if [[ "$org" == "Homo_Sapiens" ]];
then
    genome="hg38"
    chrom_sizes="/mnt/BioAdHoc/Groups/vd-ay/Database_HiChIP_eQTL_GWAS/Data/RefGenome/chrsize/hg38.chrom.sizes"
    ref_genome_file="/mnt/BioAdHoc/Groups/vd-ay/kfetter/hichip-db-loop-calling/results/revisions/juicer/references/hg38/hg38.fa"
elif [[ "$org" == "Mus_Musculus" ]];
then
    genome="mm10"
    chrom_sizes="/mnt/BioAdHoc/Groups/vd-ay/Database_HiChIP_eQTL_GWAS/Data/RefGenome/chrsize/mm10.chrom.sizes"
    ref_genome_file="/mnt/BioAdHoc/Groups/vd-ay/kfetter/hichip-db-loop-calling/results/revisions/juicer/references/mm10/mm10.fa"
else
    echo "org not found"
    exit
fi

# printing run/sample information
echo
echo "Processing"
echo "----------"
echo "sample_name: $sample_name"
echo "re: $re"
echo "org: $org"
echo

# make the output directory 
fastq_dir="/mnt/BioAdHoc/Groups/vd-ay/kfetter/hichip-db-loop-calling/results/fastqs/raw/revisions/${sample_name}"
final_dir="/mnt/BioAdHoc/Groups/vd-ay/kfetter/hichip-db-loop-calling/results/revisions/juicer/work/${sample_name}"
sample_fastq_dir="${final_dir}/fastq/"
mkdir -p $sample_fastq_dir

# softlink fastqs to a sample directory with "_R"
echo "# softlink fastqs to the juicer sample directory"
fastqs=$(ls $fastq_dir/*fastq.gz)
for fq in $fastqs;
do
    echo "Softlinking: $fq"
    link_base=$(basename $fq | sed 's/\(.*_\)\([12]\)\(.fastq.gz\)/\1R\2\3/')
    link_path="${sample_fastq_dir}/${link_base}"
    ln -s -r -f $fq $link_path
done
echo

# run juicer
echo "# Running Juicer"
echo 
juicer_dir="/mnt/BioAdHoc/Groups/vd-ay/kfetter/hichip-db-loop-calling/results/revisions/juicer"

if [[ "$re" == "MNase" ]];
then
    ${juicer_dir}/scripts/juicer.sh -d $final_dir -p $chrom_sizes -s none -z $ref_genome_file -C 50000000 -D $juicer_dir -q compute -l compute --assembly
else
    site_option="/mnt/BioAdHoc/Groups/vd-ay/hichip-db-loop-calling/results/revisions/juicer/restriction_sites/${genome}_${re}.txt"
    ${juicer_dir}/scripts/juicer.sh -d $final_dir -p $chrom_sizes -s ${re} -y $site_option -z $ref_genome_file -C 50000000 -D $juicer_dir -q compute -l compute -f --assembly
fi

# print end message
echo "Ended: run_juicer"