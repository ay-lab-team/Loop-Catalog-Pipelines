#PBS -l nodes=1:ppn=1
#PBS -l mem=30gb
#PBS -l walltime=20:00:00
#PBS -e results/refs/logs/
#PBS -o results/refs/logs/
#PBS -N digest_reference_genome
#PBS -V

# example run:
# 1) qsub -F "<name of RE (lowercase)> <restriction site>" digest_reference_genome.sh

# path of files
output="/mnt/BioAdHoc/Groups/vd-ay/Database_HiChIP_eQTL_GWAS/Data/RefGenome/Restriction_Fragment/hg38/hg38_$1_digestion.bed"
ref_fasta="results/refs/reference_genomes/RefGenome/fasta/hg38/hg38.fa"

# path of softwares 
source config/config.sh
source workflow/source_paths.sh

# digest the genome
$hicpro_python $hicpro_digest -r $2 -o $output $ref_fasta