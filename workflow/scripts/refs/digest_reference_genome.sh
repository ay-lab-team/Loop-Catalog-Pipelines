# path of files
output="results/refs/restriction_enzyme/hg38.hicpro.arima.txt"
ref_fasta="results/refs/reference_genomes/RefGenome/fasta/hg38/hg38.fa"

# path of softwares 
source config/config.sh

# make the output directory 
outdir=$(dirname $output)
mkdir -p $outdir

# digest the genome
python $hicpro_digest \
            -r ^GATC G^ANTC \
            -o $output \
            $ref_fasta
