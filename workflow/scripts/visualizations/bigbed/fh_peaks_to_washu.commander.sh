###############################################################################
# run with bash
###############################################################################
#samplesheet="results/samplesheets/fh_peaks/mm10.samplesheet.tsv"; ref="mm10";
#bash workflow/scripts/visualizations/bigbed/fh_peaks_to_washu.qarray.sh $samplesheet $ref 65

###############################################################################
# run with sbatch
###############################################################################

# hg38
#samplesheet="results/samplesheets/fh_peaks/hg38.samplesheet.tsv"; ref="hg38";
#export_vars="samplesheet=$samplesheet,ref=$ref"
#sbatch --array 1-754 --export="$export_vars" workflow/scripts/visualizations/bigbed/fh_peaks_to_washu.qarray.sh

# mm10
samplesheet="results/samplesheets/fh_peaks/mm10.samplesheet.tsv"; ref="mm10";
export_vars="samplesheet=$samplesheet,ref=$ref"
sbatch --array 1-281 --export="$export_vars" workflow/scripts/visualizations/bigbed/fh_peaks_to_washu.qarray.sh
