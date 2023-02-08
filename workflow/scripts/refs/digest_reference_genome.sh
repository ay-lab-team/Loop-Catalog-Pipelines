#PBS -l nodes=1:ppn=1
#PBS -l mem=30gb
#PBS -l walltime=20:00:00
#PBS -e results/refs/logs/
#PBS -o results/refs/logs/
#PBS -N digest_reference_genome
#PBS -V

# example run:
# 1) qsub -F "<reference genome> <name of RE (lowercase, if multiple separate with dashes)> <restriction site(s)>" workflow/scripts/refs/digest_reference_genome.sh

# print start time message
start_time=$(date "+%Y.%m.%d.%H.%M")
echo "Start time: $start_time"

# print start message
echo "Started: digest_reference_genome"

# run bash in strict mode
set -euo pipefail
IFS=$'\n\t'

# make sure to work starting from the base directory for this project 
cd $PBS_O_WORKDIR

# path of softwares 
source workflow/source_paths.sh

echo
echo "genome: $1"
echo "start diesgtion for: $2"
echo "sites: ${@:3}"
echo

# output file
outdir="/mnt/bioadhoc-temp/Groups/vd-ay/kfetter/hichip-db-loop-calling/ref_genome/chm13_refgenome/restriction_fragment"
output="${outdir}/${1}_${2}_digestion.bed"

# reference genome file
# use for human
ref_fasta="/mnt/bioadhoc-temp/Groups/vd-ay/kfetter/hichip-db-loop-calling/ref_genome/chm13_refgenome/fasta/chm13.fa"
# Use for mouse mm10:
#ref_fasta="/mnt/BioAdHoc/Groups/vd-ay/Database_HiChIP_eQTL_GWAS/Data/RefGenome/fasta/mm10/GRCm38.P6.primary_assembly.genome.fa"

# digest the genome
$hicpro_python $hicpro_digest -r ${@:3} -o $output $ref_fasta

# print end message
echo
echo "Ended: digest_reference_genome"
echo

# print end time message
end_time=$(date "+%Y.%m.%d.%H.%M")
echo "End time: $end_time"