new_dir="results/misc/rename_samples/archive/"
samplesheet="results/misc/rename_samples/rename-info/chipseq-based/problem_paths.tree-based.txt"

while read -r path; do

    # get the old dirname
    old_dirname=$(dirname $path)

    # get the new dirname and make the tree
    old_dirname_no_res=$(echo $old_dirname | sed "s+/mnt/BioAdHoc/Groups/vd-ay/hichip-db-loop-calling/results/++")
    new_dirname="${new_dir}/${old_dirname_no_res}/"
    mkdir -p $new_dirname

    # move the old sample folder into the old dir
    mv $path $new_dirname

done < $samplesheet
