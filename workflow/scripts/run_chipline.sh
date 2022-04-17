#!/bin/bash -ex

#PBS -l nodes=1:ppn=16
#PBS -l mem=100GB
#PBS -l walltime=40:00:00
#PBS -m ae
#PBS -j oe
#PBS -V

# Usage:
# ./workflow/scripts/run_chipline.sh <input fastq folder> <input control folder (bam files)> <output folder name>

source ~/.bashrc
hostname
TMPDIR=/scratch
cd $PBS_O_WORKDIR

source activate chipline
PATH=/share/apps/R/3.6.1/bin/:$PATH
PATH=/mnt/BioAdHoc/Groups/vd-ay/nrao/hichip_database/chipline/software:$PATH

PATH=/mnt/BioAdHoc/Groups/vd-ay/nrao/hichip_database/chipline/software/phantompeakqualtools/:$PATH
PATH=/share/apps/picard-tools/picard-tools-2.7.1/:$PATH
PATH=/share/apps/python/python-3.4.6/bin/:$PATH # deeptools


#=================
# main executable script of the ChIP seq pipeline
#=================
# developed by - Sourya Bhattacharyya
# Vijay-AY lab
# La Jolla Institute for Allergy and Immunology
#=================

CodeDir="/mnt/BioAdHoc/Groups/vd-ay/nrao/hichip_database/chipline/ChIPLine/"
CodeExec="$CodeDir/bin/pipeline.sh"

#=================
# script 1 - when fastq files of paired end read are provided as the input
#=================

workdir="results/loops/chipline"
genome="/mnt/BioAdHoc/Groups/vd-ay/Database_HiChIP_eQTL_GWAS/Data/RefGenome/bowtie2_index/hg38/hg38"

# directory with input fastqs
dirdata=$1

# set variables for input fastqs
fastqs=()
for FILE in $dirdata/*.fastq.gz
do
    fastqs+=($FILE)
done

inpfile1=${fastqs[0]}

if [[ ${#a[@]} -eq 2 ]]
then
    inpfile2=${fastqs[1]}
fi    

if [[$# -eq 3]]
then
    prefix=$3
else
    prefix=$2
fi

outdir="$workdir/$prefix"
mkdir -p $outdir


# Set the control file

control_pattern=""

if [[$# -eq 3]]
then
    control_folder=$2
    for i in $controlfolder/*.bam
    do
        control_pattern+="-c $i"
    done
fi

# run the pipeline
if [[ ${#a[@]} -eq 2 ]]
then
    $CodeExec -f $inpfile1 -r $inpfile2 -C "config/chipline/configfile.txt" -n $prefix -g $genome -d $outdir -t 16 -m "16G" -T 0 -q 30 -D 1 -p "hs" -O 1 $control_pattern
else
    $CodeExec -f $inpfile1 -C "config/chipline/configfile.txt" -n $prefix -g $genome -d $outdir -t 16 -m "16G" -T 0 -q 30 -D 1 -p "hs" -O 1 $control_pattern
fi

