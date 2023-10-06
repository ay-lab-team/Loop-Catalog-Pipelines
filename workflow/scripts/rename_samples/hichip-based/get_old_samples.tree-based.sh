## make the outdir
outdir="results/misc/rename_samples/rename-info/hichip-based/"
mkdir -p $outdir

## set the output file
cand_paths_fn="${outdir}/candidate_paths.tree-based.txt"

## find across all dirs
function find_dirs_and_softdirs() {
    find $1 -maxdepth 1 \( -type d -o \( -type l -xtype d \) \)
}

# note: when using a function where one of the parameters is a
# string with a "*", you have to be careful and use "\*" because
# it seems the bash * operator is being applied somehow
#find_dirs_and_softdirs results/fastqs/raw/\* > $cand_paths_fn
#find_dirs_and_softdirs results/fastqs/parallel/\* >> $cand_paths_fn
#find_dirs_and_softdirs results/fastqs/stats/\* >> $cand_paths_fn
#find_dirs_and_softdirs results/hicpro/\* >> $cand_paths_fn
#find_dirs_and_softdirs results/loops/fithichip/\* >> $cand_paths_fn
#find_dirs_and_softdirs results/loops/hiccups/whole_genome/\* >> $cand_paths_fn
#find_dirs_and_softdirs results/qc/fastqc/\* >> $cand_paths_fn
#find_dirs_and_softdirs results/peaks/fithichip/\* >> $cand_paths_fn
#find_dirs_and_softdirs results/peaks/hichip-peaks/\* >> $cand_paths_fn
#find_dirs_and_softdirs results/visualizations/washu/fithichip_loops_chipseq/\* > $cand_paths_fn
#find_dirs_and_softdirs results/motif_analysis/meme/fimo/\* > $cand_paths_fn
find_dirs_and_softdirs results/pieqtl_ncm_rep_combined_donorwise/fithichip/\* > $cand_paths_fn
find_dirs_and_softdirs results/pieqtl_ncm_rep_combined_donorwise/validpairs/\* >> $cand_paths_fn

#find_dirs_and_softdirs
#\*
#> $cand_paths_fn





#find_dirs_and_softdirs results/peaks/overlaps/no_slop_recall/\* > $cand_paths_fn (file-based)
## locate the final problematic paths
problem_samples_fn="${outdir}/copy_and_rename.samples.txt"
problem_paths_fn="${outdir}/problem_paths.tree-based.txt"
grep -f $problem_samples_fn $cand_paths_fn > $problem_paths_fn

echo "Check out the results with:"
echo "vim -p ${cand_paths_fn} ${problem_paths_fn}"
