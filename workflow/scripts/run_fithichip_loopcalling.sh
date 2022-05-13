#!/bin/bash -ex

#PBS -l nodes=1:ppn=1
#PBS -l mem=20GB
#PBS -l walltime=40:00:00
#PBS -o results/loops/logs/
#PBS -e results/loops/logs/
#PBS -N run_fithichip_loopcalling
#PBS -m ae
#PBS -j oe
#PBS -V


# Usage:
# workflow/scripts/run_fithichip_loopcalling.sh <HiCPro validPairs> <peak file> <output directory name>


source ~/.bashrc
hostname
TMPDIR=/scratch
cd $PBS_O_WORKDIR

# source tool paths
source workflow/source_paths.sh

# add the directories from source_paths.sh to PATH
PATH=$(dirname $hicpro_python):$PATH
PATH=$(dirname $hicpro):$PATH
PATH=$(dirname $split_reads):$PATH
PATH=$(dirname $hicpro2juicebox):$PATH

PATH=$(dirname $fithichip_python):$PATH
PATH=$(dirname $fithichip_r):$PATH
PATH=$(dirname $fithichip_r_library):$PATH
PATH=$(dirname $fithichip_peakinferhichip):$PATH
PATH=$(dirname $fithichip_call_loops):$PATH

PATH=/mnt/BioAdHoc/Groups/vd-ay/nrao/hichip_database/fithichip/software/bedtools2/bin:$PATH

# Config file input:
# 1) Valid pairs from HiCPro
# 2) Reference ChIP-seq / HiChIP peaks (in .bed format or narrowPeak format)
# 3) Output base directory under which all results will be stored

validPairsFile=$(realpath $1)
peakFile=$(realpath $2)
outDir=$(realpath "results/loops/$3")

mkdir -p $outDir

# copy the config files over to the output directory
cp config/fithichip/configfile_BiasCorrection_CoverageBias $outDir
cp config/fithichip/configfile_P2P_BiasCorrection_CoverageBias $outDir

# replace the lines of the config files with the input parameters
origValidPairs="ValidPairs=./TestData/Sample_ValidPairs.txt.gz"
newValidPairs="ValidPairs=$validPairsFile"
sed -i "s|$origValidPairs|$newValidPairs|" $outDir/configfile_BiasCorrection_CoverageBias
sed -i "s|$origValidPairs|$newValidPairs|" $outDir/configfile_P2P_BiasCorrection_CoverageBias

origPeaks="PeakFile=./TestData/Sample.Peaks.gz"
newPeaks="PeakFile=$peakFile"
sed -i "s|$origPeaks|$newPeaks|" $outDir/configfile_BiasCorrection_CoverageBias
sed -i "s|$origPeaks|$newPeaks|" $outDir/configfile_P2P_BiasCorrection_CoverageBias

origOutDir="OutDir=./TestData/results/"
newOutDir="OutDir=$outDir"
sed -i "s|$origOutDir|$newOutDir|" $outDir/configfile_BiasCorrection_CoverageBias
sed -i "s|$origOutDir|$newOutDir|" $outDir/configfile_P2P_BiasCorrection_CoverageBias

cd $(dirname $fithichip_call_loops)

# executing FitHiChIP according to the settings of configuration file
# any modification of input parameters should be done via the configuration file

# executing FitHiChIP(L) with coverage bias regression (loose background, more loops)
bash FitHiChIP_HiCPro.sh -C $outDir/configfile_BiasCorrection_CoverageBias

# executing FitHiChIP(S) with coverage bias regression (stringent background, fewer loops)
bash FitHiChIP_HiCPro.sh -C $outDir/configfile_P2P_BiasCorrection_CoverageBias


# this command is commented
# user may uncomment this command for differential analysis of FitHiChIP loops
# for two categories each with multiple replicates 
# a sample test data is provided in this repository
# bash Differetial_Analysis_Script.sh

# delete the temporary config files
rm "$outDir/configfile_BiasCorrection_CoverageBias"
rm "$outDir/configfile_P2P_BiasCorrection_CoverageBias"
