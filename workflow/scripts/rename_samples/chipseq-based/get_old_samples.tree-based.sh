## make the outdir
outdir="results/misc/rename_samples/rename-info/chipseq-based/"
mkdir -p $outdir

## set the output file
cand_paths_fn="${outdir}/candidate_paths.tree-based.txt"

## find across all dirs
# can add more here
#find /mnt/BioAdHoc/Groups/vd-ay/hichip-db-loop-calling/results/peaks/chipline/* -maxdepth 1 > $cand_paths_fn
find /mnt/BioAdHoc/Groups/vd-ay/hichip-db-loop-calling/results/peaks/merged_chipline/* -maxdepth 1 > $cand_paths_fn

## locate the final problematic paths
problem_samples_fn="${outdir}/copy_and_rename.samples.txt"
problem_paths_fn="${outdir}/problem_paths.tree-based.txt"
grep -f $problem_samples_fn $cand_paths_fn > $problem_paths_fn

echo "Check out the results with:"
echo "vim -p ${cand_paths_fn} ${problem_paths_fn}"
