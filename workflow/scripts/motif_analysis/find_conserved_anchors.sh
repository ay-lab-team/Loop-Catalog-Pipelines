#PBS -l nodes=1:ppn=1
#PBS -l mem=2gb
#PBS -l walltime=0:30:00
#PBS -e results/motif_analysis/logs/
#PBS -o results/motif_analysis/logs/
#PBS -N find_conserved_anchors
#PBS -V

# run bash in strict mode
set -euo pipefail
IFS=$'\n\t'

# make sure to work starting from the github base directory for this script 
cd $PBS_O_WORKDIR

# source tool paths
source workflow/source_paths.sh

base="results/motif_analysis/conserved_anchors"
samples="results/motif_analysis/conserved_anchors/samples"
anchors="$base/anchors_raw.txt"
anchors_sorted="$base/anchors.sorted.txt"
anchors_uniq="$base/anchors.sorted.uniq.txt"
anchors_final="$base/anchors.sorted.uniq.final.txt"
anchors_tab="$base/anchors_sums.txt"

# compile all unique anchors from all samples
for sample in "$samples"/*; do
    loop_file="$sample/S5/FitHiChIP_Peak2ALL_b5000_L20000_U2000000/P2PBckgr_1/Coverage_Bias/FitHiC_BiasCorr/FitHiChIP-S5.interactions_FitHiC_Q0.01.bed"
    awk -F["\t"] '{if (FNR > 1) {print $1"\t"$2"\t"$3"\n"$4"\t"$5"\t"$6}}' $loop_file >> "$anchors"
done
sort -k1,1 -k2,2n -k3,3n $anchors > $anchors_sorted
uniq $anchors_sorted > $anchors_uniq
awk -F["\t"] '{print $1"\t"$2"\t"$3"\tanchor_"NR}' $anchors_uniq > $anchors_final

# count the number of times each anchor appears in given sample
for sample in "$samples"/*; do
    loop_file="$sample/S5/FitHiChIP_Peak2ALL_b5000_L20000_U2000000/P2PBckgr_1/Coverage_Bias/FitHiC_BiasCorr/FitHiChIP-S5.interactions_FitHiC_Q0.01.bed"
    echo "$sample" >> $anchors_tab
    awk -F["\t"] 'NR==FNR {f1[$1"\t"$2"\t"$3]=0; next} {if ($1"\t"$2"\t"$3 in f1) {f1[$1"\t"$2"\t"$3]=f1[$1"\t"$2"\t"$3]+1}} {if ($4"\t"$5"\t"$6 in f1) {f1[$4"\t"$5"\t"$6]=f1[$4"\t"$5"\t"$6]+1}} END {for (key in f1) {print key"\t"f1[key]}}' $anchors_final $loop_file >> $anchors_tab 
done