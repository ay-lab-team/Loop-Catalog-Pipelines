############################# User Input #############################
# receiving input data
input_sample=$1 # input sample with INCORRECT name
output_sample=$2 # output sample with CORRECT name
input_sample_dir=$3 # absolute or relative
output_sample_dir=$4 # absolute or relative

# get the absolute path for the input_sample_dir
input_sample_dir=$(readlink -f $input_sample_dir)

# make the output_sample_dir if necessary then get the absolute path
mkdir -p $output_sample_dir
output_sample_dir=$(readlink -f $output_sample_dir)

############################# Examples Inputs #############################
# example hicpro
#rename_samples.sh T47D-T0.GSE179666.Homo_Sapiens.PR.b1 \
#                    T47D-T0.GSE179666.Homo_Sapiens.CORRECTNAME.b1 \
#                    ../../hicpro/T47D-T0.GSE179666.Homo_Sapiens.PR.b1/ \
#                    ../../hicpro/T47D-T0.GSE179666.Homo_Sapiens.PR.b1/
#
#rename_samples.sh T47D-T0.GSE179666.Homo_Sapiens.PR.b1 T47D-T0.GSE179666.Homo_Sapiens.CORRECTNAME.b1 \
#                    ../../hicpro/T47D-T0.GSE179666.Homo_Sapiens.PR.b1/ ../test/hicpro/T47D-T0.GSE179666.Homo_Sapiens.PR.b1/

# example fithichip
#input_sample="T47D-T0.GSE179666.Homo_Sapiens.PR.b1_chipseq.peaks"
#output_sample="T47D-T0.GSE179666.Homo_Sapiens.CORRECTNAME.b1_chipseq.peaks"
#input_sample_dir="T47D-T0.GSE179666.Homo_Sapiens.PR.b1_chipseq.peaks/"
#output_sample_dir="../test/"

############################# Main Code #############################

# get the paths to copy
# navigating to input_sample_dir is important in order to use find 
# with "*" which can remove the initial part of the path
curr_dir=$(pwd)
cd $input_sample_dir
input_paths=$(find *)
cd $curr_dir

# cycle through samples, rename, and copy
for input_path in $input_paths;
do
    # get the full input path
    full_input_path="${input_sample_dir}/${input_path}"

    # generate output path from the input path by replacing the input_sample name
    # with the output_sample name
	full_output_path=$(echo $input_path | sed "s/${input_sample}/${output_sample}/g")
	full_output_path="${output_sample_dir}/${full_output_path}"

    echo "Copying and renaming ${full_input_path} to ${full_output_path}"

    # if a dir then make a new dir
	if [[ -d $full_input_path ]]; 
	then
		mkdir -p $full_output_path

    # if a file then softlink the original file 
	elif [[ -f $full_input_path ]];
    then
		ln -s $full_input_path $full_output_path
	fi
done
