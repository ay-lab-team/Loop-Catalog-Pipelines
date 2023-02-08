#PBS -l nodes=1:ppn=1
#PBS -l mem=100gb
#PBS -l walltime=100:00:00
#PBS -e results/loops/logs/
#PBS -o results/loops/logs/
#PBS -N create_apa
#PBS -V

# run bash in strict mode
set -euo pipefail
IFS=$'\n\t'

cd "$PBS_O_WORKDIR/results/loops/overlaps/hiccups_vc_kr/"

apa_script="/mnt/BioAdHoc/Groups/vd-ay/kfetter/2021_iqtl_hichip/CD4N_HiChIP/code/APA_Compute_revised.r"
input_file="${3}"
#/mnt/bioadhoc-temp/Groups/vd-ay/kfetter/hichip-db-loop-calling/results/loops/fithichip/GM12878.GSE101498.Homo_Sapiens.H3K27ac.b1_fithichip.peaks/L5/FitHiChIP_Peak2ALL_b5000_L20000_U2000000/P2PBckgr_0/Coverage_Bias/FitHiC_BiasCorr/FitHiChIP-L5.interactions_FitHiC_Q0.01_sorted.bed
type_loops="${2}"
sample="${1}"
#ref_file="/mnt/BioAdHoc/Groups/vd-vijay/sourya/DATA/HiC/FitHiC_Rao2014/BinSize5000/HiC_Data_Ref_ICENorm/K562_combined_afterICE.bed"
ref_file="/mnt/BioAdHoc/Groups/vd-vijay/sourya/DATA/HiC/FitHiC_Rao2014/BinSize5000/HiC_Data_Ref_ICENorm/GM12878_combined_afterICE.bed"
outdir="/mnt/bioadhoc-temp/Groups/vd-ay/kfetter/hichip-db-loop-calling/results/loops/overlaps/hiccups_vc_kr/apa/${sample}_${type_loops}"
out="${outdir}/${type_loops}_"

mkdir -p $outdir

Rscript $apa_script --InpFile $input_file --RefFile $ref_file --midRef --cccol 5 --binsize 5000 --OutPrefix $out