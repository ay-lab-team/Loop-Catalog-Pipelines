#!/bin/bash -ex
#PBS -l nodes=1:ppn=1
#PBS -l mem=20GB
#PBS -l walltime=10:00:00
#PBS -M nrao@lji.org
#PBS -m ae
#PBS -j eo
#PBS -V

# Usage:
# ./workflow/scripts/run_fithichip.sh <sample name> <read length>

source ~/.bashrc
hostname
TMPDIR=/scratch
cd \$PBS_O_WORKDIR

source activate fithichip

sample_name=$1
concatenated_pairs="results/hicpro/$sample_name/concatenated_pairs/"

outdir=results/peaks/fithichip/$sample_name
mkdir -p outdir

refGenomeStr='hs' # default is hs

# For this value, go to the SRA run selector, click on the SRR ID, then the length should be listed as "L=_"
ReadLength=$2

/mnt/BioAdHoc/Groups/vd-ay/nrao/hichip_database/fithichip/FitHiChIP/Imp_Scripts/PeakInferHiChIP.sh -H $concatenated_pairs -D $outdir -R $refGenomeStr -L $ReadLength
