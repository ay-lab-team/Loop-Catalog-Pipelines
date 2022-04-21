#!/bin/bash -ex

#PBS -l nodes=1:ppn=16
#PBS -l mem=100GB
#PBS -l walltime=40:00:00
#PBS -o results/peaks/chipline/logs/
#PBS -e results/peaks/chipline/logs/
#PBS -N run_chipline
#PBS -m ae
#PBS -j oe
#PBS -V

# Usage:
# qsub workflow/scripts/run_chipline.sh -F "<input fastq folder> <input control bam file>"

source ~/.bashrc
hostname
TMPDIR=/scratch
cd $PBS_O_WORKDIR

# run bash in strict mode
set -euo pipefail
IFS=$'\n\t'

# set paths to softwares
PATH=/mnt/BioAdHoc/Groups/vd-ay/nrao/hichip_database/chipline/software/bowtie2/bowtie2-2.4.5:$PATH # bowtie2
PATH=/mnt/BioAdHoc/Groups/vd-ay/nrao/hichip_database/chipline/software/samtools/samtools-1.15.1:$PATH # samtools
PATH=/share/apps/picard-tools/picard-tools-2.7.1/:$PATH # picard
PATH=/mnt/BioAdHoc/Groups/vd-ay/nrao/hichip_database/chipline/software/phantompeakqualtools/:$PATH # phantompeakqualtools
PATH=/mnt/BioAdHoc/Groups/vd-ay/nrao/hichip_database/chipline/software:$PATH # Utilities "bedGraphToBigWig", "bedSort", "bigBedToBed", "hubCheck", "fetchChromSizes"
PATH=/share/apps/python/python-3.4.6/bin/:$PATH # deeptools
PATH=/share/apps/python/python-2.7.13/bin/:$PATH # macs2
PATH=/mnt/BioAdHoc/Groups/vd-ay/nrao/hichip_database/chipline/software/homer/bin/:$PATH # HOMER
PATH=/share/apps/R/3.6.1/bin/:$PATH # R

#=================
# main executable script of the ChIP seq pipeline
#=================
# developed by - Sourya Bhattacharyya
# modified by - Nikhil Rao
# Vijay-AY lab
# La Jolla Institute for Allergy and Immunology
#=================

CodeDir="/mnt/BioAdHoc/Groups/vd-ay/nrao/hichip_database/chipline/ChIPLine/"
CodeExec="$CodeDir/bin/pipeline.sh"

workdir="results/peaks/chipline"
genome="/mnt/BioAdHoc/Groups/vd-ay/Database_HiChIP_eQTL_GWAS/Data/RefGenome/bowtie2_index/hg38/hg38"

# directory with input fastqs
dirdata=$1

# set variables for input fastqs
fastqs=($dirdata/*.fastq.gz)

inpfile1=${fastqs[0]}

if [[ ${#fastqs[@]} -eq 2 ]]
then
    inpfile2=${fastqs[1]}
fi

prefix=$(basename $1)

outdir="$workdir/$prefix"
mkdir -p $outdir

# run the pipeline
if [ ${#fastqs[@]} -eq 2 ]
then
    
    if [ $# -eq 2 ]
    then
        $CodeExec -f $inpfile1 -r $inpfile2 -C "config/chipline/configfile.txt" -n $prefix -g $genome -d $outdir -w "hg38" -t 16 -m "16G" -T 0 -q 30 -D 1 -p "hs" -O 1 -c $2
    
    else
        $CodeExec -f $inpfile1 -r $inpfile2 -C "config/chipline/configfile.txt" -n $prefix -g $genome -d $outdir -w "hg38" -t 16 -m "16G" -T 0 -q 30 -D 1 -p "hs" -O 1
    fi
    
else

    if [ $# -eq 2 ]
    then
        $CodeExec -f $inpfile1 -C "config/chipline/configfile.txt" -n $prefix -g $genome -d $outdir -w "hg38" -t 16 -m "16G" -T 0 -q 30 -D 1 -p "hs" -O 1 -c $2
    
    else
        $CodeExec -f $inpfile1 -C "config/chipline/configfile.txt" -n $prefix -g $genome -d $outdir -w "hg38" -t 16 -m "16G" -T 0 -q 30 -D 1 -p "hs" -O 1
    fi
    
fi
