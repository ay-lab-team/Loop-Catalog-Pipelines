#!/bin/bash
#SBATCH --job-name=organize_fastqs
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=1gb
#SBATCH --time=1:00:00
#SBATCH --output=results/fastqs/chipseq_pieqtl/job-%j.out
#SBATCH --error=results/fastqs/chipseq_pieqtl/job-%j.err

# run bash in strict mode
set -euo pipefail
IFS=$'\n\t'

#====================
# NOTE: CD4N, CD8N, NK are empty 
#====================

#====================
# get Naive B samples of donors 1800, 1814, 1815, 1816, 1829, 1831
#====================

# BaseDir="/mnt/NGSAnalyses/ChIP-Seq/Mapping/004291_R24_NB_AF"
# FastqDir="${BaseDir}/input_FASTQ"

# OutBaseDir="/mnt/BioAdHoc/Groups/vd-ay/kfetter/hichip-db-loop-calling/results/fastqs/chipseq_pieqtl/Naive_B"
# mkdir -p $OutBaseDir

# LogFile="${OutBaseDir}/Samples.txt"
# Samplesheet="${OutBaseDir}/NB_samplesheet.txt"

# for donor in 2_A_NaveB_2_A2_1800_RH1 17_B_NaveB_1_B1_1814_RH1 21_B_NaveB_5_B5_1815_RH1 1_A_NaveB_1_A1_1816_RH1 35_C_NaveB_3_C3_1829_RH1 5_A_NaveB_5_A5_1831_RH1; do
#     echo ${donor} >> ${LogFile}
#     for fq in ${FastqDir}/${donor}*/*.fastq.gz; do
#         echo ${fq} >> ${LogFile}
#         mkdir -p ${OutBaseDir}/${donor}
#         zcat ${fq} >> ${OutBaseDir}/${donor}/${donor}.fastq
#     done
#     pigz ${OutBaseDir}/${donor}.fastq
#     echo >> ${LogFile}
# done

# for donor in 1800 1814 1815 1816 1829 1831; do 
#     echo -e "NB_${donor}.phs001703v3p1.Homo_Sapiens.H3K27ac.b1\t$(ls ${OutBaseDir} | grep ${donor})\tN/A\tgrch38" >> ${Samplesheet}
# done

#====================
# get Mono samples of donors 1800, 1814, 1815, 1816, 1829, 1831
#====================

# BaseDir="/mnt/NGSAnalyses/ChIP-Seq/Mapping/004020_R24_ClassMONO_RunsAF"
# FastqDir="${BaseDir}/input_FASTQ"

# OutBaseDir="/mnt/BioAdHoc/Groups/vd-ay/kfetter/hichip-db-loop-calling/results/fastqs/chipseq_pieqtl/Mono"
# mkdir -p $OutBaseDir

# LogFile="${OutBaseDir}/Samples.txt"
# Samplesheet="${OutBaseDir}/Mono_samplesheet.txt"

# for donor in A_ClassMCs_2_A2_1800_RH1 B_ClassMCs_1_B1_1814_RH1 B_ClassMCs_5_B5_1815_RH1 A_ClassMCs_1_A1_1816_RH1 C_ClassMCs_3_C3_1829_RH1 A_ClassMCs_5_A5_1831_RH1; do
#     echo ${donor} >> ${LogFile}
#     for fq in ${FastqDir}/*${donor}*/*.fastq.gz; do
#         echo ${fq} >> ${LogFile}
#         mkdir -p ${OutBaseDir}/${donor}
#         zcat ${fq} >> ${OutBaseDir}/${donor}/${donor}.fastq
#     done
#     pigz ${OutBaseDir}/${donor}/${donor}.fastq
#     echo >> ${LogFile}
# done

# for donor in 1800 1814 1815 1816 1829 1831; do 
#     echo -e "Mono_${donor}.phs001703v3p1.Homo_Sapiens.H3K27ac.b1\t$(ls ${OutBaseDir} | grep ${donor})\tN/A\tgrch38" >> ${Samplesheet}
# done

#====================
# get NCM samples of donors 1800, 1814, 1815, 1816, 1829, 1831
#====================

BaseDir="/mnt/BioAdHoc/Groups/vd-vijay/sourya/Projects/2019_HiChIP_CD4_Subtypes_Vivek/Data_Submission/ChIP"
FastqDir="${BaseDir}/NCM"

OutBaseDir="/mnt/BioAdHoc/Groups/vd-ay/kfetter/hichip-db-loop-calling/results/fastqs/chipseq_pieqtl/NCM"
mkdir -p $OutBaseDir

LogFile="${OutBaseDir}/Samples.txt"
Samplesheet="${OutBaseDir}/NCM_samplesheet.txt"

for donor in 1786 1800 1814 1815 1816 1831; do
    echo ${donor} >> ${LogFile}
    for fq in ${FastqDir}/*${donor}*/*.fastq.gz; do
        echo ${fq} >> ${LogFile}
        mkdir -p ${OutBaseDir}/${donor}
        zcat ${fq} >> ${OutBaseDir}/${donor}/${donor}.fastq
    done
    pigz ${OutBaseDir}/${donor}/${donor}.fastq
    echo >> ${LogFile}
done

for donor in 1786 1800 1814 1815 1816 1831; do 
    echo -e "NCM_${donor}.phs001703v4p1.Homo_Sapiens.H3K27ac.b1\t$(ls ${OutBaseDir} | grep ${donor})\tN/A\tgrch38" >> ${Samplesheet}
done