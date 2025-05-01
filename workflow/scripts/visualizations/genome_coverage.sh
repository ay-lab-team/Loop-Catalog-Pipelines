#!/bin/sh
#SBATCH --job-name=genome_coverage
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=20gb
#SBATCH --time=100:00:00
#SBATCH --output=results/hicpro/CD4_Naive_All-Donors.phs001703v3p1.Homo_Sapiens.H3K27ac.biorep_merged/alignment/job-%j.out
#SBATCH --error=results/hicpro/CD4_Naive_All-Donors.phs001703v3p1.Homo_Sapiens.H3K27ac.biorep_merged/alignment/job-%j.error

# run bash in strict mode
set -euo pipefail
IFS=$'\n\t'

# print start time message
start_time=$(date "+%Y.%m.%d.%H.%M")
echo "Start time: $start_time"

# print start message
echo "Started: genome_coverage"

# make sure to work starting from the base directory for this project 
cd $SLURM_SUBMIT_DIR

# source tool paths
source workflow/source_paths.sh

sample_name="CD4_Naive_All-Donors.phs001703v3p1.Homo_Sapiens.H3K27ac.biorep_merged"

# printing sample information
echo
echo "Processing"
echo "----------"
echo "sample_name: $sample_name"
echo

# make the output directory 
outdir="results/hicpro/${sample_name}/alignment"
mkdir -p $outdir

# concatenate validpairs files
echo "# merge BAM files"

#samtools merge -o ${outdir}/${sample_name}.bam results/hicpro/CD4_Naive_18*/bowtie_results/bwt2/*/*.bwt2pairs.bam
cd ${outdir}
samtools sort ${sample_name}.bam -o ${sample_name}.sorted.bam
samtools index ${sample_name}.sorted.bam

echo "done"
echo 

# run bamCoverage 
echo "# run bamCoverage" 

# get effective genome size (from ChIPLine)
genome="hg38"
if [[ $genome == "hg38" ]]; then
	EGS=2913022398
elif [[ $genome == "mm10" ]]; then
	EGS=2652783500
fi

bamCoverage -b ${sample_name}.sorted.bam -o ${sample_name}.CoverageNorm.bw -of bigwig -bs 10 --effectiveGenomeSize ${EGS} --normalizeUsing RPKM --extendReads

echo "done"

# print end message
echo
echo "Ended: genome_coverage"

# print end time message
end_time=$(date "+%Y.%m.%d.%H.%M")
echo "End time: $end_time"