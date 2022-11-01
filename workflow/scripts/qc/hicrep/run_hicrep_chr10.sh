#PBS -l nodes=1:ppn=1
#PBS -l mem=7gb
#PBS -l walltime=5:00:00
#PBS -e results/qc/hicrep/logs/
#PBS -o results/qc/hicrep/logs/
#PBS -N run_hicrep_chr10
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
echo "Started: run_hicrep_chr10"

# run bash in strict mode
set -euo pipefail
IFS=$'\n\t'

# make sure to work starting from the base directory for this project 
cd $PBS_O_WORKDIR

# source tool paths
source workflow/source_paths.sh

# extract the sample information using the PBS ARRAYID
IFS=$'\t'
samplesheet="results/samplesheets/post-hicpro/mouse_hicrep.samplesheet.without_header.tsv"
sample_info=( $(cat $samplesheet | sed -n "${PBS_ARRAYID}p") )
sample="${sample_info[2]}"
rep1="${sample_info[0]}"
rep2="${sample_info[1]}"
res=10

# printing sample information
echo
echo "Processing"
echo "----------"
echo "sample: $sample"
echo "rep1: $rep1"
echo "rep2: $rep2"
echo "resolution: $res"
echo "chr: 10"
echo

# get the output directory
b1=$(echo $rep1 | tail -c 3)
b2=$(echo $rep2 | tail -c 3) 
outdir="results/qc/hicrep/hicrep_output/$sample/${b1}_${b2}/"
mkdir -p $outdir

# get fastq file path for this SRR
cool1="results/qc/hicrep/cool_files/${rep1}/cool_input/cool_${res}000.cool"
cool2="results/qc/hicrep/cool_files/${rep2}/cool_input/cool_${res}000.cool"

# determine optimal h-value
echo "# running htrain"
hicreppy htrain -r 10 -m 100000 -w chr10 ${cool1} ${cool2} > ${outdir}/h_value_chr10_${res}.txt

HVAL=$(<${outdir}/h_value_chr10_${res}.txt)
echo "h-value: ${HVAL}"
echo

# run hicrep
echo "# running hicrep scc"
hicreppy scc -v ${HVAL} -m 100000 -w chr10 ${cool1} ${cool2} > ${outdir}/ssc_chr10_${res}.txt

# print end message
echo
echo "Ended: run_hicrep_chr10"

# print end time message
end_time=$(date "+%Y.%m.%d.%H.%M")
echo "End time: $end_time"