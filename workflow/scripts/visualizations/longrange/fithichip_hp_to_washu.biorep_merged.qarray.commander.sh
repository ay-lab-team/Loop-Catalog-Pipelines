###############################################################################
# create the samplesheet, if necessary
###############################################################################
samplesheet="results/samplesheets/post-hicpro/fithichip_hp_to_washu.biorep_merged.samplesheet.txt"
#ls -d /home/jreyna/hichip-db-loop-calling/results/biorep_merged/results/loops/fithichip/*fithichip.peaks | parallel basename {} | sed "s/_fithichip.peaks//" > results/samplesheets/post-hicpro/fithichip_hp_to_washu.biorep_merged.samplesheet.txt

###############################################################################
# run with bash
###############################################################################
#bash workflow/scripts/visualizations/longrange/fithichip_hp_to_washu.biorep_merged.qarray.qsh $samplesheet 145

###############################################################################
# run with slurm
###############################################################################
export_vars="samplesheet=${samplesheet}"
sbatch --array 1-282 --export="$export_vars" workflow/scripts/visualizations/longrange/fithichip_hp_to_washu.biorep_merged.qarray.qsh
