###############################################################################
# create the samplesheet, if necessary
###############################################################################
samplesheet="results/samplesheets/post-hicpro/fithichip_cp_to_washu.biorep_merged.samplesheet.txt"
#ls -d /home/jreyna/hichip-db-loop-calling/results/biorep_merged/results/loops/fithichip/*chipseq.peaks | parallel basename {} | sed "s/_chipseq.peaks//" > results/samplesheets/post-hicpro/fithichip_cp_to_washu.biorep_merged.samplesheet.txt

###############################################################################
# run with bash
###############################################################################
bash workflow/scripts/visualizations/longrange/fithichip_cp_to_washu.biorep_merged.qarray.qsh $samplesheet 1

###############################################################################
# run with slurm
###############################################################################
#export_vars="samplesheet=${samplesheet}"
#sbatch --array 1-74 --export="$export_vars" workflow/scripts/visualizations/longrange/fithichip_cp_to_washu.biorep_merged.qarray.qsh
#sbatch --array 1-71 --export="$export_vars" workflow/scripts/visualizations/longrange/fithichip_cp_to_washu.biorep_merged.qarray.qsh
