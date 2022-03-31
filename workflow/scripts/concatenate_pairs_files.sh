#!/bin/bash -ex
#PBS -l nodes=1:ppn=1
#PBS -l mem=20GB
#PBS -l walltime=2:00:00
#PBS -M kfetter@lji.org
#PBS -m ae
#PBS -j eo
#PBS -V
source ~/.bashrc
hostname
TMPDIR=/scratch
cd $PBS_O_WORKDIR

hicpro_basefolder=$1
hicpro_results="$hicpro_basefolder/hic_results/data/"

sample_name=$2

outdir="results/hicpro/$sample_name/concatenated_pairs/"
mkdir -p $outdir

cat $hicpro_results/*'.DEPairs' >> "$outdir/all_${sample_name}.bwt2pairs.DEPairs"
cat $basedir/*'.SCPairs' >> "$outdir/all_${sample_name}.bwt2pairs.SCPairs"
cat $basedir/*'.REPairs' >> "$outdirall_${sample_name}.bwt2pairs.REPairs"
cat $basedir/*'.validPairs' >> "$outdir/all_${sample_name}.bwt2pairs.validPairs"
cat $basedir/*'.allValidPairs' >> "$outdir/${sample_name}.allValidPairs"