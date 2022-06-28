#PBS -l nodes=1:ppn=1
#PBS -l mem=40gb
#PBS -l walltime=100:00:00
#PBS -e results/loops/logs/
#PBS -o results/loops/logs/
#PBS -N run_hiccups
#PBS -V

# example run:
# 1) qsub -t <index1>,<index2>,... workflow/scripts/loops/run_hiccups.sh
# 2) qsub -t <index-range> workflow/scripts/loops/run_hiccups.sh
# 3) qsub -t <index1>,<index2>,<index-range1> workflow/scripts/loops/run_hiccups.sh
# 4) qsub -t <index-range1>,<index-range2>,... workflow/scripts/loops/run_hiccups.sh
# 5) qsub -t <any combination of index + ranges> workflow/scripts/loops/run_hiccups.sh

# print start time message
start_time=$(date "+%Y.%m.%d.%H.%M")
echo "Start time: $start_time"

# print start message
echo "Started: run_hiccups"

# run bash in strict mode
set -euo pipefail
IFS=$'\n\t'

# make sure to work starting from the github base directory for this script 
cd $PBS_O_WORKDIR

# source tool paths
source workflow/source_paths.sh

# extract the sample information using the PBS ARRAYID
samplesheet="results/samplesheets/post-hicpro/current-post-hicpro-without-header.tsv"
sample_info=( $(cat $samplesheet | sed -n "${PBS_ARRAYID}p") )
sample_name="${sample_info[0]}"

# printing sample information
echo
echo "Processing"
echo "----------"
echo "sample_name: $sample_name"
echo

# make the output directory 
outdir="results/loops/hiccups/threshold_200_10kb_loops/$sample_name/"
hic_outdir="results/loops/hiccups/threshold_200_10kb_loops/$sample_name/hic_input/"
mkdir -p $hic_outdir

# run hicpro2juicebox.sh
echo "# running hicpro2juicebox.sh to create .hic input file"
valid_pairs="results/hicpro/$sample_name/hic_results/data/$sample_name/$sample_name.allValidPairs"
$hicpro2juicebox -i $valid_pairs -g hg38 -j $juicertools -t $hic_outdir -o $hic_outdir

# print end message
echo "Ended: hicpro2juicebox"

# run hiccups
echo "# running hiccups"
inpdir="results/loops/hiccups/threshold_200_10kb_loops/$sample_name/hic_input/$sample_name.allValidPairs.hic"
java -Xmx40g -jar $juicertools hiccups --cpu --ignore-sparsity -r 5000,10000,25000 $inpdir $outdir

# print end message
echo "Ended: hiccups"

# print end time message
end_time=$(date "+%Y.%m.%d.%H.%M")
echo "End time: $end_time"
