
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

function ended_job_message() {
    job_message=$1
    echo "Ended: $job_message"

    # print end time message
    end_time=$(date "+%Y.%m.%d.%H.%M")
    echo "End time: $end_time"
}



declare -A bad_to_good_sample_names
bad_to_good_sample_names=(
    ["JN-DSRCT1.shEWSWT1"]="JN-DSRCT1-shEWSWT1"
    ["JN-DSRCT1.shGFP"]="JN-DSRCT1-shGFP"
    ["L3.6pl"]="L3-6pl"
    ["Cardiomyocyte-E12.5"]="Cardiomyocyte-E12-5"
    ["Cardiomyocyte-E18.5"]="Cardiomyocyte-E18-5"
)

correct_bad_std_sample_name() {
    local std_sample_name=$1
    IFS='.' read -ra split <<< "$std_sample_name"

    name="${split[*]:0:${#split[@]}-4}"
    name=$(echo $name | sed "s/ /./g")
    if [[ -n "${bad_to_good_sample_names[$name]}" ]]; then
        good_name="${bad_to_good_sample_names[$name]}"
        corrected_std_sample_name="${good_name}.${split[@]: -4}"
        corrected_std_sample_name=$(echo $corrected_std_sample_name | sed "s/ /./g")
        echo "$corrected_std_sample_name"
    else
        echo "$std_sample_name"
    fi
}

# Example usage:
# std_sample_name="JN-DSRCT1.shEWSWT1.some.extra.parts.txt"
# corrected_std_sample_name=$(correct_bad_std_sample_name "$std_sample_name")
# echo "Corrected std sample name: $corrected_std_sample_name"
