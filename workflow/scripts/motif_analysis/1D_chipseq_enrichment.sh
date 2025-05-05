#!/bin/sh
#SBATCH --job-name=1D_chipseq_enrichment
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=80g
#SBATCH --time=100:00:00
#SBATCH --output=results/motif_analysis/chipseq_enrichment/logs/job-%j.out
#SBATCH --error=results/motif_analysis/chipseq_enrichment/logs/job-%j.error

# print start time message
start_time=$(date "+%Y.%m.%d.%H.%M")
echo "Start time: $start_time"

# run bash in strict mode
set -euo pipefail
IFS=$'\n\t'

# make sure to work starting from the github base directory for this script 
cd $SLURM_SUBMIT_DIR

# source tool paths
source workflow/source_paths.sh

# print start message
echo "Started: 1D_chipseq_enrichment"
echo

samplesheet="results/samplesheets/post-hicpro/2024.11.06.h3k27ac_top_samples.tsv" # 54 samples; first row is the header
sample_info=( $(cat $samplesheet | sed -n "${SLURM_ARRAY_TASK_ID}p") )
foregound_regions_type="${sample_info[0]}"
protein="KLF15"
motifs="CTCF"
cell_type="HepG2"

echo "Protein: ${protein}"
echo "Motif Sites: ${motifs}"
echo "Cell Type: ${cell_type}"
echo "Sample: ${foregound_regions_type}"
echo

# input files
foregound_regions="results/motif_analysis/fimo_single_sample/${foregound_regions_type}/input_bed.bed" # strongest chipseq peaks overlapping loop anchor
motif_sites="results/motif_analysis/fimo_single_sample/${foregound_regions_type}/fimo_out_jaspar/fimo.tsv"
#chipseq_peaks="results/downloads/znf_chip_01.27.2025/ZNF460_HepG2_hg38_ENCFF261NJZ.sorted.bed"
chipseq_peaks="results/downloads/znf_chip_01.27.2025/KLF15_HepG2_hg38_ENCFF663PTR.sorted.bed"

echo "Using foreground seqs: ${foregound_regions}"
echo "Using motif sites: ${motif_sites}"
echo "Using chip-seq peaks: ${chipseq_peaks}"
echo

# output directory
outdir="results/motif_analysis/chipseq_enrichment/${foregound_regions_type}/${protein}/${cell_type}/CTCF_motifs"
mkdir -p ${outdir}


#####################################################
# filter foreground regions with 1+ motifs
# NOTE => currently do NOT include strand information
#####################################################

echo "# Get Foregound Seqs"
echo

# get motif sites for motif of interest
awk -v motifs="${motifs}" -F["\t"] '{if (NR>1 && $2==motifs) {print $3"\t"$4"\t"$5"\t"$9}}' ${motif_sites} | sort -k1,1 -k2,2n -k3,3n -k4,4n > ${outdir}/${motifs}.motif_sites.filt.sorted.bed

# overlap motif sites with foreground regions (at least 1bp overlap); keep motif site with smallest q-value; extend motif site region by 250bp each side
# note: output selected foreground regions are of lenth 515bp, there the motif is at the center
awk -F["\t"] '{print $1"\t"$2"\t"$3}' ${foregound_regions} | sort -k1,1 -k2,2n -k3,3n > ${outdir}/foreground_regions.sorted.bed
bedtools intersect -wa -wb -a ${outdir}/foreground_regions.sorted.bed -b ${outdir}/${motifs}.motif_sites.filt.sorted.bed | sort -k1,1 -k2,2n -k3,3n -k7,7g | sort -k1,1 -k2,2n -k3,3n -u | awk -F["\t"] '{print $4"\t"$5-250"\t"$6+250}' > ${outdir}/foreground_regions_overlapping_motif.sorted.bed


#####################################################
# overlap ChIP-seq peaks and foreground regions with 1+ motifs
#####################################################

echo "# Overlap Foreground Seqs with ChIP-seq Peaks"
echo

awk -F["\t"] '{print $1"\t"$2"\t"$3}' ${chipseq_peaks} | sort -k1,1 -k2,2n -k3,3n > ${outdir}/${protein}.chipseq_peaks.sorted.bed

# overlap chipseq peaks and foregound regions (at least 1bp overlap)
bedtools intersect -u -a ${outdir}/foreground_regions_overlapping_motif.sorted.bed -b ${outdir}/${protein}.chipseq_peaks.sorted.bed | sort -k1,1 -k2,2n -k3,3n > ${outdir}/foreground_regions_overlapping_chipseq.sorted.bed

