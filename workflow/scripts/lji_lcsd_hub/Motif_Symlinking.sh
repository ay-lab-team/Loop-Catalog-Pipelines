

###############################################################################
# Setting global vars
###############################################################################

# rename the normalizations
declare -A norm_dict
norm_dict["KR_NORM"]="kr"
norm_dict["NONE_NORM"]="raw"
norm_dict["VC_NORM"]="vc"

# set lji_lcsd path
lji_lcsd_hub_dir="results/lji_lcsd_hub/release-0.1/hub/hg38/motifs/"
mkdir -p $lji_lcsd_hub_dir


###############################################################################
# Symlinking the main files
###############################################################################

# example_path results/biorep_merged/results/motif_analysis/meme/fimo/<sample_name>/fimo_out_jaspar/fimo.html
glob_str="results/biorep_merged/results/motif_analysis/meme/fimo/*/fimo_out_jaspar/fimo.html"

for fn in $(ls $glob_str); do

    # directories that are named with meta data
    IFS='/' read -ra meta_data <<< "$fn"

    # extract important fields
    sample_name="${meta_data[6]}"

    # new path for file
    new_basename="${sample_name}.fimo.html"

    # check the file names
    old_basename=$(basename $fn)

    # symlink
    new_path="${lji_lcsd_hub_dir}/${new_basename}"
    if [ ! -e $new_path ];
    then
        ln -s -r $fn $new_path
    fi

done

###############################################################################
# Symlinking the CTCF files
###############################################################################

# example_path results/biorep_merged/results/motif_analysis/meme/fimo/CTCF/<sample_name>/fimo_out_jaspar/fimo.html
glob_str="results/biorep_merged/results/motif_analysis/meme/fimo/CTCF/*/fimo_out_jaspar/fimo.html"

for fn in $(ls $glob_str); do

    # directories that are named with meta data
    IFS='/' read -ra meta_data <<< "$fn"

    # extract important fields
    sample_name="${meta_data[7]}"

    # new path for file
    new_basename="${sample_name}.fimo.html"

    # check the file names
    old_basename=$(basename $fn)

    # symlink
    new_path="${lji_lcsd_hub_dir}/${new_basename}"
    if [ ! -e $new_path ];
    then
        ln -s -r $fn $new_path
    fi

done

###############################################################################
# Symlinking the CTCF files
###############################################################################

# example_path results/biorep_merged/results/motif_analysis/meme/fimo/CTCF/<sample_name>/fimo_out_jaspar/fimo.html
glob_str="results/biorep_merged/results/motif_analysis/meme/fimo/CTCF/*/fimo_out_jaspar/fimo.html"

for fn in $(ls $glob_str); do

    # directories that are named with meta data
    IFS='/' read -ra meta_data <<< "$fn"

    # extract important fields
    sample_name="${meta_data[7]}"

    # new path for file
    new_basename="${sample_name}.fimo.html"

    # check the file names
    old_basename=$(basename $fn)

    # symlink
    new_path="${lji_lcsd_hub_dir}/${new_basename}"
    if [ ! -e $new_path ];
    then
        ln -s -r $fn $new_path
    fi

done
###############################################################################
# Symlinking the Conserved loops results
###############################################################################

#results/biorep_merged/results/motif_analysis/meme/sea_conserved_anchors/<sample_set>/sea_out_jaspar/sea_<sample_set>.html
glob_str="results/biorep_merged/results/motif_analysis/meme/sea_conserved_anchors/*/sea_out_jaspar/sea_*.html"

for fn in $(ls $glob_str); do

    # directories that are named with meta data
    IFS='/' read -ra meta_data <<< "$fn"

    # extract important fields
    sample_name="${meta_data[6]}"

    # new path for file
    new_basename="${sample_name}.sea.html"

    # check the file names
    old_basename=$(basename $fn)

    # symlink
    new_path="${lji_lcsd_hub_dir}/${new_basename}"
    if [ ! -e $new_path ];
    then
        ln -s -r $fn $new_path
    fi

done

