# run bash in strict mode
set -euo pipefail
IFS=$'\n\t'

# source tool paths
source workflow/source_paths.sh

sample_name="$1"

# printing sample information
echo
echo "Processing"
echo "----------"
echo "sample_name: $sample_name"
echo

# get input and output file
L5="results/loops/fithichip/${sample_name}_chipseq.peaks/L5/FitHiChIP_Peak2ALL_b5000_L20000_U2000000/P2PBckgr_0/Coverage_Bias/FitHiC_BiasCorr/FitHiChIP-L5.interactions_FitHiC_Q0.01.bed"
L10="results/loops/fithichip/${sample_name}_chipseq.peaks/L10/FitHiChIP_Peak2ALL_b10000_L20000_U2000000/P2PBckgr_0/Coverage_Bias/FitHiC_BiasCorr/FitHiChIP-L10.interactions_FitHiC_Q0.01.bed"
L25="results/loops/fithichip/${sample_name}_chipseq.peaks/L25/FitHiChIP_Peak2ALL_b25000_L20000_U2000000/P2PBckgr_0/Coverage_Bias/FitHiC_BiasCorr/FitHiChIP-L25.interactions_FitHiC_Q0.01.bed"
S5="results/loops/fithichip/${sample_name}_chipseq.peaks/S5/FitHiChIP_Peak2ALL_b5000_L20000_U2000000/P2PBckgr_1/Coverage_Bias/FitHiC_BiasCorr/FitHiChIP-S5.interactions_FitHiC_Q0.01.bed"
S10="results/loops/fithichip/${sample_name}_chipseq.peaks/S10/FitHiChIP_Peak2ALL_b10000_L20000_U2000000/P2PBckgr_1/Coverage_Bias/FitHiC_BiasCorr/FitHiChIP-S10.interactions_FitHiC_Q0.01.bed"
S25="results/loops/fithichip/${sample_name}_chipseq.peaks/S25/FitHiChIP_Peak2ALL_b25000_L20000_U2000000/P2PBckgr_1/Coverage_Bias/FitHiC_BiasCorr/FitHiChIP-S25.interactions_FitHiC_Q0.01.bed"


function fithichip_to_washu() {

    filename=$1
    sample_name=$2
    combo=$3

    if [ -s "$filename" ] && [ $(wc -l < $filename) -gt 1 ]; then

        outdir="results/visualizations/washu/fithichip_loops_chipseq/${sample_name}/${combo}/"
        mkdir -p $outdir
        outfile="${outdir}/${sample_name}.fithichip.${combo}.loops.chipseq.peaks.txt"

        awk 'BEGIN{OFS="\t"}; {score=-log($26)/log(10); if (NR > 1) {print $1, $2, $3, $4 ":" $5 "-" $6 ",score\n" $4, $5, $6, $1 ":" $2 "-" $3 ",score"}}' $filename | sort -k1,1 -k2,2n > $outfile

        $bgzip -f $outfile
        $tabix -f -p bed "${outfile}.gz"
    fi
}

# convert if file exists 
if [ -s "$L5" ] && [ $(wc -l < $L5) -gt 1 ]; then
    fithichip_to_washu $L5 $sample_name L5
fi

# convert if file exists 
if [ -s "$L10" ] && [ $(wc -l < $L10) -gt 1 ]; then
    fithichip_to_washu $L10 $sample_name L10
fi

# convert if file exists 
if [ -s "$L25" ] && [ $(wc -l < $L25) -gt 1 ]; then
    fithichip_to_washu $L25 $sample_name L25
fi

# convert if file exists 
if [ -s "$S5" ] && [ $(wc -l < $S5) -gt 1 ]; then
    fithichip_to_washu $S5 $sample_name S5
fi

# convert if file exists 
if [ -s "$S10" ] && [ $(wc -l < $S10) -gt 1 ]; then
    fithichip_to_washu $S10 $sample_name S10
fi

# convert if file exists 
if [ -s "$S25" ] && [ $(wc -l < $S25) -gt 1 ]; then
    fithichip_to_washu $S25 $sample_name S25
fi

## printing done msg
#echo
#echo "Done"
#echo "----------"
#echo "sample_name: $sample_name"
#echo