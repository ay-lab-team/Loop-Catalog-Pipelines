import os
import glob

###############################################################################
# Helper Functions
###############################################################################

def count_uniq_loops_across_files(filelist, verbose=True):
    '''
    Count the unique number of loops across all files.
    '''

    # make an loop set
    loop_set = set()

    # loop through the file
    for fn in filelist:

        # print processing message
        if verbose:
            print('processing: {}'.format(fn))

        # read lines and add to loop set
        with open(fn, "r") as file:
            for line in file.readlines()[1:]:
                curr_loop = tuple(line.split()[:6])
                loop_set.add(curr_loop)

    # return the unique number of loops
    return(len(loop_set))

def save_results(num_loops, outfn):
    '''
    Save the results.
    '''
    with open(outfn, 'w') as fh:
        fh.write(str(num_loops))

def count_uniq_loops_across_files_and_save(filelist, outfn, override=False, verbose=True):

    # run if the file doesn't exist or there is an override
    if not os.path.exists(outfn) or override:

        # count
        num_unique_loops = count_uniq_loops_across_files(loop_fns, verbose=True)

        # save
        save_results(num_unique_loops, outfn)

###############################################################################
# Global Settings
###############################################################################

# setting the outdir for all results
outdir = 'results/stats/number_of_unique_loops/'
os.makedirs(outdir, exist_ok=True)

# dictionary to map been resolutions
ref_dict = {'res_short_5000': '5', 'res_kb_5000': '5kb',
            'res_short_10000': '10', 'res_kb_10000': '10kb',
            'res_short_25000': '25', 'res_kb_25000': '25kb'}

# set the global override
override = True
override = False

################################################################################
## Human loops for ALL FC, FH and HiCCUPs Loops Combined (FitHiChIP with Stringent Mode)
################################################################################

print("## Human loops for ALL FC, FH and HiCCUPs Loops Combined (FitHiChIP with Stringent Mode)")

# glob pattern for the fc main samples
main_fc_loops_template = 'results/loops/fithichip/*Homo_Sapiens*_chipseq.peaks/S{res_short}/'
main_fc_loops_template += 'FitHiChIP_Peak2ALL_b*_L20000_U2000000/P2PBckgr_*/Coverage_Bias/'
main_fc_loops_template += 'FitHiC_BiasCorr/FitHiChIP-S{res_short}.interactions_FitHiC_Q0.01.bed'

# glob pattern for the fc biorep samples
biorep_fc_loops_template = 'results/biorep_merged/results/loops/fithichip/*Homo_Sapiens*_chipseq.peaks/S{res_short}/'
biorep_fc_loops_template += 'FitHiChIP_Peak2ALL_b*_L20000_U2000000/P2PBckgr_*/Coverage_Bias/'
biorep_fc_loops_template += 'FitHiC_BiasCorr/FitHiChIP-S{res_short}.interactions_FitHiC_Q0.01.bed'

# glob pattern for the fh main samples
main_fh_loops_template = 'results/loops/fithichip/*Homo_Sapiens*_fithichip.peaks/S{res_short}/'
main_fh_loops_template += 'FitHiChIP_Peak2ALL_b*_L20000_U2000000/P2PBckgr_*/Coverage_Bias/'
main_fh_loops_template += 'FitHiC_BiasCorr/FitHiChIP-S{res_short}.interactions_FitHiC_Q0.01.bed'

# glob pattern for the fh biorep samples
biorep_fh_loops_template = 'results/biorep_merged/results/loops/fithichip/*Homo_Sapiens*_fithichip.peaks/S{res_short}/'
biorep_fh_loops_template += 'FitHiChIP_Peak2ALL_b*_L20000_U2000000/P2PBckgr_*/Coverage_Bias/'
biorep_fh_loops_template += 'FitHiC_BiasCorr/FitHiChIP-S{res_short}.interactions_FitHiC_Q0.01.bed'

# glob pattern for the hiccups main samples
main_hiccups_loops_template = 'results/loops/hiccups/whole_genome_all_batches/*Homo_Sapiens*/postprocessed_pixels_{res_long}.bedpe'

# glob pattern for the hiccups biorep samples
biorep_hiccups_loops_template = 'results/biorep_merged/results/loops/hiccups/whole_genome/*Homo_Sapiens*/postprocessed_pixels_{res_long}.bedpe'

# counting the number of unique loops in hg38, stringent, 5,10,25kb loops

for res_long in [5000, 10000, 25000]:

    print('processing filelist for {} resolution.'.format(res_long))

    # get the resolution short form
    res_short = ref_dict['res_short_{}'.format(res_long)]

    # get globs for the fc samples 
    cmain_fc_loops_glob = main_fc_loops_template.format(res_short=res_short)
    cbiorep_fc_loops_glob = biorep_fc_loops_template.format(res_short=res_short)

    # get globs for the fh samples 
    cmain_fh_loops_glob = main_fh_loops_template.format(res_short=res_short)
    cbiorep_fh_loops_glob = biorep_fh_loops_template.format(res_short=res_short)

    # get globs for the hiccups samples 
    cmain_hiccups_loops_glob = main_hiccups_loops_template.format(res_long=res_long)
    cbiorep_hiccups_loops_glob = biorep_hiccups_loops_template.format(res_long=res_long)

    # get all of the files into a single list
    loop_fns = glob.glob(cmain_fc_loops_glob)+ glob.glob(cbiorep_fc_loops_glob)
    loop_fns += glob.glob(cmain_fh_loops_glob)+ glob.glob(cbiorep_fh_loops_glob)
    loop_fns += glob.glob(cmain_hiccups_loops_glob)+ glob.glob(cbiorep_hiccups_loops_glob)

    # perform the counting 
    unique_fn = os.path.join(outdir, 'unique_loops.hg38.{res_long}.unique.txt'.format(res_long=res_long))
    count_uniq_loops_across_files_and_save(loop_fns, unique_fn, override=override, verbose=True)

