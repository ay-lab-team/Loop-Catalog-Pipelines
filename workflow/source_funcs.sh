
# function to get the reference from the sample name
# this function only make sense for mm10 versus hg38
# because t2t data is stored at another location
function get_ref_from_sample_name() {
    sample_name=$1
    if [[ $sample_name =~ Mus_Musculus ]];
    then
        echo mm10
    elif [[ $sample_name =~ Homo_Sapiens ]];
    then
        echo hg38
    else
        echo error
    fi
}