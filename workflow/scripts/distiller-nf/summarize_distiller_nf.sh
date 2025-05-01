#!/bin/sh
#SBATCH --job-name=summarize_distiller_nf
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=1g
#SBATCH --time=5:00:00
#SBATCH --output=results/revisions/distiller-nf/logs/summarize/job-%j.out
#SBATCH --error=results/revisions/distiller-nf/logs/summarize/job-%j.error

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
outdir="results/revisions/distiller-nf/work/${sample_name}/results/pairs_library"
pairs_file="${outdir}/${sample_name}.hg38.nodups.pairs.gz"

echo "Using outfile: ${pairs_file}"
echo

# get filtered version of pairs file
echo "# filtering pairs file"

zcat ${pairs_file} | grep -v '^#' | awk '{if (($8=="UU" || $8=="UR" || $8=="RU") && $9>=30 && $10>=30) {print $0}}' > ${outdir}/${sample_name}.hg38.nodups.mapq30.UU.UR.pairs

echo "done"
echo

# get stats and output to summary file
echo "# write stats to summary file"
summary_file="${outdir}/filtered_stats_UU_UR.txt"

#gunzip ${outdir}/${sample_name}.hg38.nodups.mapq30.UU.UR.pairs.gz

# total number of pairs
echo "validpairs"
validpairs=$(wc -l ${outdir}/${sample_name}.hg38.nodups.mapq30.UU.UR.pairs | awk '{print $1}')
echo "Total Pairs: ${validpairs}" >> ${summary_file}

# cis 
echo "cis"
cis=$(awk '{if ($2==$4) {print $0}}' ${outdir}/${sample_name}.hg38.nodups.mapq30.UU.UR.pairs | wc -l)
echo "Cis Pairs: ${cis}" >> ${summary_file}

# cis short-range
echo "cis short-range"
cis_shortrange=$(awk '{if ($2==$4 && $5-$3<=20000) {print $0}}' ${outdir}/${sample_name}.hg38.nodups.mapq30.UU.UR.pairs | wc -l)
echo "Cis Short-Range Pairs: ${cis_shortrange}" >> ${summary_file}

# cis long-range
echo "cis long-range"
cis_longrange=$(awk '{if ($2==$4 && $5-$3>20000) {print $0}}' ${outdir}/${sample_name}.hg38.nodups.mapq30.UU.UR.pairs | wc -l)
echo "Cis Long-Range Pairs: ${cis_longrange}" >> ${summary_file}

# trans
echo "trans"
trans=$(awk '{if ($2!=$4) {print $0}}' ${outdir}/${sample_name}.hg38.nodups.mapq30.UU.UR.pairs | wc -l)
echo "Trans Pairs: ${trans}" >> ${summary_file}

echo "done"
echo

# gzip filtered file
echo "# gzip filtered pairs file"
pigz ${outdir}/${sample_name}.hg38.nodups.mapq30.UU.UR.pairs
echo "done"

# print end message
echo
echo "Ended: summarize_distiller_nf"
echo

# print end time message
end_time=$(date "+%Y.%m.%d.%H.%M")
echo "End time: $end_time"