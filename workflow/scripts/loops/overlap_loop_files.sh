#PBS -l nodes=1:ppn=1
#PBS -l mem=30gb
#PBS -l walltime=20:00:00
#PBS -e results/loops/logs/
#PBS -o results/loops/logs/
#PBS -N overlap_loop_files
#PBS -V

# example run:
# 1) qsub -F "<sample_name>" workflow/scripts/loops/overlap_loop_files.sh

# print start time message
start_time=$(date "+%Y.%m.%d.%H.%M")
echo "Start time: $start_time"

# print start message
echo "Started: overlap_loop_files"

# run bash in strict mode
set -euo pipefail
IFS=$'\n\t'

# make sure to work starting from the base directory for this project 
cd $PBS_O_WORKDIR

# path of softwares 
source workflow/source_paths.sh

# input file
sample_name=${1}
f1="${LOOP_CATALOG_DIR}/results/loops/hiccups"
f2="${LOOP_CATALOG_DIR}/results/loops/hiccups_vc"

# output file
outdir="${LOOP_CATALOG_DIR}/results/loops/overlaps/hiccups_vc_kr"

# find overlaps
for res in 5000 10000 25000; 
do
    output="${outdir}/${sample_name}_${res}_overlaps.bed"
    bedtools pairtopair -a "${f1}/${sample_name}/postprocessed_pixels_${res}.bedpe" -b "${f2}/${sample_name}/postprocessed_pixels_${res}.bedpe" > $output
done

# print end message
echo
echo "Ended: overlap_loop_files"
echo

# print end time message
end_time=$(date "+%Y.%m.%d.%H.%M")
echo "End time: $end_time"