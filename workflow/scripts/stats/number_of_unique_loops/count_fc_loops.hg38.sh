

# setting the outdir for all results
outdir="results/stats/number_of_unique_loops/"
mkdir -p $outdir

###############################################################################
# Counting the number of unique loops in hg38, stringent, 5kb looops
###############################################################################

concat_fn="$outdir/fc_loops.unique_loops.hg38.stringent.5kb.concat.txt"
unique_fn="$outdir/fc_loops.unique_loops.hg38.stringent.5kb.unique.txt"
if [ ! -e $unique_fn ];
then

    # empty concat file is it exists
    truncate -s 0 $outdir/fc_loops.unique_loops.hg38.5kb.concat.txt

    # concating files
    printf "# concating files\n"
    glob_path="results/loops/fithichip/*Homo_Sapiens*_chipseq.peaks/S5/"
    glob_path+="FitHiChIP_Peak2ALL_b*_L20000_U2000000/P2PBckgr_*/Coverage_Bias/"
    glob_path+="FitHiC_BiasCorr/FitHiChIP-S5.interactions_FitHiC_Q0.01.bed"
    for fn in $(ls $glob_path);
    do
        num_lines=$(wc -l $fn | cut -f 1 -d " ")
        printf "$fn: $num_lines\n"
        cat $fn | sed '1d' | cut -f 1,2,3,4,5,6 >> $concat_fn
    done

    # getting the unique number of loops 
    printf "# getting the unique number of loops\n"
    sort $concat_fn | uniq > $unique_fn
fi

# counting the lines to get the unique number of loops
wc -l $unique_fn

###############################################################################
# Counting the number of unique loops in hg38, stringent, 10kb looops
###############################################################################

concat_fn="$outdir/fc_loops.unique_loops.hg38.stringent.10kb.concat.txt"
unique_fn="$outdir/fc_loops.unique_loops.hg38.stringent.10kb.unique.txt"
if [ ! -e $unique_fn ];
then

    # empty concat file is it exists
    truncate -s 0 $outdir/fc_loops.unique_loops.hg38.10kb.concat.txt

    # concating files
    printf "# concating files\n"
    glob_path="results/loops/fithichip/*Homo_Sapiens*_chipseq.peaks/S10/"
    glob_path+="FitHiChIP_Peak2ALL_b*_L20000_U2000000/P2PBckgr_*/Coverage_Bias/"
    glob_path+="FitHiC_BiasCorr/FitHiChIP-S10.interactions_FitHiC_Q0.01.bed"
    for fn in $(ls $glob_path);
    do
        num_lines=$(wc -l $fn | cut -f 1 -d " ")
        printf "$fn: $num_lines\n"
        cat $fn | sed '1d' | cut -f 1,2,3,4,5,6 >> $concat_fn
    done

    # getting the unique number of loops 
    printf "# getting the unique number of loops\n"
    sort $concat_fn | uniq > $unique_fn
fi

# counting the lines to get the unique number of loops
wc -l $unique_fn

###############################################################################
# Counting the number of unique loops in hg38, stringent, 25kb looops
###############################################################################

concat_fn="$outdir/fc_loops.unique_loops.hg38.stringent.25kb.concat.txt"
unique_fn="$outdir/fc_loops.unique_loops.hg38.stringent.25kb.unique.txt"
if [ ! -e $unique_fn ];
then

    # empty concat file is it exists
    truncate -s 0 $outdir/fc_loops.unique_loops.hg38.25kb.concat.txt

    # concating files
    printf "# concating files\n"
    glob_path="results/loops/fithichip/*Homo_Sapiens*_chipseq.peaks/S25/"
    glob_path+="FitHiChIP_Peak2ALL_b*_L20000_U2000000/P2PBckgr_*/Coverage_Bias/"
    glob_path+="FitHiC_BiasCorr/FitHiChIP-S25.interactions_FitHiC_Q0.01.bed"
    for fn in $(ls $glob_path);
    do
        num_lines=$(wc -l $fn | cut -f 1 -d " ")
        printf "$fn: $num_lines\n"
        cat $fn | sed '1d' | cut -f 1,2,3,4,5,6 >> $concat_fn
    done

    # getting the unique number of loops 
    printf "# getting the unique number of loops\n"
    sort $concat_fn | uniq > $unique_fn
fi

# counting the lines to get the unique number of loops
wc -l $unique_fn

###############################################################################
# Counting the number of unique loops in hg38, loose, 5kb looops
###############################################################################

