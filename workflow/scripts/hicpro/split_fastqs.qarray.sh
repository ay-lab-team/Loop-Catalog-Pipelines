#!/bin/sh
#SBATCH --job-name=split_fastqs
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=48g
#SBATCH --time=100:00:00
#SBATCH --output=results/fastqs/parallel/logs/job-%j.out
#SBATCH --error=results/fastqs/parallel/logs/job-%j.error

# # run bash in strict mode
set -euo pipefail
IFS=$'\n\t'

# source tool paths
source workflow/source_paths.sh

# dummy slurm array environment values
# dummy value when not running with sbatch
echo
if [[ -z ${SLURM_ARRAY_TASK_ID+x} ]]
then
    echo "Running with bash, setting SLURM_ARRAY_TASK_ID=\$1=$1"
    SLURM_ARRAY_TASK_ID=$1
    SLURM_SUBMIT_DIR="${LOOP_CATALOG_DIR}"
else
    echo "Running with sbatch, SLURM_ARRAY_TASK_ID=$SLURM_ARRAY_TASK_ID"
fi
echo

# print start time message
start_time=$(date "+%Y.%m.%d.%H.%M")
echo "Start time: $start_time"

# print start message
echo "Started: split_fastqs" 

# run bash in strict mode
set -euo pipefail
IFS=$'\n\t'

# make sure to work starting from the base directory for this project 
cd $SLURM_SUBMIT_DIR

# extract the sample information using the slurm ARRAYID
IFS=$'\t'
samplesheet="results/samplesheets/hicpro/current.hicpro.samplesheet.monocyte.without_header.tsv"
#samplesheet="results/samplesheets/hicpro/correct.pieqtl.010724.txt"
sample_info=( $(cat $samplesheet | sed -n "${SLURM_ARRAY_TASK_ID}p") )
sample_name="${sample_info[0]}"
#geo_id="${sample_info[1]}"
IFS=$'\n\t' # can go back to using \n\t

# printing sample information
echo
echo "Processing"
echo "----------"
echo "sample_name: $sample_name"
#echo "geo_id: $geo_id"
echo

# make the output directory 
fastqfolder="results/fastqs/raw/pieQTL_Samples_Correct/${sample_name}/"
outdir="results/fastqs/parallel/${sample_name}/"
mkdir -p $outdir

# run split_reads
echo "# running split_reads"
for fq in $fastqfolder/*.fastq.gz;
do
    echo "Splitting: $fq"
    $hicpro_python $split_reads --results_folder $outdir --nreads 50000000 $fq
done

# softlink files with R1/R2 designation rather than 1/2 only (found bugs with this method)
echo "# softlink files with R1/R2 designation"

fqs=$(ls $outdir/*.fastq)
for fq in $fqs;
do
    #link_base=$(basename $fq | sed "s/\(.*_SRR.*_\)\([12]\)\(_trimmed_[35]_prime\)\(.fastq\)/\1R\2\3/")
    #link_base=$(basename $fq | sed "s/\(.*_SRR.*_\)\([12]\)\(_trimmed\)\(.fastq\)/\1R\2\3\4/")
    link_base=$(basename $fq | sed "s/\(.*_SRR.*_\)\([12]\)\(.fastq\)/\1R\2\3/")
    link_path="$(dirname $fq)/$link_base"
    ln -f -s -r $fq $link_path
done

# print end message
echo "Ended: split_fastqs"

# print end time message
end_time=$(date "+%Y.%m.%d.%H.%M")
echo "End time: $end_time"