#PBS -l nodes=1:ppn=1
#PBS -l mem=20gb
#PBS -l walltime=100:00:00
#PBS -e results/motif_analysis/logs/
#PBS -o results/motif_analysis/logs/
#PBS -N run_fimo
#PBS -V

# print start time message
start_time=$(date "+%Y.%m.%d.%H.%M")
echo "Start time: $start_time"

# print start message
echo "Started: run_fimo"

# run bash in strict mode
set -euo pipefail
IFS=$'\n\t'

# make sure to work starting from the github base directory for this script 
cd $PBS_O_WORKDIR
work_dir=$PBS_O_WORKDIR

# source tool paths
source workflow/source_paths.sh

# extract the sample information using the PBS ARRAYID
# samplesheet="results/samplesheets/hicpro/current.hicpro.samplesheet.without_header.tsv"
# sample_info=( $(cat $samplesheet | sed -n "${PBS_ARRAYID}p") )
# sample_name="${sample_info[0]}"
# org="${sample_info[2]}"
# protein="${sample_info[4]}"

database="jaspar"
#database="hocomoco"

# printing sample information
echo
echo "Processing"
echo "----------"
#echo "sample_name: $sample_name"
#echo "org: $org"
#echo "protein: $protein"
echo

# make the output directory
base="results/motif_analysis/conserved_anchors/meme_out"
outdir="results/motif_analysis/conserved_anchors/meme_out/fimo/"
#outdir="results/motif_analysis/conserved_anchors_prototype/fimo/prototype_030523/"
mkdir -p $outdir

# if [ -f $base/input_sorted.bed ]; then
#     # convert input bed to fasta
#     echo "# creating input fasta file"
#     #genome="/mnt/bioadhoc-temp/Groups/vd-ay/kfetter/hichip-db-loop-calling/data/hg38/hg38.fa"
#     #bed2fasta -o $outdir/input_fasta.fa -both $outdir/input_sorted.bed $genome
# fi

# if [ ! -f $outdir/input_fasta.fa ]; then
#     # create input bed file
#     echo "# one-dimensionalizing loop BEDPE file"
#     config="S5"
#     echo "# config: $config"
    
#     loop_file="results/loops/fithichip/${sample_name}_fithichip.peaks/${config}/FitHiChIP_Peak2ALL_b5000_L20000_U2000000/P2PBckgr_1/Coverage_Bias/FitHiC_BiasCorr/FitHiChIP-S5.interactions_FitHiC_Q0.01.bed"
    
#     if [[ $protein == "H3K27ac" ]]; then
#         peak_file="data/encode_chipseq/GM12878_H3K27ac_hg38_sorted.bed"
#     fi
#     if [[ $protein == "CTCF" ]]; then
#         peak_file="data/encode_chipseq/ENCFF827JRI_GM12878_CTCF_sorted.bed"
#     fi
#     if [[ $protein == "SMC1A" ]]; then
#         peak_file="data/encode_chipseq/ENCFF837YJA_GM12878_SMC3_sorted.bed"
#     fi
    
#     input="results/motif_analysis/meme/ame/$sample_name/input_bed.bed"

#     # one-dimensionalize bedpe + get unique anchors 
#     awk -F["\t"] '{if (NR > 1) {print $1"\t"$2"\t"$3"\tloop_"NR-1"_anchor_1\t.\t+\n"$4"\t"$5"\t"$6"\tloop_"NR-1"_anchor_2\t.\t+"}}' $loop_file | sort -k1,1 -k2,2n -k3,3n -u > "$outdir/anchors.txt"

#     # overlap unique anchors with peak file such that all overlapping peaks for a given anchor are listed for that one anchor
#     bedtools intersect -a "$outdir/anchors.txt" -b ${peak_file} -wa -wb > "$outdir/anchors_overlap_peaks.txt"

#     # sort the peaks for a given anchor from smallest to largest in regard to signalValue
#     sort -k1,1 -k2,2n -k3,3n -k13,13n "$outdir/anchors_overlap_peaks.txt" > "$outdir/anchors_overlap_peaks_sorted.txt"

#     # keep the peak with the greatest score for a given anchor, discard the rest
#     tac "$outdir/anchors_overlap_peaks_sorted.txt" | sort -k1,1 -k2,2n -k3,3n -u > "$outdir/anchors_overlap_peaks_sorted_best_peak.txt"

#     # print input file composed of the best peaks 
#     awk -F["\t"] '{print $7"\t"$8"\t"$9"\t"$4"\t"$6}' "$outdir/anchors_overlap_peaks_sorted_best_peak.txt" > $input

#     # convert input bed to fasta
#     genome="/mnt/bioadhoc-temp/Groups/vd-ay/kfetter/hichip-db-loop-calling/data/hg38/hg38.fa"
#     bed2fasta -o $outdir/input_fasta.fa -both $input $genome
# fi

# run fimo
echo
echo "# running fimo"

if [[ $database == "jaspar" ]]; then
    motifs="data/motifs/motif_databases/Jaspar_CORE_2022_latest_human.meme"
    #motifs="data/motifs/motif_databases/test.meme"
fi
if [[ $database == "hocomoco" ]]; then
    motifs="data/motifs/motif_databases/HUMAN/HOCOMOCOv11_core_HUMAN_mono_meme_format.meme"
fi

fimo --oc $outdir/fimo_out_$database --parse-genomic-coord --thresh 1e-6 $motifs $base/input_fasta.fa

# print end message
echo
echo "# Ended: fimo"

# print end time message
end_time=$(date "+%Y.%m.%d.%H.%M")
echo "End time: $end_time"