#PBS -l nodes=1:ppn=1
#PBS -l mem=5gb
#PBS -l walltime=1:00:00
#PBS -e results/visualizations/logs/
#PBS -o results/visualizations/logs/
#PBS -N to_washu.sh
#PBS -V

# print start time message
start_time=$(date "+%Y.%m.%d.%H.%M")
echo "Start time: $start_time"

# print start message
echo "Started: to_washu"

# run bash in strict mode
set -euo pipefail
IFS=$'\n\t'

# make sure to work starting from the github base directory for this script
cd $PBS_O_WORKDIR

# source tool paths
source workflow/source_paths.sh

# extract the sample information using the PBS ARRAYID
samplesheet="results/samplesheets/post-hicpro/current-post-hicpro-without-header.tsv"
sample_info=( $(cat $samplesheet | sed -n "${PBS_ARRAYID}p") )
sample_name="${sample_info[0]}"

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

# convert if file exists 
if [ -s "${L5}" ] && [ $(wc -l < ${L5}) -gt 1 ]; then
    outdir="results/visualizations/washu/fithichip_loops_chipseq/${sample_name}/L5/"
    mkdir -p $outdir
    outfile="${outdir}${sample_name}.fithichip.L5.loops.chipseq.peaks.txt"

    awk -F['\t'] '{if (NR > 1) {print $1"\t"$2"\t"$3"\t"$4":"$5"-"$6",10\n"$4"\t"$5"\t"$6"\t"$1":"$2"-"$3",10"}}' ${L5} | sort -k1,1 -k2,2n > $outfile

    bgzip $outfile
    tabix -f -p bed $outfile'.gz'
fi

if [ -s "${L10}" ] && [ $(wc -l < ${L10}) -gt 1 ]; then
    outdir="results/visualizations/washu/fithichip_loops_chipseq/${sample_name}/L10/"
    mkdir -p $outdir
    outfile="${outdir}${sample_name}.fithichip.L10.loops.chipseq.peaks.txt"

    awk -F['\t'] '{if (NR > 1) {print $1"\t"$2"\t"$3"\t"$4":"$5"-"$6",10\n"$4"\t"$5"\t"$6"\t"$1":"$2"-"$3",10"}}' ${L10} | sort -k1,1 -k2,2n > $outfile

    bgzip $outfile
    tabix -f -p bed $outfile'.gz'
fi

if [ -s "${L25}" ] && [ $(wc -l < ${L25}) -gt 1 ]; then
    outdir="results/visualizations/washu/fithichip_loops_chipseq/${sample_name}/L25/"
    mkdir -p $outdir
    outfile="${outdir}${sample_name}.fithichip.L25.loops.chipseq.peaks.txt"

    awk -F['\t'] '{if (NR > 1) {print $1"\t"$2"\t"$3"\t"$4":"$5"-"$6",10\n"$4"\t"$5"\t"$6"\t"$1":"$2"-"$3",10"}}' ${L25} | sort -k1,1 -k2,2n > $outfile

    bgzip $outfile
    tabix -f -p bed $outfile'.gz'
fi

if [ -s "${S5}" ] && [ $(wc -l < ${S5}) -gt 1 ]; then
    outdir="results/visualizations/washu/fithichip_loops_chipseq/${sample_name}/S5/"
    mkdir -p $outdir
    outfile="${outdir}${sample_name}.fithichip.S5.loops.chipseq.peaks.txt"

    awk -F['\t'] '{if (NR > 1) {print $1"\t"$2"\t"$3"\t"$4":"$5"-"$6",10\n"$4"\t"$5"\t"$6"\t"$1":"$2"-"$3",10"}}' ${S5} | sort -k1,1 -k2,2n > $outfile

    bgzip $outfile
    tabix -f -p bed $outfile'.gz'
fi

if [ -s "${S10}" ] && [ $(wc -l < ${S10}) -gt 1 ]; then
    outdir="results/visualizations/washu/fithichip_loops_chipseq/${sample_name}/S10/"
    mkdir -p $outdir
    outfile="${outdir}${sample_name}.fithichip.S10.loops.chipseq.peaks.txt"

    awk -F['\t'] '{if (NR > 1) {print $1"\t"$2"\t"$3"\t"$4":"$5"-"$6",10\n"$4"\t"$5"\t"$6"\t"$1":"$2"-"$3",10"}}' ${S10} | sort -k1,1 -k2,2n > $outfile

    bgzip $outfile
    tabix -f -p bed $outfile'.gz'
fi

if [ -s "${S25}" ] && [ $(wc -l < ${S25}) -gt 1 ]; then
    outdir="results/visualizations/washu/fithichip_loops_chipseq/${sample_name}/S25/"
    mkdir -p $outdir
    outfile="${outdir}${sample_name}.fithichip.S25.loops.chipseq.peaks.txt"

    awk -F['\t'] '{if (NR > 1) {print $1"\t"$2"\t"$3"\t"$4":"$5"-"$6",10\n"$4"\t"$5"\t"$6"\t"$1":"$2"-"$3",10"}}' ${S25} | sort -k1,1 -k2,2n > $outfile

    bgzip $outfile
    tabix -f -p bed $outfile'.gz'
fi

# print end message
echo "Ended: converting to washu format"

# print end time message
end_time=$(date "+%Y.%m.%d.%H.%M")
echo "End time: $end_time"