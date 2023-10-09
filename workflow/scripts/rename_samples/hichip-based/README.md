Tree-based Renaming
-------------------
Tree-based refers to file structures where each sample has a directory with 
sub-branches inside of itself with result files across this tree. Example
.
└── visualization_files 
    ├── sampleA/ + subtrees
    ├── sampleB/ + subtrees
    └── sampleC/ + subtrees

Rather than just renaming directly, we renamed samples by first archiving them then
performing an operation akin to cp -r -l -s where I make the directory structure 
and symlink the files from the archived samples. The following are the scripts 
used to achieve this:

 1. workflow/scripts/rename_samples/get_old_samples.tree-based.sh - get a list of the old samples
 2. workflow/scripts/rename_samples/archive_old_samples.tree-based.sh - archive the list of old samples
 3. workflow/scripts/rename_samples/rename_old_samples.tree-based.sh - perform the renaming
     a. workflow/scripts/general/symlink_and_rename_sample_trees.sh - script coding the renaming capability for trees

Output can be found at:
 - results/misc/rename_samples/archive/ - archived samples
 - results/misc/rename_samples/hichip-based/copy_and_rename.samplesheet.txt - original samplesheet of samples to rename


#File-based Renaming (under-development)
#-------------------
#File-based refers to file structures where a (single) folder contains data
#for multiple samples in the form of files ONLY. Example:
#.
#└── visualization_files 
#    ├── sampleA.txt
#    ├── sampleB.txt
#    └── sampleC.txt
#
#Rather than just renaming directly, we renamed samples by first archiving them then
#performing an operation akin to cp -r -l -s where I make the directory structure 
#and symlink the files from the archived samples. The following are the scripts 
#used to achieve this:
#
# 1. workflow/scripts/rename_samples/get_old_samples.file-based.sh - get a list of the old samples
# 2. workflow/scripts/rename_samples/archive_old_samples.file-based.sh - archive the list of old samples
# 3. workflow/scripts/rename_samples/rename_old_samples.file-based.sh - perform the renaming
#     a. workflow/scripts/general/symlink_and_rename_sample_files.sh - script coding the renaming capability for files
#
#Output can be found at:
# - results/misc/rename_samples/archive/ - archived samples
# - results/misc/rename_samples/chipseq-based/copy_and_rename.samplesheet.txt - original samplesheet of samples to rename

