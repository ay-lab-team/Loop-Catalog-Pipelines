#PBS -l nodes=1:ppn=1
#PBS -l mem=20gb
#PBS -l walltime=100:00:00
#PBS -e results/loops/logs/
#PBS -o results/loops/logs/
#PBS -N run_fithichip_loopcalling
#PBS -V

# example run:
# 1) qsub -t <index1>,<index2>,... workflow/scripts/run_fithichip_loopcalling.sh
# 2) qsub -t <index-range> workflow/scripts/run_fithichip_loopcalling.sh
# 3) qsub -t <index1>,<index2>,<index-range1> workflow/scripts/run_fithichip_loopcalling.sh
# 4) qsub -t <index-range1>,<index-range2>,... workflow/scripts/run_fithichip_loopcalling.sh
# 5) qsub -t <any combination of index + ranges> workflow/scripts/run_fithichip_loopcalling.sh

# print start time message
start_time=$(date "+%Y.%m.%d.%H.%M")
echo "Start time: $start_time"

# print start message
echo "Started: run_fithichip_loopcalling"

# run bash in strict mode
set -euo pipefail
IFS=$'\n\t'

# make sure to work starting from the base directory for this project 
cd $PBS_O_WORKDIR

# source tool paths
source workflow/source_paths.sh

# extract the sample information using the PBS ARRAYID
samplesheet="results/samplesheets/fastq/2022.04.09.16.57.fastq.samplesheet.without_header.tsv"
sample_info=( $(cat $samplesheet | sed -n "${PBS_ARRAYID}p") )
sample_name="${sample_info[0]}"

# printing sample information
echo
echo "Processing"
echo "----------"
echo "sample_name: $sample_name"
echo

# make the output directory 
outdir="results/loops/fithichip/$sample_name/"
mkdir -p $outdir

# run fithichip
echo "# running fithichip"
inpdir=""
java -Xmx20g -jar $juicertools hiccups --cpu -r 5000 -f 0.01 -p 4 -i 7 -d 20000 $inpdir $outdir

# print end message
echo "Ended: fithichip"

# print end time message
end_time=$(date "+%Y.%m.%d.%H.%M")
echo "End time: $end_time"