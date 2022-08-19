#PBS -l nodes=1:ppn=1
#PBS -l mem=10gb
#PBS -l walltime=5:00:00
#PBS -e results/visualizations/logs/
#PBS -o results/visualizations/logs/
#PBS -N to_washu.sh
#PBS -V

# print start time message
start_time=$(date "+%Y.%m.%d.%H.%M")
echo "Start time: $start_time"

# print start message
echo "Started: to_washu"

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

# get input and output file
infile="results/loops/hiccups/$sample_name/merged_loops.bedpe"

# convert if file exists 
if [ -s "${infile}" ]; then
    echo "loops file found"
    outfile="results/visualizations/washu/hiccups_loops_all/${sample_name}.hiccups-allchrs.loops.txt"

    awk -F['\t'] '{if (NR > 2) {print "chr"$1"\t"$2"\t"$3"\tchr"$4":"$5"-"$6",10\nchr"$4"\t"$5"\t"$6"\tchr"$1":"$2"-"$3",10"}}' $infile | sort -k1,1 -k2,2n > $outfile

    bgzip $outfile
    tabix -f -p bed $outfile'.gz'

else
    echo "no valid loops file found"
fi

# print end message
echo "Ended: converting to washu format"

# print end time message
end_time=$(date "+%Y.%m.%d.%H.%M")
echo "End time: $end_time"