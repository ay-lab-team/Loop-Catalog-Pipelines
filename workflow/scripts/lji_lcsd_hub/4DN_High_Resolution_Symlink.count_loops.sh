###############################################################################
# Setting global vars
###############################################################################

# rename the normalizations
declare -A norm_dict
norm_dict["KR_NORM"]="kr"
norm_dict["NONE_NORM"]="raw"
norm_dict["VC_NORM"]="vc"

# set lji_lcsd path
lji_lcsd_hub_dir="results/lji_lcsd_hub/release-0.1/hub/hg38/loops/hic/mustache/"

###############################################################################
# Count the loops 
###############################################################################

# empty/or create the summary file
summary_fn="results/lji_lcsd_hub/release-0.1/hub/hg38/loops/hic/mustache/summary.txt"
truncate -s 0 $summary_fn

main_dir="/mnt/BioAdHoc/Groups/vd-ay/hichip-db-loop-calling/results/lji_lcsd_hub/release-0.1/hub/hg38/loops/hic/mustache/"
for fn in $(find $main_dir -wholename "*.*.*.combined.tsv"); do

    # extracting the basename, here's an example: 4DNFIP71EWXC.1kb.raw.combined.tsv
    bn=$(basename $fn)

    # directories that are named with meta data
    IFS='.' read -ra meta_data <<< "$bn"

    # extract important fields
    sample_name="${meta_data[0]}"
    res="${meta_data[1]}"
    norm="${meta_data[2]}"

    # count the loops
    num_lines=$(wc -l $fn | cut -d " " -f 1)
    num_loops=$(expr $num_lines - 1)
    if [ $num_loops == -1 ];
    then
        num_loops=0
    fi


    # save the data
    data="${sample_name}\t${res}\t${norm}\t${num_loops}\n"
    printf "$data" >> $summary_fn

done

# sort the file
sort -k3,3 -k2,2 -k1,1 $summary_fn > $summary_fn.sorted
mv $summary_fn.sorted $summary_fn
