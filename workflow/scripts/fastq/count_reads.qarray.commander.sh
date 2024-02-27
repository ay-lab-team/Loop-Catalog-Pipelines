# running in bash
samplesheet="results/samplesheets/fastq/read_counts.v2.tsv"
bash workflow/scripts/fastq/count_reads.qarray.qsh $samplesheet 1

# submitting jobs
#samplesheet="results/samplesheets/fastq/read_counts.tsv"
#sbatch --export="samplesheet=$samplesheet" workflow/scripts/fastq/count_reads.qarray.qsh







