#!/bin/sh
#SBATCH --job-name=run_distiller_nf
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=1g
#SBATCH --time=150:00:00
#SBATCH --output=results/revisions/distiller-nf/logs/job-%j.out
#SBATCH --error=results/revisions/distiller-nf/logs/job-%j.error

# print start time message
start_time=$(date "+%Y.%m.%d.%H.%M")
echo "Start time: $start_time"

# run bash in strict mode
set -euo pipefail
IFS=$'\n\t'

# make sure to work starting from the github base directory for this script 
cd $SLURM_SUBMIT_DIR

# extract the sample information using the ARRAYID
IFS=$'\t'
samplesheet="results/samplesheets/hicpro/revisions.top_45.hicpro.samplesheet.unmerged.all_batches.without_header.tsv"
sample_info=( $(cat $samplesheet | sed -n "${SLURM_ARRAY_TASK_ID}p") )
sample_name="${sample_info[0]}"
org="${sample_info[2]}"
IFS=$'\n\t'

# set-up new project
cp -r results/revisions/distiller-nf/distiller-nf_TEMPLATE results/revisions/distiller-nf/work/${sample_name}
outdir="results/revisions/distiller-nf/work/${sample_name}"
cd $outdir

# get correct cluster config file
if [[ "$org" == "Homo_Sapiens" ]];
then
    project_template="project_hg38_TEMPLATE.yml"
elif [[ "$org" == "Mus_Musculus" ]];
then
    project_template="project_mm10_TEMPLATE.yml"
else
    echo "config not found"
    exit
fi

# printing run/sample information
echo
echo "Processing"
echo "----------"
echo "sample_name: $sample_name"
echo "org: $org"
echo

# softlink fastqs to a sample directory with "_R"
fastq_dir="${SLURM_SUBMIT_DIR}/results/fastqs/raw/revisions/${sample_name}"
sample_fastq_dir="fastq/"
mkdir -p $sample_fastq_dir

echo "# softlink fastqs to the distiller-nf sample directory"
fastqs=$(ls $fastq_dir/*fastq.gz)
for fq in $fastqs;
do
    echo "Softlinking: $fq"
    link_base=$(basename $fq | sed 's/\(.*_\)\([12]\)\(.fastq.gz\)/\1R\2\3/')
    link_path="${sample_fastq_dir}/${link_base}"
    ln -s -r -f $fq $link_path
done
echo

# set-up project.yml file
echo "# create project.yml file" 
echo

project_file="project.yml"
echo "input:" >> $project_file
echo -e "    raw_reads_paths:" >> $project_file
echo -e "        ${sample_name}:" >> $project_file

find "fastq/" -name "*.fastq.gz" | sort -V | awk -v lane_number=1 -v curr_dir="$(pwd)/" '
{
    # Determine if its R1 or R2
    if (match($0, /_R1/)) {
        r1 = curr_dir $0
    } else if (match($0, /_R2/)) {
        r2 = curr_dir $0
    }

    # When both R1 and R2 are found, add them to the configuration
    if (r1 && r2) {
        print "            lane" lane_number ":"
        print "                - " r1
        print "                - " r2
        r1 = ""
        r2 = ""
        lane_number++
    }
}' >> $project_file

cat $project_template >> $project_file

# run distiller-nf
echo "# run distiller-nf" 

NXF_VER=22.10.7 nextflow run distiller.nf -params-file ${project_file} -profile cluster

# print end message
echo
echo "Ended: distiller-nf"
echo

# print end time message
end_time=$(date "+%Y.%m.%d.%H.%M")
echo "End time: $end_time"