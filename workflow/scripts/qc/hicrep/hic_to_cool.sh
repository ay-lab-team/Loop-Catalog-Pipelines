#PBS -l nodes=1:ppn=1
#PBS -l mem=5gb
#PBS -l walltime=5:00:00
#PBS -e results/qc/hicrep/logs/
#PBS -o results/qc/hicrep/logs/
#PBS -N hic_to_cool
#PBS -V

# run bash in strict mode
set -euo pipefail
IFS=$'\n\t'

# print start time message
start_time=$(date "+%Y.%m.%d.%H.%M")
echo "Start time: $start_time"

# print start message
echo "Started: hic_to_cool"

# run bash in strict mode
set -euo pipefail
IFS=$'\n\t'

# make sure to work starting from the base directory for this project 
cd $PBS_O_WORKDIR

# source tool paths
source workflow/source_paths.sh

# extract the sample information using the PBS ARRAYID
IFS=$'\t'
samplesheet="results/samplesheets/hicpro/current.hicpro.samplesheet.without_header.tsv"
sample_info=( $(cat $samplesheet | sed -n "${PBS_ARRAYID}p") )
sample_name="${sample_info[0]}"

# printing sample information
echo
echo "Processing"
echo "----------"
echo "sample_name: $sample_name"
echo

# make the output directory 
outdir="results/qc/hicrep/cool/${sample_name}/"
mkdir -p $outdir

# get hic file path
hic_file="results/loops/hiccups/chr1/${sample_name}/${sample_name}.hic"

# run hic2cool
echo "# running hic2cool"
hic2cool convert $hic_file "${outdir}/allres.cool" -r 0
hic2cool convert $hic_file "${outdir}/1000.cool" -r 1000
hic2cool convert $hic_file "${outdir}/5000.cool" -r 5000
hic2cool convert $hic_file "${outdir}/10000.cool" -r 10000
hic2cool convert $hic_file "${outdir}/25000.cool" -r 25000
hic2cool convert $hic_file "${outdir}/50000.cool" -r 50000
hic2cool convert $hic_file "${outdir}/100000.cool" -r 100000
hic2cool convert $hic_file "${outdir}/250000.cool" -r 250000
hic2cool convert $hic_file "${outdir}/500000.cool" -r 500000
hic2cool convert $hic_file "${outdir}/1000000.cool" -r 1000000
hic2cool convert $hic_file "${outdir}/2500000.cool" -r 2500000

# print end message
echo
echo "Ended: hic2cool"

# print end time message
end_time=$(date "+%Y.%m.%d.%H.%M")
echo "End time: $end_time"