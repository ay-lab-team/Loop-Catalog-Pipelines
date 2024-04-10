###############################################################################
# create the samplesheet, if necessary
###############################################################################

# regular batches
samplesheet="results/samplesheets/post-hicpro/hiccups_to_washu.samplesheet.txt"
batch="biorep-merged"

# biorep-merged batches that are saved elsewhere
samplesheet="results/samplesheets/post-hicpro/hiccups_to_washu.samplesheet.biorep-merged.txt"
batch="biorep-merged"

#ls -d results/loops/hiccups/whole_genome_all_batches/* | parallel basename {} > $samplesheet
#echo "samplesheet: $samplesheet"

###############################################################################
# run with bash
###############################################################################
#bash workflow/scripts/visualizations/longrange/hiccups_to_washu.qarray.qsh 1
#bash workflow/scripts/visualizations/longrange/hiccups_to_washu.qarray.qsh 2
#bash workflow/scripts/visualizations/longrange/hiccups_to_washu.qarray.qsh 3
#bash workflow/scripts/visualizations/longrange/hiccups_to_washu.qarray.qsh 4

###############################################################################
# run with slurm
###############################################################################
#sbatch --array 1-289 --export="samplesheet=$samplesheet,batch=$batch" workflow/scripts/visualizations/longrange/hiccups_to_washu.qarray.qsh
#sbatch --array 1 --export="samplesheet=$samplesheet,batch=$batch" workflow/scripts/visualizations/longrange/hiccups_to_washu.qarray.qsh
sbatch --array 1-137 --export="samplesheet=$samplesheet,batch=$batch" workflow/scripts/visualizations/longrange/hiccups_to_washu.qarray.qsh

###############################################################################
# print helpful message 
###############################################################################

echo "Results can be found at:"

hub_dir="results/lji_lcsd_hub/release-0.1/hub/hg38/loops/hichip/hiccups/"
echo "$hub_dir"

hub_dir="results/lji_lcsd_hub/release-0.1/hub/mm10/loops/hichip/hiccups/"
echo "$hub_dir"

