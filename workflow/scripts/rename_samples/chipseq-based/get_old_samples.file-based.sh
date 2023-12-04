## make the outdir
outdir="results/misc/rename_samples/rename-info/chipseq-based/"
mkdir -p $outdir

## set the output file
cand_paths_fn="${outdir}/candidate_paths.file-based.txt"

## find across all dirs
function find_files() {
    find $1 -maxdepth 1 \( -type f -o \( -type l -xtype f \) \)
}

# note: when using a function where one of the parameters is a
# string with a "*", you have to be careful and use "\*" because
# it seems the bash * operator is being applied somehow
find_files results/visualizations/washu/chipseq_peaks/ > $cand_paths_fn                                                                        

## locate the final problematic paths
problem_samples_fn="${outdir}/copy_and_rename.samples.txt"
problem_paths_fn="${outdir}/problem_paths.file-based.txt"
grep -f $problem_samples_fn $cand_paths_fn > $problem_paths_fn

echo "Check out the results with:"
echo "vim -p ${cand_paths_fn} ${problem_paths_fn}"
