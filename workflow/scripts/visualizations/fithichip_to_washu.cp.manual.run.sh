script="workflow/scripts/visualizations/fithichip_to_washu.manual.sh"
#for cp_loop in "BCBL1.GSE136090.Homo_Sapiens.H3K27ac.b1";
for cp_loop in $(ls -d results/loops/fithichip/*_chipseq.peaks/);
do
    # extract loop samples with chipseq data
    sample=$(echo $cp_loop | cut -d "/" -f 4 | sed "s/_chipseq\.peaks//")

    # run the script 
    $script $sample
done
