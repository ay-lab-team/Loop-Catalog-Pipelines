#!/bin/sh
#SBATCH --job-name=chipseq_qc
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=10g
#SBATCH --time=25:00:00
#SBATCH --output=results/qc/chipseq_qc/logs/job-%j.out
#SBATCH --error=results/qc/chipseq_qc/logs/job-%j.error

# run bash in strict mode
set -euo pipefail
IFS=$'\n\t'

# print start time message
start_time=$(date "+%Y.%m.%d.%H.%M")
echo "Start time: $start_time"

# print start message
echo "Started: chipseq_qc"

# run bash in strict mode
set -euo pipefail
IFS=$'\n\t'

# make sure to work starting from the base directory for this project 
cd $SLURM_SUBMIT_DIR

# source tool paths
source workflow/source_paths.sh

# extract the sample information using the PBS ARRAYID
IFS=$'\t'
samplesheet="results/samplesheets/post-hicpro/chipseq_samples_08_02_2024.tsv"
sample_info=( $(cat $samplesheet | sed -n "${SLURM_ARRAY_TASK_ID}p") )
sample_name="${sample_info[0]}"
paired="${sample_info[1]}"
tag="${sample_info[2]}"

# printing sample information
echo
echo "Processing"
echo "----------"
echo "sample_name: $sample_name"
echo

# output file 
outdir="results/qc/chipseq_qc/$sample_name"
mkdir -p $outdir
outfile="${outdir}/out_stats_09.16.24_new.txt"

# required files for calculations
if [ "$tag" = "No Tag" ]; then
		peaks="results/peaks/chipline_v2/${sample_name}/MACS2_Ext_No_Control/${sample_name}.macs2_peaks.narrowPeak_Q0.01filt"
elif [ "$tag" = "Tag" ]; then
		peaks="results/peaks/chipline_v2/${sample_name}/MACS2_Ext_Tag_No_Control/${sample_name}.macs2_peaks.narrowPeak_Q0.01filt"
fi
bam="results/peaks/chipline_v2/${sample_name}/Alignment_MAPQ30/${sample_name}.align.sort.MAPQ30.rmdup.bam"
uniq_mapped_read_bamfile="results/peaks/chipline_v2/${sample_name}/Alignment_MAPQ30/UniqMappedRead.bam"
temp_NRF_PBC_file="results/peaks/chipline_v2/${sample_name}/temp_NRF_PBC.bed"

echo "Files Selected:"
echo "Peaks: $peaks"
echo "BAM: $bam"
echo "Uniq Mapped Reads: $uniq_mapped_read_bamfile"
echo "NRF/PBC: $temp_NRF_PBC_file"
echo

# NRF (Non redundant fraction) value
# Number of distinct uniquely mapping reads (after removing duplicates) / total number of reads
# other definition is number of distinct genome position for uniquely mapped reads / number of uniquely mapped reads
# we follow this second definition (ENCODE PAPER)
echo "# NRF, M1-2, and PBC1-2 Computations"
if [ "$paired" = "single-end" ]; then
		echo "single-end read fastq file is provided as input, no modification needed for uniqgenomepos"
		uniqgenomepos=`cat $temp_NRF_PBC_file | wc -l`
elif [ "$paired" = "paired-end" ]; then
		echo "paired-end read fastq file is provided as input, divide uniqgenomepos by 2"
		uniqgenomepos=$(( $(cat $temp_NRF_PBC_file | wc -l) / 2 ))
fi

uniq_mapped_read=`samtools view $uniq_mapped_read_bamfile | cut -f 1 | sort | uniq | wc -l`
NRFval=`bc <<< "scale=3; ($uniqgenomepos * 1.0) / $uniq_mapped_read"`

# number of genomic locations where exactly one read maps uniquely
if [ "$paired" = "single-end" ]; then
	echo "single-end read fastq file is provided as input, no modification needed"
	M1=`awk '$4==1' $temp_NRF_PBC_file | wc -l`
else 
	echo "paired-end read fastq file is provided as input, divide M1 by 2"
	M1=$(( $(awk '$4==1' $temp_NRF_PBC_file | wc -l) / 2 ))
fi

# PCR Bottlenecking Coefficient 1 (PBC1) is computed by considering the 
# number of genomic locations where exactly one read maps uniquely
# dividing by the number of distinct genomic locations to which some read maps uniquely
PBC1=`bc <<< "scale=3; ($M1 * 1.0) / $uniqgenomepos"`

# number of genomic locations where exactly two reads map uniquely
if [ "$paired" = "single-end" ]; then
	echo "single-end read fastq file is provided as input, no modification needed"
	M2=`awk '$4==2' $temp_NRF_PBC_file | wc -l`
else 
	echo "paired-end read fastq file is provided as input, divide M2 by 2"
	M2=$(( $(awk '$4==2' $temp_NRF_PBC_file | wc -l) / 2 ))
fi

# PCR Bottlenecking Coefficient 2 (PBC2)
# ratio of the following quantities
if [[ $M2 -gt 0 ]]; then
    PBC2=`bc <<< "scale=3; ($M1 * 1.0) / $M2"`
else
    PBC2=0
fi

echo
echo "# Calculate FRiP"

# From ChIPLine - number of reads within MACS2 narrow peaks
macs2_nreads_narrowpeak=`samtools view -L $peaks $bam | cut -f1 | sort -k1,1 | uniq | wc -l`	## applicable for both SE and PE reads
FRiP_narrowpeak=`bc <<< "scale=3; ($macs2_nreads_narrowpeak * 1.0) / $uniq_mapped_read"`

echo
echo "# Grab NSC and RSC"

# get NSC and RSC
tab_file="results/peaks/chipline_v2/${sample_name}/chipSampleMaster.tagAlign.tab"
nsc=$( cut -f9 $tab_file )
rsc=$( cut -f10 $tab_file )

echo
echo "# Write results to outfile"

# write results to outfile
echo -e 'Unique_Mapped_Read: '$uniq_mapped_read >> $outfile
echo -e 'Unique_Genome_Pos: '$uniqgenomepos >> $outfile
echo -e 'NRF: '$NRFval >> $outfile
echo -e 'M1: '$M1 >> $outfile
echo -e 'M2: '$M2 >> $outfile
echo -e 'PBC1: '$PBC1 >> $outfile
echo -e 'PBC2: '$PBC2 >> $outfile
echo -e 'MappedReadNarrowpeak: '$macs2_nreads_narrowpeak >> $outfile
echo -e 'FRiPNarrowPeak: '$FRiP_narrowpeak >> $outfile
echo -e 'NSC: '$nsc >> $outfile
echo -e 'RSC: '$rsc >> $outfile

# print end message
echo
echo "Ended: chipseq_qc"

# print end time message
end_time=$(date "+%Y.%m.%d.%H.%M")
echo "End time: $end_time"