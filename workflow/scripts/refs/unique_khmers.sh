#PBS -l nodes=1:ppn=1
#PBS -l mem=30gb
#PBS -l walltime=20:00:00
#PBS -e results/refs/logs/
#PBS -o results/refs/logs/
#PBS -N unique_khmers
#PBS -V

# example run:
# 1) qsub -F "<reference genome>" workflow/scripts/refs/unique_khmers.sh

# print start time message
start_time=$(date "+%Y.%m.%d.%H.%M")
echo "Start time: $start_time"

# print start message
echo "Started: unique_khmers"

# run bash in strict mode
set -euo pipefail
IFS=$'\n\t'

# make sure to work starting from the base directory for this project 
cd $PBS_O_WORKDIR

# path of softwares 
source workflow/source_paths.sh

echo
echo "genome: $1"
echo

# output file
outdir="${LOOP_CATALOG_DIR}/results/refs/effective_genome_size"

# reference genome file
# use for human chm13
#ref_fasta="${LOOP_CATALOG_DIR}/ref_genome/chm13_refgenome/fasta/chm13v2.0.fa.gz"
# use for human hg38
#ref_fasta="${Database_HiChIP_eQTL_GWAS}/Data/RefGenome/fasta/hg38/hg38.fa"
# Use for mouse mm10:
ref_fasta="${Database_HiChIP_eQTL_GWAS}/Data/RefGenome/fasta/mm10/GRCm38.P6.primary_assembly.genome.fa"

# find unque khmers
#zcat ${ref_fasta} > "${outdir}/chm13.fa"
for size in 50 75 100 150;
do
    output="${outdir}/${1}_${size}_genome_size.txt"
    unique-kmers.py -k ${size} -R "${1}_${size}_report.txt" $ref_fasta > $output
done
#rm "${outdir}/chm13.fa"

# print end message
echo
echo "Ended: unique_khmers"
echo

# print end time message
end_time=$(date "+%Y.%m.%d.%H.%M")
echo "End time: $end_time"