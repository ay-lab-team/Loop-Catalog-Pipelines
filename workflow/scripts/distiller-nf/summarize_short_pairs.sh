#!/bin/sh
#SBATCH --job-name=summarize_short_pairs
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=1g
#SBATCH --time=5:00:00
#SBATCH --output=results/revisions/alignment_comparison/short_pairs_analysis/logs/job-%j.out
#SBATCH --error=results/revisions/alignment_comparison/short_pairs_analysis/logs/job-%j.error

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
outdir="results/revisions/alignment_comparison/short_pairs_analysis/${sample_name}"
stats_file="${outdir}/stats_distiller_UU_UR.txt"
mkdir -p ${outdir}

echo "Writing results to: ${outdir}"
echo

#####################################################################
# For each tool, filter out pairs <1kb and then compile summary stats
#####################################################################

# HiC-Pro
# determine (or create) hicpro dir
# echo "# Begin HiC-Pro Analysis"
# hicpro_file="results/hicpro/${sample_name}/hic_results/data/${sample_name}/${sample_name}.allValidPairs"
# hicpro_cisdistfilt_file="${outdir}/hicpro.mincisdist_1000.allValidPairs"

# # filter for cis distance >1kb
# awk -F["\t"] '{if (($2!=$5) || ($2==$5 && $6-$3>1000)) print $0}' ${hicpro_file} > ${hicpro_cisdistfilt_file}

# all_pairs=$(wc -l ${hicpro_file} | awk '{print $1}')
# cisfilt_pairs=$(wc -l ${hicpro_cisdistfilt_file} | awk '{print $1}')
# cis=$(awk -F["\t"] '{if ($2==$5) print $0}' ${hicpro_cisdistfilt_file} | wc -l)
# cis_shortrange=$(awk -F["\t"] '{if ($2==$5 && $6-$3<=20000) print $0}' ${hicpro_cisdistfilt_file} | wc -l)
# cis_longrange=$((cis-cis_shortrange))
# trans=$((cisfilt_pairs-cis))

# echo "HiC-Pro All: ${all_pairs}" >> ${stats_file}
# echo "HiC-Pro >1kb: ${cisfilt_pairs}" >> ${stats_file}
# echo "HiC-Pro Cis: ${cis}" >> ${stats_file}
# echo "HiC-Pro Cis Short-Range: ${cis_shortrange}" >> ${stats_file}
# echo "HiC-Pro Cis Long-Range: ${cis_longrange}" >> ${stats_file}
# echo "HiC-Pro Trans: ${trans}" >> ${stats_file}
# echo >> ${stats_file}

# echo "ended"
# echo

# # Juicer
# echo "# Begin Juicer Analysis"
# hic_contacts="results/revisions/juicer/work/${sample_name}/aligned/hic_contacts.txt"
# juicer_cisdistfilt_file="${outdir}/juicer.mincisdist_1000.pairs"

# # filter for cis distance >1kb
# awk '{if ($7-$3>0) {if (($2!=$6) || ($2==$6 && $7-$3>1000)) print $0} else {if (($2!=$6) || ($2==$6 && $3-$7>1000)) print $0}}' ${hic_contacts} > ${juicer_cisdistfilt_file}

# all_pairs=$(wc -l ${hic_contacts} | awk '{print $1}')
# cisfilt_pairs=$(wc -l ${juicer_cisdistfilt_file} | awk '{print $1}')
# cis=$(awk '{if ($2==$6) print $0}' ${juicer_cisdistfilt_file} | wc -l)
# cis_shortrange=$(awk '{if ($7-$3>0) {if ($2==$6 && $7-$3<=20000) print $0} else {if ($2==$6 && $3-$7<=20000) print $0}}' ${juicer_cisdistfilt_file} | wc -l)
# cis_longrange=$((cis-cis_shortrange))
# trans=$((cisfilt_pairs-cis))

# echo "Juicer All: ${all_pairs}" >> ${stats_file}
# echo "Juicer >1kb: ${cisfilt_pairs}" >> ${stats_file}
# echo "Juicer Cis: ${cis}" >> ${stats_file}
# echo "Juicer Cis Short-Range: ${cis_shortrange}" >> ${stats_file}
# echo "Juicer Cis Long-Range: ${cis_longrange}" >> ${stats_file}
# echo "Juicer Trans: ${trans}" >> ${stats_file}
# echo >> ${stats_file}

# echo "ended"
# echo

# distiller-nf
echo "# Begin distiller-nf Analysis"
distiller_file="results/revisions/distiller-nf/work/${sample_name}/results/pairs_library/${sample_name}.hg38.nodups.mapq30.UU.UR.pairs"
distiller_cisdistfilt_file="${outdir}/distiller.mincisdist_1000.UU.UR.pairs"

# filter for cis distance >1kb
zcat ${distiller_file} | awk '{if (($2!=$4) || ($2==$4 && $5-$3>1000)) print $0}' > ${distiller_cisdistfilt_file}

all_pairs=$(zcat ${distiller_file} | wc -l)
cisfilt_pairs=$(wc -l ${distiller_cisdistfilt_file} | awk '{print $1}')
cis=$(awk -F["\t"] '{if ($2==$4) print $0}' ${distiller_cisdistfilt_file} | wc -l)
cis_shortrange=$(awk -F["\t"] '{if ($2==$4 && $5-$3<=20000) print $0}' ${distiller_cisdistfilt_file} | wc -l)
cis_longrange=$((cis-cis_shortrange))
trans=$((cisfilt_pairs-cis))

echo "distiller-nf All: ${all_pairs}" >> ${stats_file}
echo "distiller-nf >1kb: ${cisfilt_pairs}" >> ${stats_file}
echo "distiller-nf Cis: ${cis}" >> ${stats_file}
echo "distiller-nf Cis Short-Range: ${cis_shortrange}" >> ${stats_file}
echo "distiller-nf Cis Long-Range: ${cis_longrange}" >> ${stats_file}
echo "distiller-nf Trans: ${trans}" >> ${stats_file}

echo "ended"

# print end message
echo
echo "Ended: summarize_short_pairs"
echo

# print end time message
end_time=$(date "+%Y.%m.%d.%H.%M")
echo "End time: $end_time"