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
samplesheet="results/samplesheets/hicpro/Current-HiChIP-Samplesheet.tsv"
sample_info=( $(cat $samplesheet | sed -n "${PBS_ARRAYID}p") )
sample_name="${sample_info[0]}"
srr_id="${sample_info[3]}"
re="${sample_info[4]}"

# printing sample information
echo
echo "Processing"
echo "----------"
echo "sample_name: $sample_name"
echo "srr_id: $srr_id"
echo

# setting the config path. Make sure to include the proper reference files
# which requires:
#1) genome sizes = "results/refs/reference_genomes/RefGenome/chrsize/hg38.chrom.sizes"
#2) digestion file = ""
#3) bowtie2_indexes = "results/refs/reference_genomes/RefGenome/bowtie2_index/hg38/hg38"
config="config/hicpro/configfile.hg38.human.mboi.txt"

# make the output directory 
datadir="results/fastq/${sample_name}/parallel/"
fastq_dir="results/fastqs/parallel/${sample_name}/"
tempdir="results/temp/hicpro/${sample_name}/"
outdir="results/hicpro/${sample_name}/"
mkdir -p $tempdir $outdir

qsubs_written="results/main/{cline}/hicpro_with_parallel/qsubs.written"

# softlink fastqs to a temporary directory
fastqs=$(ls
for fq in $fastqs;
do
    ln -s -r $fq $tempdir
done

# getting absolute paths for data and outdirs, required
# by HiCPro
abs_datadir=$(readlink -f $tempdir)
abs_outdir=$(readlink -f $outdir)

# running with setting -s so that it runs only the alignment
# pipeline (default settings), qsub jobs are automatically submitted
echo "# running with setting -s so that it runs only the alignment" >> {log} 2>&1
$hicpro \
    -p \
    -i $abs_datadir \
    -o $abs_outdir \
    -c $config


# print end message
echo "Ended: run_hicpro"
