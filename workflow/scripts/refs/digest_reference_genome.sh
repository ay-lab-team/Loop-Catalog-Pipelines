#PBS -l nodes=1:ppn=1
#PBS -l mem=30gb
#PBS -l walltime=20:00:00
#PBS -e results/refs/logs/
#PBS -o results/refs/logs/
#PBS -N digest_reference_genome
#PBS -V

# example run:
# 1) qsub -F "<name of RE (lowercase)> <restriction site>" digest_reference_genome.sh

# run bash in strict mode
set -euo pipefail
IFS=$'\n\t'

# make sure to work starting from the base directory for this project 
cd $PBS_O_WORKDIR

# path of files
output="/mnt/BioAdHoc/Groups/vd-ay/Database_HiChIP_eQTL_GWAS/Data/RefGenome/Restriction_Fragment/hg38/hg38_${1}_digestion.bed"
ref_fasta="results/refs/reference_genomes/RefGenome/fasta/hg38/hg38.fa"

# path of softwares 
source workflow/source_paths.sh

# digest the genome
$hicpro_python $hicpro_digest -r ${@:2} -o $output $ref_fasta