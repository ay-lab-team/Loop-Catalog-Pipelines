# running in bash
samplesheet="results/samplesheets/fastq/read_counts.v2.tsv"
#bash workflow/scripts/fastq/count_reads.qarray.qsh $samplesheet 1

# submitting jobs
samplesheet="results/samplesheets/fastq/read_counts.v2.tsv"
#sbatch --array=1 --export=samplesheet=$samplesheet workflow/scripts/fastq/count_reads.qarray.qsh
sbatch --array="2-556" --export="samplesheet=$samplesheet" workflow/scripts/fastq/count_reads.qarray.qsh







