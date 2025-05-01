#!/bin/sh
#SBATCH --job-name=summarize_juicer
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=1g
#SBATCH --time=5:00:00
#SBATCH --output=results/revisions/juicer/logs/summarize/job-%j.out
#SBATCH --error=results/revisions/juicer/logs/summarize/job-%j.error

# print start time message
start_time=$(date "+%Y.%m.%d.%H.%M")
echo "Start time: $start_time"

# run bash in strict mode
set -euo pipefail
IFS=$'\n\t'

# make sure to work starting from the github base directory for this script 
cd $SLURM_SUBMIT_DIR

# extract the sample information using the ARRAYID
IFS=$'\t'
samplesheet="results/samplesheets/hicpro/revisions.top_45.hicpro.samplesheet.unmerged.all_batches.without_header.tsv"
sample_info=( $(cat $samplesheet | sed -n "${SLURM_ARRAY_TASK_ID}p") )
sample_name="${sample_info[0]}"
org="${sample_info[2]}"
IFS=$'\n\t'

# get correct genome string
if [[ "$org" == "Homo_Sapiens" ]];
then
    genome="hg38"
elif [[ "$org" == "Mus_Musculus" ]];
then
    genome="mm10"
else
    echo "org not found"
    exit
fi

# printing run/sample information
echo
echo "Processing"
echo "----------"
echo "sample_name: $sample_name"
echo "org: $org"
echo

# get outfile
outdir="results/revisions/juicer/work/${sample_name}/aligned"
pairs_file="${outdir}/merged30.txt"

echo "Using outfile: ${pairs_file}"
echo

# get filtered version of pairs file
echo "# filtering pairs file"

# get hic contacts (remove intra-fragment pairs)
hic_contacts="results/revisions/juicer/work/${sample_name}/aligned/hic_contacts.txt"
if [ -f $hic_contacts ]; then
   echo "File $hic_contacts exists."
else
   awk '{if ($4!=$8 || ($2!=$6 && $4==$8)) print $0}' ${pairs_file} > ${hic_contacts} # filter out intra-fragment pairs
fi
echo "done"
echo

# get stats and output to summary file
echo "# write stats to summary file"
summary_file="${outdir}/filtered_stats_updated.txt"

# total number of pairs
echo "validpairs"
validpairs=$(wc -l ${hic_contacts} | awk '{print $1}')
echo "Total Pairs: ${validpairs}" >> ${summary_file}

# cis 
echo "cis"
cis=$(awk '{if ($2==$6) {print $0}}' ${hic_contacts} | wc -l)
echo "Cis Pairs: ${cis}" >> ${summary_file}

# cis short-range
echo "cis short-range"
cis_shortrange=$(awk '{if ($7-$3>0) {if ($2==$6 && $7-$3<=20000) print $0} else {if ($2==$6 && $3-$7<=20000) print $0}}' ${hic_contacts} | wc -l)
echo "Cis Short-Range Pairs: ${cis_shortrange}" >> ${summary_file}

# cis long-range
echo "cis long-range"
cis_longrange=$(awk '{if ($7-$3>0) {if ($2==$6 && $7-$3>20000) print $0} else {if ($2==$6 && $3-$7>20000) print $0}}' ${hic_contacts} | wc -l)
echo "Cis Long-Range Pairs: ${cis_longrange}" >> ${summary_file}

# trans
echo "trans"
trans=$(awk '{if ($2!=$6) {print $0}}' ${hic_contacts} | wc -l)
echo "Trans Pairs: ${trans}" >> ${summary_file}

echo "done"

# print end message
echo
echo "Ended: summarize_juicer"
echo

# print end time message
end_time=$(date "+%Y.%m.%d.%H.%M")
echo "End time: $end_time"