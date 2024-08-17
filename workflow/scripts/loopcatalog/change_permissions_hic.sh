###############################################################################
# Unmerged samples
###############################################################################

## hg38 unmerged sample files (DONE)
for fn in $(find /mnt/BioAdHoc/Groups/vd-ay/hichip-db-loop-calling/results/loops/hiccups/chr1_all_batches/*/*.hic)
do
      echo chmod 664 $(readlink -f $fn)
      chmod 664 $(readlink -f $fn)
done

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
