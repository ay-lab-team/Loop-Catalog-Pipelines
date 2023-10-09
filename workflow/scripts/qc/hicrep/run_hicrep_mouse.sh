#PBS -l nodes=1:ppn=1
#PBS -l mem=25gb
#PBS -l walltime=5:00:00
#PBS -e results/qc/hicrep/logs/
#PBS -o results/qc/hicrep/logs/
#PBS -N run_hicrep_mouse
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
echo "Started: run_hicrep_mouse"

# run bash in strict mode
set -euo pipefail
IFS=$'\n\t'

# make sure to work starting from the base directory for this project 
cd $PBS_O_WORKDIR

# source tool paths
source workflow/source_paths.sh

# extract the sample information using the PBS ARRAYID
IFS=$'\t'
samplesheet="results/samplesheets/post-hicpro/mouse_hicrep_04_27_23.samplesheet.without_header.tsv"
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
echo "chr: 1"
echo

# get the output directory 
b1=$(echo $rep1 | tail -c 3)
b2=$(echo $rep2 | tail -c 3)
outdir="results/qc/hicrep/scc/$sample/"
mkdir -p $outdir

# get fastq file path for this SRR
cool1="results/qc/hicrep/cool/${rep1}/${res}000.cool"
cool2="results/qc/hicrep/cool/${rep2}/${res}000.cool"

# run hicrep
echo "# running hicrep scc"
sample_values=( $(grep "${sample}" "results/samplesheets/post-hicpro/mouse_hicrep_htrain_050723.txt") )
HVAL=${sample_values[1]}
echo $HVAL
hicreppy scc -v ${HVAL} -m 100000 -w chr1,chr10,chr17,chr19 ${cool1} ${cool2} > ${outdir}/ssc_${res}_${b1}_${b2}.txt

# print end message
echo
echo "Ended: run_hicrep_mouse"

# print end time message
end_time=$(date "+%Y.%m.%d.%H.%M")
echo "End time: $end_time"