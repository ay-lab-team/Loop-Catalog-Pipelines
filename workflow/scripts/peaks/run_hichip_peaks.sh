#PBS -l nodes=1:ppn=1
#PBS -l mem=200gb
#PBS -l walltime=50:00:00
#PBS -e results/peaks/logs/
#PBS -o results/peaks/logs/
#PBS -N run_hichip_peaks
#PBS -V

# example run:
# 1) qsub -t <index1>,<index2>,... workflow/scripts/peaks/run_hichip_peaks.sh
# 2) qsub -t <index-range> workflow/scripts/peaks/run_hichip_peaks.sh
# 3) qsub -t <index1>,<index2>,<index-range1> workflow/scripts/peaks/run_hichip_peaks.sh
# 4) qsub -t <index-range1>,<index-range2>,... workflow/scripts/peaks/run_hichip_peaks.sh
# 5) qsub -t <any combination of index + ranges> workflow/scripts/peaks/run_hichip_peaks.sh

# print start time message
start_time=$(date "+%Y.%m.%d.%H.%M")
echo "Start time: $start_time"

# print start message
echo "Started: hichip-peaks"

# run bash in strict mode
set -euo pipefail
IFS=$'\n\t'

# make sure to work starting from the github base directory for this script 
cd $PBS_O_WORKDIR
work_dir=$PBS_O_WORKDIR

# source tool paths
source workflow/source_paths.sh

# extract the sample information using the PBS ARRAYID
IFS=$'\t'
samplesheet="results/samplesheets/post-hicpro/current-post-hicpro-without-header.tsv"
sample_info=( $(cat $samplesheet | sed -n "${PBS_ARRAYID}p") )
sample_name="${sample_info[0]}"
re=$(echo ${sample_info[5]} | tr '[:upper:]' '[:lower:]')
org="${sample_info[2]}"
IFS=$'\n\t'

# printing sample information
echo
echo "Processing"
echo "----------"
echo "sample_name: $sample_name"
echo "re: $re"
echo "org: $org"
echo

# make the output directory 
outdir="results/peaks/hichip-peaks/$sample_name/"
mkdir -p $outdir

# get other parameters
hicpro_dir="results/hicpro/$sample_name/hic_results/data/$sample_name"

if [[ "$org" == "Homo_Sapiens" ]];
then
    resfrag="/mnt/BioAdHoc/Groups/vd-ay/Database_HiChIP_eQTL_GWAS/Data/RefGenome/Restriction_Fragment/hg38/hg38_${re}_digestion.bed"
    chrsizes="/mnt/BioAdHoc/Groups/vd-ay/Database_HiChIP_eQTL_GWAS/Data/RefGenome/chrsize/hg38.chrom.sizes"
elif [[ "$org" == "Mus_Musculus" ]];
then
    resfrag="/mnt/BioAdHoc/Groups/vd-ay/Database_HiChIP_eQTL_GWAS/Data/RefGenome/Restriction_Fragment/mm10/mm10_${re}_digestion.bed"
    chrsizes="/mnt/BioAdHoc/Groups/vd-ay/Database_HiChIP_eQTL_GWAS/Data/RefGenome/chrsize/mm10.chrom.sizes"
else
    echo "valid org not found"
    exit
fi

# run hichip-peak calling
echo
echo "# running hichip-peaks"
$peak_call -i $hicpro_dir -o $outdir -r $resfrag -p 'out_' -f 0.01 -a $chrsizes --worker_threads 4 --keep_diff

# print end message
echo
echo "# Ended: hichip-peaks"

# print end time message
end_time=$(date "+%Y.%m.%d.%H.%M")
echo "End time: $end_time"