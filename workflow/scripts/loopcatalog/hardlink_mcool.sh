###############################################################################
# Unmerged samples
###############################################################################

## hg38 unmerged sample files (DONE)
hg38_outdir="/mnt/BioHome/jreyna/hichip-db-loop-calling/results/loopcatalog/release-0.1/hub/hg38/interactions/hicpro/"
for fn in $(find /mnt/BioAdHoc/bioadhoc-temp/Groups/vd-ay/kfetter/hichip-db-loop-calling/results/qc/hicrep/cool/*Homo_Sapiens*/allres.mcool);
do


    # get the sample name
    std_sample_name=$(echo $fn | cut -d "/" -f 13)

    # create the path to the new link
    new_link="${hg38_outdir}/${std_sample_name}.mcool"

    # create the new link only if not existant
    if [ ! -e $new_link ];
    then
        ln $(readlink -f $fn) $new_link
    fi
done





# mm10 unmerged sample files (DONE)
#mm10_outdir="/mnt/BioHome/jreyna/hichip-db-loop-calling/results/loopcatalog/release-0.1/hub/mm10/interactions/hicpro/"
#for fn in $(find /mnt/BioAdHoc/Groups/vd-ay/hichip-db-loop-calling/results/loops/hiccups/chr1_all_batches/*Mus_Musculus*/*.hic)
#do
#    # create the path to the new link
#    bn=$(basename $fn)
#    new_link="${mm10_outdir}/${bn}"
#
#    # create the new link only if not existant
#    if [ ! -e $new_link ];
#    then
#        ln $(readlink -f $fn) $new_link
#    fi
#done


###############################################################################
# Merged samples
###############################################################################

# hg38 merged sample files (in progress)
#for fn in $(find /mnt/BioAdHoc/Groups/vd-ay/hichip-db-loop-calling/results/biorep_merged/results/hicpro/*Homo_Sapiens*/*.allValidPairs);
#do
#    # create the path to the new link
#    bn=$(basename $fn)
#    new_link="${hg38_outdir}/${bn}"
#
#    # create the new link only if not existant
#    if [ ! -e $new_link ];
#    then
#        echo "ln $(readlink -f $fn) $new_link"
#    fi
#done
