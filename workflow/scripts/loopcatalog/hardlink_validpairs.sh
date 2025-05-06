###############################################################################
# Unmerged samples
###############################################################################

## hg38 unmerged sample files (DONE)
#hg38_outdir="<project-dir>/results/loopcatalog/release-0.1/hub/hg38/interactions/hicpro/"
#for fn in $(find <project-dir>/results/hicpro/*Homo_Sapiens*/hic_results/data/*/*.allValidPairs);
#do
#    # create the path to the new link
#    bn=$(basename $fn)
#    new_link="${hg38_outdir}/${bn}"
#
#    # create the new link only if not existant
#    if [ ! -e $new_link ];
#    then
#        ln $(readlink -f $fn) $new_link
#    fi
#done

# mm10 unmerged sample files (DONE)
#mm10_outdir="<project-dir>/results/loopcatalog/release-0.1/hub/mm10/interactions/hicpro/"
#for fn in $(find <project-dir>/results/hicpro/*Mus_Musculus*/hic_results/data/*/*.allValidPairs);
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
#for fn in $(find <project-dir>/results/biorep_merged/results/hicpro/*Homo_Sapiens*/*.allValidPairs);
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
