#!/bin/sh
#SBATCH --job-name=loop_overlap_venn
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=100g
#SBATCH --time=05:00:00
#SBATCH --output=results/revisions/alignment_comparison/loops/logs/job-%j.out
#SBATCH --error=results/revisions/alignment_comparison/loops/logs/job-%j.error

# print start time message
start_time=$(date "+%Y.%m.%d.%H.%M")
echo "Start time: $start_time"

# print start message
echo "Started: loop_overlap_venn"

# run bash in strict mode
set -euo pipefail
IFS=$'\n\t'

# make sure to work starting from the base directory for this project 
cd $SLURM_SUBMIT_DIR

# path of softwares 
source workflow/source_paths.sh

# alignment tool comparison
#cd /mnt/BioAdHoc/Groups/vd-ay/kfetter/hichip-db-loop-calling/results/revisions/alignment_comparison/loops/CD34+-Cord-Blood.GSE165207.Homo_Sapiens.H3K27ac.b1

# hiccups normalization comparison
sample="CD34+-Cord-Blood.GSE165207.Homo_Sapiens.H3K27ac.b1"
cd /mnt/BioAdHoc/Groups/vd-ay/kfetter/hichip-db-loop-calling/results/revisions/hiccups/whole_genome/overlaps_09.09.24/${sample}

# alignment tool comparison
#Rscript /mnt/BioAdHoc/Groups/vd-ay/kfetter/hichip-db-loop-calling/workflow/scripts/misc/Utilities/Loop_Overlap_Venn/Venn_Interactions.r --FileList S5_hicpro/FitHiChIP_Peak2ALL_b5000_L20000_U2000000/P2PBckgr_1/Coverage_Bias/FitHiC_BiasCorr/FitHiChIP-S5.interactions_FitHiC_Q0.01.bed,S5_juicer/FitHiChIP_Peak2ALL_b5000_L20000_U2000000/P2PBckgr_1/Coverage_Bias/FitHiC_BiasCorr/FitHiChIP-S5.interactions_FitHiC.bed,S5_distiller/FitHiChIP_Peak2ALL_b5000_L20000_U2000000/P2PBckgr_1/Coverage_Bias/FitHiC_BiasCorr/FitHiChIP-S5.interactions_FitHiC.bed --Labels HiC-Pro,Juicer,distiller-nf --OutDir venn_01.05.2025_dump

# hiccups normalization comparison
Rscript /mnt/BioAdHoc/Groups/vd-ay/kfetter/hichip-db-loop-calling/workflow/scripts/misc/Utilities/Loop_Overlap_Venn/Venn_Interactions.r --FileList postprocessed_pixels_5000.SCALE.sorted.bedpe,postprocessed_pixels_5000.VC.sorted.bedpe,postprocessed_pixels_5000.VC_SQRT.sorted.bedpe --HeaderList 0,0,0 --Labels SCALE,VC,VC_SQRT --OutDir venn_01.13.2025_dump

# print end message
echo
echo "Ended: loop_overlap_venn"
echo

# print end time message
end_time=$(date "+%Y.%m.%d.%H.%M")
echo "End time: $end_time"