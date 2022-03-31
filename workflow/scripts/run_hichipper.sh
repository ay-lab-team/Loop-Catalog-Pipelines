#!/bin/bash -ex
#PBS -l nodes=1:ppn=1
#PBS -l mem=100GB
#PBS -l walltime=100:00:00
#PBS -m ae
#PBS -j eo
#PBS -V

source ~/.bashrc
hostname
TMPDIR=/scratch
cd $PBS_O_WORKDIR

# Usage:
# ./workflow/scripts/run_hichipper.sh <name of sample> <restriction fragment file> <HiC-Pro output folder> <read length>

source activate hichipper

"peaks:
  - EACH,ALL
resfrags:
  - $2
hicpro_output:
  - $3" > config_temp.yaml


hichipper --out results/peaks/hichipper/$1 --keep-temp-files --skip-diffloop --read-length $4 config_temp.yaml

rm config_temp.yaml