# convert foreground sequences into a fasta file
bedtools getfasta -fi ${GENOME}/fasta/hg38.fa -bed ${outdir}/foreground_regions_overlapping_motif.sorted.bed > ${outdir}/${motifs}.${cell_type}.foreground_regions_overlapping_motif.fa

# calculate summary stats
num_foreground=$( wc -l ${outdir}/foreground_regions_overlapping_motif.sorted.bed | awk '{print $1}' )
num_foreground_overlapping_chipseq=$( wc -l ${outdir}/foreground_regions_overlapping_chipseq.sorted.bed | awk '{print $1}' )
frac_foregound=$( bc -l <<< "scale=3 ; ${num_foreground_overlapping_chipseq}/${num_foreground}" )

# print summary stats
echo "Total foreground regions: $( wc -l  ${outdir}/foreground_regions.sorted.bed | awk '{print $1}' )"
echo "Total motif sites: $( wc -l ${outdir}/${motifs}.motif_sites.filt.sorted.bed | awk '{print $1}' )"
echo "Total foreground regions with motif overlap: ${num_foreground}"
echo "Total foreground regions with motif and ChIP-seq overlap: ${num_foreground_overlapping_chipseq}"
echo "Fraction of foreground regions with motif and ChIP-seq overlap: ${frac_foregound}"
echo


#####################################################
# generate background
#####################################################

echo "# Get Background Seqs"
echo

# generate fasta which skips motif sites so that these regions are not chosen
bedtools subtract -a ${GENOME}/fasta/hg38.bed -b ${outdir}/${motifs}.motif_sites.filt.sorted.bed > ${outdir}/${motifs}.${cell_type}.good_regions.bed
bedtools getfasta -fi ${GENOME}/fasta/hg38.fa -bed ${outdir}/${motifs}.${cell_type}.good_regions.bed > ${outdir}/${motifs}.${cell_type}.hg38_motif_sites_masked.fa

# generate control seqs (mask soft-masked seqs, generate #foreground seqs number of control seqs of 515kb in size)
size=$( awk -F["\t"] '{if (NR==1) print $3-$2}' ${outdir}/foreground_regions_overlapping_motif.sorted.bed )
mkdir -p ${outdir}/homer2_bg
homer2 bg -i ${outdir}/${motifs}.${cell_type}.foreground_regions_overlapping_motif.fa -g ${outdir}/${motifs}.${cell_type}.hg38_motif_sites_masked.fa -size ${size} -N ${num_foreground} -ikmer 2 -o ${outdir}/homer2_bg/background_regions

# clean up background sequences
awk -F '[:\t]' '{print $1"\t"$3"\t"$4}' ${outdir}/homer2_bg/background_regions.bg.positions.bed > ${outdir}/homer2_bg/background_regions.bg.positions.cleaned.bed
shuf -n ${num_foreground} ${outdir}/homer2_bg/background_regions.bg.positions.cleaned.bed | sort -k1,1 -k2,2n -k3,3n > ${outdir}/homer2_bg/background_regions.bg.positions.cleaned.sorted.bed

#####################################################
# overlap ChIP-seq peaks and background regions
##################################################### 

echo "# Overlap Background Seqs with ChIP-seq Peaks"
echo

# overlap chipseq peaks and background regions (at least 1bp overlap)
bedtools intersect -u -a ${outdir}/homer2_bg/background_regions.bg.positions.cleaned.sorted.bed -b ${outdir}/${protein}.chipseq_peaks.sorted.bed | sort -k1,1 -k2,2n -k3,3n > ${outdir}/background_regions_overlapping_chipseq.sorted.bed

num_background=$( wc -l ${outdir}/homer2_bg/background_regions.bg.positions.cleaned.sorted.bed | awk '{print $1}' )
num_background_overlapping_chipseq=$( wc -l ${outdir}/background_regions_overlapping_chipseq.sorted.bed | awk '{print $1}' )
frac_background=$( bc -l <<< "scale=6 ; ${num_background_overlapping_chipseq}/${num_background}" )

echo "Total background regions: ${num_background}"
echo "Total background regions with ChIP-seq overlap: ${num_background_overlapping_chipseq}"
echo "Fraction of background regions with ChIP-seq overlap: ${frac_background}"
echo


#####################################################
# compute enrichment
#####################################################

echo "# Compute Enrichment"
echo

# enrichment = number of foregound regions overlapping chipseq / number of background regions overlapping chipseq
enrichment_ratio=$( bc -l <<< "scale=6 ; ${frac_foregound}/${frac_background}" )
echo "Enrichment Ratio: ${enrichment_ratio}"


# print end message
echo
echo "# Ended: 1D_chipseq_enrichment"

# print end time message
end_time=$(date "+%Y.%m.%d.%H.%M")
echo "End time: $end_time"