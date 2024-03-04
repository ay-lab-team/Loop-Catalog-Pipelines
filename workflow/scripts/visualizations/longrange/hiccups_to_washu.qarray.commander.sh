###############################################################################
# create the samplesheet, if necessary
###############################################################################
samplesheet="results/samplesheets/post-hicpro/hiccups_to_washu.samplesheet.txt"
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
#sbatch --array 1-289 --export="samplesheet=$samplesheet" workflow/scripts/visualizations/longrange/hiccups_to_washu.qarray.qsh

###############################################################################
# print helpful message 
###############################################################################

echo "Results can be found at:"

hub_dir="results/lji_lcsd_hub/release-0.1/hub/hg38/loops/hichip/hiccups/"
echo "$hub_dir"

hub_dir="results/lji_lcsd_hub/release-0.1/hub/mm10/loops/hichip/hiccups/"
echo "$hub_dir"

