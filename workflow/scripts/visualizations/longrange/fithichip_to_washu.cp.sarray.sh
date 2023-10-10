# extract loop samples with chipseq data
cp_loop=$(sed -n ${slurm_id}p  workflow/scripts/visualizations/longrange/fithichip_to_washu.cp.sarray.samplesheet.txt)
sample=$(echo $cp_loop | cut -d "/" -f 4 | sed "s/_chipseq\.peaks//")

# run the script 
workflow/scripts/visualizations/longrange/fithichip_to_washu.cp.manual.sh $sample
