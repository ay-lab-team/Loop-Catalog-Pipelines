#PBS -l mem=4gb
#PBS -l nodes=1:ppn=1
#PBS -l walltime=00:50:00
#PBS -o results/shortcuts/log_hiccups_final/
#PBS -e results/shortcuts/log_hiccups_final/
#PBS -N interactions_to_bigInteract
# -t 1
# -d .

set -euo pipefail
IFS=$'\n\t'

# to run the code from bash use:
# bash interactions_to_bigInteract.qarray.qsh 3

# to run the code from Qsub use:
# qsub interactions_to_bigInteract.qarray.qsh -t 3

# allow this script to be run without qsub by assigning PBS_ARRAYID from
# # the command line using $1
if [ -z "${PBS_ARRAYID+x}" ]
then
  PBS_ARRAYID=$1
  PBS_O_WORKDIR="."
fi

# defining a named array for the chromsize files
hg38_chromsize="/mnt/BioAdHoc/Groups/vd-ay/Database_HiChIP_eQTL_GWAS/Data/RefGenome/chrsize/hg38.chrom.sizes"
mm10_chromsize="/mnt/BioAdHoc/Groups/vd-ay/Database_HiChIP_eQTL_GWAS/Data/RefGenome/chrsize/mm10.chrom.sizes"
t2t_chromsize="/mnt/bioadhoc-temp/Groups/vd-ay/kfetter/hichip-db-loop-calling/ref_genome/chm13_refgenome/chrsize/chm13.chrom.sizes"
declare -A chromsizes=(
  ["hg38"]="$hg38_chromsize"
  ["mm10"]="$mm10_chromsize"
  ["t2t-chm13-v2.0"]="$t2t_chromsize"
)

# extracting the input file name
info=$(sed -n ${PBS_ARRAYID}p workflow/scripts/visualizations/biginter/samplesheets/samplesheet.hiccups.wc.txt)
echo $info
input=$(echo $info | cut -d " " -f 1)
num_loops=$(echo $info | cut -d " " -f 2)

echo "$info"

if [[ $num_loops -lt 1]]
then
  echo "No loops found for $input"
  exit 0
fi

# extract the genome from the input file name
ref=$(echo $input | cut -d "/" -f 3)
chromsize="${chromsizes[$ref]}"
echo $ref

# defining a list of input variables
output=$(echo $input | sed 's/bed$/interaction.bb/')
autosql="results/refs/ucsc/interact.autoSql.txt"
type="hiccups"
bedToBigBed="/mnt/BioAdHoc/Groups/vd-ay/kfetter/packages/ucsc_genome_browser/bedToBigBed"

echo "input: $input"
echo "output: $output"
echo "chromsize: $chromsize"
echo "autosql: $autosql"
echo "type: $type"

# running the interact_to_bigbed.py script
echo 'running the interact_to_bigbed.py script'
cmd="/mnt/bioadhoc-temp/Groups/vd-ay/rignacio/Scripts/Library/miniconda3/miniconda3/bin/python3.10 \
  workflow/scripts/visualizations/biginter/interactions_to_bigInteract.py \
    --input-file $input \
		--output-file $output \
    --chromsize $chromsize \
    --autosql $autosql \
    --type $type \
    --bedToBigBed $bedToBigBed"
echo "Running: $cmd"
eval $cmd