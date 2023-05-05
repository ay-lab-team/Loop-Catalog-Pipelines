#PBS -l nodes=1:ppn=1
#PBS -l mem=7gb
#PBS -l walltime=5:00:00
#PBS -e results/qc/hicrep/logs/
#PBS -o results/qc/hicrep/logs/
#PBS -N run_htrain
#PBS -V

#########################################################################################

# This script uses the python implementation of HiC-Rep (https://github.com/cmdoret/hicreppy) 

# qsub -t <indicies from hicpro samplesheet>%50 workflow/scripts/qc/hicrep/run_hicrep.sh

########################################################################################

# run bash in strict mode
set -euo pipefail
IFS=$'\n\t'

# print start time message
start_time=$(date "+%Y.%m.%d.%H.%M")
echo "Start time: $start_time"

# print start message
echo "Started: run_htrain"

# run bash in strict mode
set -euo pipefail
IFS=$'\n\t'

# make sure to work starting from the base directory for this project 
cd $PBS_O_WORKDIR

# source tool paths
source workflow/source_paths.sh

# extract the sample information using the PBS ARRAYID
IFS=$'\t'
samplesheet="results/samplesheets/post-hicpro/human_hicrep_04_27_23.samplesheet.without_header.tsv"
sample_info=( $(cat $samplesheet | sed -n "${PBS_ARRAYID}p") )
sample="${sample_info[2]}"
rep1="${sample_info[0]}"
rep2="${sample_info[1]}"
res=5

# printing sample information
echo
echo "Processing"
echo "----------"
echo "sample: $sample"
echo "rep1: $rep1"
echo "rep2: $rep2"
echo "resolution: $res"
echo

# get the output directory 
b1=$(echo $rep1 | tail -c 3)
b2=$(echo $rep2 | tail -c 3)

# get cool file path
cool1="results/qc/hicrep/cool/${rep1}/${res}000.cool"
cool2="results/qc/hicrep/cool/${rep2}/${res}000.cool"

# determine optimal h-value
echo "# running htrain"

hicreppy htrain -r 5 -m 100000 -w chr1,chr10,chr17,chr19 ${cool1} ${cool2} > "results/qc/hicrep/tmp/${rep1}_${rep2}.txt"
HVAL=$(<results/qc/hicrep/tmp/${rep1}_${rep2}.txt)

echo "$sample   ${HVAL}" >> "results/qc/hicrep/human_hg38_htrain_samplesheet_050523.txt"

# print end message
echo
echo "Ended: run_htrain"

# print end time message
end_time=$(date "+%Y.%m.%d.%H.%M")
echo "End time: $end_time"