concat_fn="$outdir/fc_loops.unique_loops.hg38.loose.5kb.concat.txt"
unique_fn="$outdir/fc_loops.unique_loops.hg38.loose.5kb.unique.txt"
if [ ! -e $unique_fn ];
then

    # empty concat file is it exists
    truncate -s 0 $outdir/fc_loops.unique_loops.hg38.5kb.concat.txt

    # concating files
    printf "# concating files\n"
    glob_path="results/loops/fithichip/*Homo_Sapiens*_chipseq.peaks/L5/"
    glob_path+="FitHiChIP_Peak2ALL_b*_L20000_U2000000/P2PBckgr_*/Coverage_Bias/"
    glob_path+="FitHiC_BiasCorr/FitHiChIP-L5.interactions_FitHiC_Q0.01.bed"
    for fn in $(ls $glob_path);
    do
        num_lines=$(wc -l $fn | cut -f 1 -d " ")
        printf "$fn: $num_lines\n"
        cat $fn | sed '1d' | cut -f 1,2,3,4,5,6 >> $concat_fn
    done

    # getting the unique number of loops 
    printf "# getting the unique number of loops\n"
    sort $concat_fn | uniq > $unique_fn
fi

# counting the lines to get the unique number of loops
wc -l $unique_fn

###############################################################################
# Counting the number of unique loops in hg38, loose, 10kb looops
###############################################################################

concat_fn="$outdir/fc_loops.unique_loops.hg38.loose.10kb.concat.txt"
unique_fn="$outdir/fc_loops.unique_loops.hg38.loose.10kb.unique.txt"
if [ ! -e $unique_fn ];
then

    # empty concat file is it exists
    truncate -s 0 $outdir/fc_loops.unique_loops.hg38.10kb.concat.txt

    # concating files
    printf "# concating files\n"
    glob_path="results/loops/fithichip/*Homo_Sapiens*_chipseq.peaks/L10/"
    glob_path+="FitHiChIP_Peak2ALL_b*_L20000_U2000000/P2PBckgr_*/Coverage_Bias/"
    glob_path+="FitHiC_BiasCorr/FitHiChIP-L10.interactions_FitHiC_Q0.01.bed"
    for fn in $(ls $glob_path);
    do
        num_lines=$(wc -l $fn | cut -f 1 -d " ")
        printf "$fn: $num_lines\n"
        cat $fn | sed '1d' | cut -f 1,2,3,4,5,6 >> $concat_fn
    done

    # getting the unique number of loops 
    printf "# getting the unique number of loops\n"
    sort $concat_fn | uniq > $unique_fn
fi

# counting the lines to get the unique number of loops
wc -l $unique_fn

###############################################################################
# Counting the number of unique loops in hg38, loose, 25kb looops
###############################################################################

concat_fn="$outdir/fc_loops.unique_loops.hg38.loose.25kb.concat.txt"
unique_fn="$outdir/fc_loops.unique_loops.hg38.loose.25kb.unique.txt"
if [ ! -e $unique_fn ];
then

    # empty concat file is it exists
    truncate -s 0 $outdir/fc_loops.unique_loops.hg38.25kb.concat.txt

    # concating files
    printf "# concating files\n"
    glob_path="results/loops/fithichip/*Homo_Sapiens*_chipseq.peaks/L25/"
    glob_path+="FitHiChIP_Peak2ALL_b*_L20000_U2000000/P2PBckgr_*/Coverage_Bias/"
    glob_path+="FitHiC_BiasCorr/FitHiChIP-L25.interactions_FitHiC_Q0.01.bed"
    for fn in $(ls $glob_path);
    do
        num_lines=$(wc -l $fn | cut -f 1 -d " ")
        printf "$fn: $num_lines\n"
        cat $fn | sed '1d' | cut -f 1,2,3,4,5,6 >> $concat_fn
    done

    # getting the unique number of loops 
    printf "# getting the unique number of loops\n"
    sort $concat_fn | uniq > $unique_fn
fi

# counting the lines to get the unique number of loops
wc -l $unique_fn





###############################################################################
# Counting the number of unique loops in hg38 across all settings
###############################################################################
printf "# Counting the number of unique loops in hg38 across all settings\n"

all_unique_loops="$outdir/fc_loops.unique_loops.hg38.all.unique.txt"
if [ ! -e $all_unique_loops ]
then
    cat "$outdir/fc_loops.unique_loops.hg38.stringent.5kb.unique.txt" "$outdir/fc_loops.unique_loops.hg38.stringent.10kb.unique.txt" "$outdir/fc_loops.unique_loops.hg38.stringent.25kb.unique.txt" "$outdir/fc_loops.unique_loops.hg38.loose.5kb.unique.txt" "$outdir/fc_loops.unique_loops.hg38.loose.10kb.unique.txt" "$outdir/fc_loops.unique_loops.hg38.loose.25kb.unique.txt" | sort | uniq > $all_unique_loops
fi

# counting the lines to get the unique number of loops
wc -l $all_unique_loops
