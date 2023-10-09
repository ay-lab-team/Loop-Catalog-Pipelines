#PBS -l nodes=1:ppn=1
#PBS -l mem=10gb
#PBS -l walltime=30:00:00
#PBS -e biorep_merged/results/hicpro/logs
#PBS -o biorep_merged/results/hicpro/logs
#PBS -N merge_validpairs
#PBS -V

# run bash in strict mode
set -euo pipefail
IFS=$'\n\t'

# print start time message
start_time=$(date "+%Y.%m.%d.%H.%M")
echo "Start time: $start_time"

# print start message
echo "Started: merge_validpairs"

# make sure to work starting from the base directory for this project 
cd $PBS_O_WORKDIR

# source tool paths
source workflow/source_paths.sh

# extract the sample information using the PBS ARRAYID
#IFS=$'\t'
samplesheet="results/samplesheets/post-hicpro/mouse.biorep_merged.initial.samplesheet.without_header.tsv"
sample_info=( $(cat $samplesheet | sed -n "${PBS_ARRAYID}p") )
sample_name="${sample_info[0]}"

# printing sample information
echo
echo "Processing"
echo "----------"
echo "sample_name: $sample_name"
echo

# make the output directory 
outdir="biorep_merged/results/hicpro/${sample_name}.biorep_merged"
mkdir -p $outdir

# concatenate validpairs files
cat results/hicpro/${sample_name}.*/hic_results/data/*/*.DEPairs >> "${outdir}/${sample_name}.biorep_merged.DEPairs"
cat results/hicpro/${sample_name}.*/hic_results/data/*/*.SCPairs >> "${outdir}/${sample_name}.biorep_merged.SCPairs"
cat results/hicpro/${sample_name}.*/hic_results/data/*/*.REPairs >> "${outdir}/${sample_name}.biorep_merged.REPairs"

# print end message
echo
echo "Ended: merge_validpairs"

# print end time message
end_time=$(date "+%Y.%m.%d.%H.%M")
echo "End time: $end_time"