# print the final result
total = 0
for res_long in [5000, 10000, 25000]:

    unique_fn = os.path.join(outdir, 'unique_loops.hg38.{res_long}.unique.txt'.format(res_long=res_long))
    with open(unique_fn) as fr:
        num_loops = fr.read()
        msg = 'hg38 stringent {}: {}'.format(res_long, num_loops)
        print(msg)

        # sum for the total
        total += int(num_loops)

msg = 'hg38 stringent total across all resolutions: {}'.format(total)
print(msg)

###############################################################################
# Mouse loops for ALL FC, FH and HiCCUPs Loops Combined (FitHiChIP with Stringent Mode)
###############################################################################
print('# Mouse loops for ALL FC, FH and HiCCUPs Loops Combined (FitHiChIP with Stringent Mode)')

# glob pattern for the fc main samples
main_fc_loops_template = 'results/loops/fithichip/*Mus_Musculus*_chipseq.peaks/S{res_short}/'
main_fc_loops_template += 'FitHiChIP_Peak2ALL_b*_L20000_U2000000/P2PBckgr_*/Coverage_Bias/'
main_fc_loops_template += 'FitHiC_BiasCorr/FitHiChIP-S{res_short}.interactions_FitHiC_Q0.01.bed'

# glob pattern for the fc biorep samples
biorep_fc_loops_template = 'results/biorep_merged/results/loops/fithichip/*Mus_Musculus*_chipseq.peaks/S{res_short}/'
biorep_fc_loops_template += 'FitHiChIP_Peak2ALL_b*_L20000_U2000000/P2PBckgr_*/Coverage_Bias/'
biorep_fc_loops_template += 'FitHiC_BiasCorr/FitHiChIP-S{res_short}.interactions_FitHiC_Q0.01.bed'

# glob pattern for the fh main samples
main_fh_loops_template = 'results/loops/fithichip/*Mus_Musculus*_fithichip.peaks/S{res_short}/'
main_fh_loops_template += 'FitHiChIP_Peak2ALL_b*_L20000_U2000000/P2PBckgr_*/Coverage_Bias/'
main_fh_loops_template += 'FitHiC_BiasCorr/FitHiChIP-S{res_short}.interactions_FitHiC_Q0.01.bed'

# glob pattern for the fh biorep samples
biorep_fh_loops_template = 'results/biorep_merged/results/loops/fithichip/*Mus_Musculus*_fithichip.peaks/S{res_short}/'
biorep_fh_loops_template += 'FitHiChIP_Peak2ALL_b*_L20000_U2000000/P2PBckgr_*/Coverage_Bias/'
biorep_fh_loops_template += 'FitHiC_BiasCorr/FitHiChIP-S{res_short}.interactions_FitHiC_Q0.01.bed'

# glob pattern for the hiccups main samples
main_hiccups_loops_template = 'results/loops/hiccups/whole_genome_all_batches/*Mus_Musculus*/postprocessed_pixels_{res_long}.bedpe'

# glob pattern for the hiccups biorep samples
biorep_hiccups_loops_template = 'results/biorep_merged/results/loops/hiccups/whole_genome/*Mus_Musculus*/postprocessed_pixels_{res_long}.bedpe'

# counting the number of unique loops in mm10, stringent, 5,10,25kb loops

for res_long in [5000, 10000, 25000]:

    print('processing filelist for {} resolution.'.format(res_long))

    # get the resolution short form
    res_short = ref_dict['res_short_{}'.format(res_long)]

    # get globs for the fc samples 
    cmain_fc_loops_glob = main_fc_loops_template.format(res_short=res_short)
    cbiorep_fc_loops_glob = biorep_fc_loops_template.format(res_short=res_short)

    # get globs for the fh samples 
    cmain_fh_loops_glob = main_fh_loops_template.format(res_short=res_short)
    cbiorep_fh_loops_glob = biorep_fh_loops_template.format(res_short=res_short)

    # get globs for the hiccups samples 
    cmain_hiccups_loops_glob = main_hiccups_loops_template.format(res_long=res_long)
    cbiorep_hiccups_loops_glob = biorep_hiccups_loops_template.format(res_long=res_long)

    # get all of the files into a single list
    loop_fns = glob.glob(cmain_fc_loops_glob)+ glob.glob(cbiorep_fc_loops_glob)
    loop_fns += glob.glob(cmain_fh_loops_glob)+ glob.glob(cbiorep_fh_loops_glob)
    loop_fns += glob.glob(cmain_hiccups_loops_glob)+ glob.glob(cbiorep_hiccups_loops_glob)

    # perform the counting 
    unique_fn = os.path.join(outdir, 'unique_loops.mm10.{res_long}.unique.txt'.format(res_long=res_long))
    count_uniq_loops_across_files_and_save(loop_fns, unique_fn, override=override, verbose=True)

# print the final result
total = 0
for res_long in [5000, 10000, 25000]:

    unique_fn = os.path.join(outdir, 'unique_loops.mm10.{res_long}.unique.txt'.format(res_long=res_long))
    with open(unique_fn) as fr:
        num_loops = fr.read()
        msg = 'mm10 stringent {}: {}'.format(res_long, num_loops)
        print(msg)

        # sum for the total
        total += int(num_loops)

msg = 'mm10 stringent total across all resolutions: {}'.format(total)
print(msg)

