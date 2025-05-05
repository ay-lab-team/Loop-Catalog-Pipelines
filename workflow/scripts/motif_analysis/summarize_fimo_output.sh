#PBS -l nodes=1:ppn=1
#PBS -l mem=10gb
#PBS -l walltime=1:00:00
#PBS -e results/motif_analysis/logs/
#PBS -o results/motif_analysis/logs/
#PBS -N summarize_fimo_output
#PBS -V

# run bash in strict mode
set -euo pipefail
IFS=$'\n\t'

# make sure to work starting from the github base directory for this script 
cd $PBS_O_WORKDIR

# source tool paths
source workflow/source_paths.sh
config="S5"

# extract the sample information using the PBS ARRAYID
samplesheet="results/samplesheets/hicpro/current.hicpro.samplesheet.without_header.tsv"
sample_info=( $(cat $samplesheet | sed -n "${PBS_ARRAYID}p") )
sample_name="${sample_info[0]}"

base="results/motif_analysis/meme/fimo/${sample_name}"
fasta="${base}/input_fasta.fa"
fimo="${base}/fimo_out_jaspar/fimo.tsv"
loops="results/loops/fithichip/${sample_name}_chipseq.peaks/${config}/FitHiChIP_Peak2ALL_b5000_L20000_U2000000/P2PBckgr_1/Coverage_Bias/FitHiC_BiasCorr/FitHiChIP-S5.interactions_FitHiC_Q0.01.bed"
#samples="results/motif_analysis/conserved_anchors/samples/*/S5/FitHiChIP_Peak2ALL_b5000_L20000_U2000000/P2PBckgr_1/Coverage_Bias/FitHiC_BiasCorr/FitHiChIP-S5.interactions_FitHiC_Q0.01.bed"

outdir="${base}/summarize_results"
mkdir -p $outdir
out="${outdir}/summary.txt"

# compile all motifs into motifs.txt with coordiates at the beginning of each line
awk -F["\t"] '{if (/^MA/) {print $3"\t"$4"\t"$5"\t"$1"\t"$2}}' $fimo | sort -k1,1 -k2,2n > $outdir/motifs.txt

# simplify bedpe file
awk -F["\t"] '{if (NR > 1) {print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t"$6}}' $loops | sort -k1,1 -k2,2n -k3,3n -u > "$outdir/loops.txt"

# intersect motif coords with loops to associate each loop with its overlapping motifs 
bedtools pairtobed -a "$outdir/loops.txt" -b "$outdir/motifs.txt" >> "$outdir/loops_overlap_motifs.txt"

# one line per loop; motifs in comma separated format
#awk -F["\t"] 'BEGIN {printf $1"\t"$2"\t"$3"\t"$4"\t"$5"\t"$6"\t"$11} {if ($8 >= $2 && $9 <= $3) {print ","$11} else {print "\n"$1"\t"$2"\t"$3"\t"$4"\t"$5"\t"$6"\t,"$11}}'

sort -k1,1 -k2,2n "$outdir/loops_overlap_motifs.txt" > "$outdir/loops_overlap_motifs.sorted.txt"
uniq "$outdir/loops_overlap_motifs.sorted.txt" > "$outdir/loops_overlap_motifs.sorted.uniq.txt"

${fithichip_python} workflow/scripts/motif_analysis/clean_up_fimo_summary.py ${sample_name}

# compile all chipseq peaks used as input into peaks.txt
#awk -F'[>: -]' '{if (/^>/) {print $2"\t"$3"\t"$4"\t"$5}}' $fasta > $outdir/peaks.txt

# intersect motif coords with peaks to associate each peak with its overlapping motifs 
#bedtools intersect -a "$outdir/peaks.txt" -b "$outdir/motifs.txt" -wa -wb | uniq > "$outdir/peaks_overlap_motifs.txt"

# annotate file with loop anchor coordinates
#awk -F["\t"] 'NR==FNR {f1[$4]=$1"\t"$2"\t"$3; next} {if ($4 in f1) {print $1"\t"$2"\t"$3"\t"$4"\t"f1[$4]"\t"$5"\t"$6"\t"$7"\t"$8"\t"$9"\t"$10"\t"$11"\t"$12"\t"$13"\t"$14}}' "$loops" "$outdir/peaks_overlap_motifs.txt" > "$outdir/full.txt"

# remove all lines/motifs that fall outside its associated loop anchor
#awk -F["\t"] '{if ($9 >= $6 && $10 <= $7) {print $4"\t"$5"\t"$6"\t"$7"\t"$8"\t"$9"\t"$10"\t"$11"\t"$12"\t"$13"\t"$14"\t"$15"\t"$16"\t"$17}}' "$outdir/full.txt" > "$out"