# make the outdir
mkdir -p results/misc/rename_samples/

# set the output file
cand_paths_fn="results/misc/rename_samples/candidate_paths.txt"

## find across all dirs
find results/fastqs/stats/* -maxdepth 0 -type d > $cand_paths_fn
find results/hicpro/* -maxdepth 0 -type d >> $cand_paths_fn
find results/loops/fithichip/* -maxdepth 0 -type d >> $cand_paths_fn
find results/loops/hiccups/whole_genome/* -maxdepth 0 -type d >> $cand_paths_fn
find results/qc/fastqc/* -maxdepth 0 -type d >> $cand_paths_fn

# locate the final problematic paths
problem_samples_fn="results/misc/rename_samples/copy_and_rename.samples.txt"
problem_paths_fn="results/misc/rename_samples/problem_paths.txt"
grep -f $problem_samples_fn $cand_paths_fn > $problem_paths_fn
