

###############################################################################
# Setting global vars
###############################################################################

# rename the normalizations
declare -A norm_dict
norm_dict["KR_NORM"]="kr"
norm_dict["NONE_NORM"]="raw"
norm_dict["VC_NORM"]="vc"

declare -A ref_dict
ref_dict["GRCh38"]="hg38"
ref_dict["GRCm38"]="mm10"


###############################################################################
# Symlinking the longrange files
###############################################################################

main_dir="<jj-data-dir>/new_data_output/new_data"
for fn in $(find $main_dir -wholename "*/*/*/*_combined*longrange.bed.gz*"); do

    # directories that are named with meta data
    IFS='/' read -ra meta_data <<< "$fn"

    # extract important fields
    norm_str="${meta_data[10]}"
    norm="${norm_dict[$norm_str]}"
    res="${meta_data[11]}"
    res=$(echo $res | sed "s/kb/000/")
    sample_name=$(echo ${meta_data[12]} | cut -d "-"  -f 2)

    # set lji_lcsd path
    fourdn_ref=$(grep $sample_name results/hic/init.hic_sample.tsv | cut -f 10)
    ref="${ref_dict[$fourdn_ref]}"
    lji_lcsd_hub_dir="results/lji_lcsd_hub/release-0.1/hub/${ref}/loops/hic/mustache/"

    # new path for file
    new_basename="${sample_name}.${res}.${norm}.longrange.bed.gz"

    # add .tbi when the file is an index
    if [[ $fn == *".tbi" ]]; then
        new_basename+=".tbi"
    fi

    # check the file names
    old_basename=$(basename $fn)
    #printf "${old_basename}\t${new_basename}\n"

    # symlink
    new_path="${lji_lcsd_hub_dir}/${new_basename}"
    ln -s -r $fn $new_path
    echo $new_path

done

###############################################################################
# Symlinking the raw files
###############################################################################

#main_dir="<jj-data-dir>/new_data_output/new_data"
#for fn in $(find $main_dir -wholename "*/*/*/*_combined_*_*.tsv" |  grep -v combined_.*_combined); do
#
#    # directories that are named with meta data
#    IFS='/' read -ra meta_data <<< "$fn"
#
#    # extract important fields
#    norm_str="${meta_data[10]}"
#    norm="${norm_dict[$norm_str]}"
#    res="${meta_data[11]}"
#    sample_name=$(echo ${meta_data[12]} | cut -d "-"  -f 2)
#
#    # new path for file
#    new_basename="${sample_name}.${res}.${norm}.combined.tsv"
#
#    # add .tbi when the file is an index
#    if [[ $fn == *".tbi" ]]; then
#        new_basename+=".tbi"
#    fi
#
#    # check the file names
#    old_basename=$(basename $fn)
#    #printf "${old_basename}\t${new_basename}\n"
#
#    # symlink
#    new_path="${lji_lcsd_hub_dir}/${new_basename}"
#    echo "ln -s -r $fn $new_path"
#    ln -s -r $fn $new_path
#
#done
