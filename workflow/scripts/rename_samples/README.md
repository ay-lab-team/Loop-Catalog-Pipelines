
Rather than just renaming directly, we renamed samples by first archiving them then
performing an operation akin to cp -r -l -s where I make the directory structure 
and symlink the files from the archived samples. The following are the scripts 
used to achieve this:

 1. workflow/scripts/rename_samples/get_old_samples.sh - get a list of the old samples
 2. workflow/scripts/rename_samples/archive_old_samples.sh - archive the list of old samples
 3. workflow/scripts/general/symlink_and_rename_sample_trees.sh - script coding the renaming capability
 4. workflow/scripts/rename_samples/rename_old_samples.sh - perform the renaming

Output can be found at:
 - results/misc/rename_samples/archive/ - archived samples
 - results/misc/rename_samples/copy_and_rename.samplesheet.txt - original samplesheet of samples to rename

