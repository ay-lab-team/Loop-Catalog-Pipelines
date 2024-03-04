###############################################################################
# create the samplesheet, if necessary
###############################################################################
samplesheet="results/samplesheets/post-hicpro/fithichip_hp_to_washu.samplesheet.txt"
#ls results/loops/fithichip/*_fithichip.peaks/*/FitHiChIP_Peak2ALL_*/P2PBckgr_*/Coverage_Bias/FitHiC_BiasCorr/FitHiChIP-*.interactions_FitHiC_Q0.01.bed > all.fithichip_hp.temp.txt 
#cat all.fithichip_hp.temp.txt | cut -f 4 -d / | sort | uniq | sed "s/_fithichip.peaks//" > $samplesheet
echo "samplesheet: $samplesheet"

###############################################################################
# run with bash
###############################################################################
#bash workflow/scripts/visualizations/longrange/fithichip_hp_to_washu.qarray.qsh 1
#bash workflow/scripts/visualizations/longrange/fithichip_hp_to_washu.qarray.qsh 2
#bash workflow/scripts/visualizations/longrange/fithichip_hp_to_washu.qarray.qsh 3
#bash workflow/scripts/visualizations/longrange/fithichip_hp_to_washu.qarray.qsh 4

###############################################################################
# run with slurm
###############################################################################
#sbatch --array 1-999 --export="samplesheet=$samplesheet" workflow/scripts/visualizations/longrange/fithichip_hp_to_washu.qarray.qsh
#sbatch --array 1-1037 workflow/scripts/visualizations/longrange/fithichip_hp_to_washu.qarray.qsh

