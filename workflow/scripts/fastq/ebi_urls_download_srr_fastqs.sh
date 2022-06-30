#PBS -l nodes=1:ppn=4
#PBS -l mem=80gb
#PBS -l walltime=10:00:00
#PBS -e results/fastqs/raw/logs/
#PBS -o results/fastqs/raw/logs/
#PBS -N ebi_urls_download_srr_fastqs
#PBS -V

#########################################################################################

# This script uses a list of EBI download links generated from the SRA Explorer
# (https://sra-explorer.info/) to download fastq files. See below for usage and
# important notes. 

### USAGE
# 1) go to the SRA Explorer (https://sra-explorer.info/)
# 2) search for the SRRs you want to download, select them, add to your collection
# 3) once all desired samples are added to your collection, click the "x saved datasets"
#    button in the upper right corner
# 4) download the Raw FastQ Download URLs file
# 5) move this file to results/samplesheets/fastq/ and softlink to the "current-ebi-download-urls.txt" file
#    (you may have to create this file if this is your first time using this script):
#    ln -s -r -f <downloaded url list current-ebi-download-urls.txt
# 6) qsub -t <indicies from fastq samplesheet>%4 workflow/scripts/fastqs/ebi_urls_download_srr_fastqs.sh

### NOTE
# make sure that you have softed linked the current list of EBI download links from
# SRA Explorer to current-ebi-download-urls.txt

########################################################################################

# # run bash in strict mode
set -euo pipefail
IFS=$'\n\t'

# print start time message
start_time=$(date "+%Y.%m.%d.%H.%M")
echo "Start time: $start_time"

# print start message
echo "Started: ebi_urls_download_srr_fastqs"

# run bash in strict mode
set -euo pipefail
IFS=$'\n\t'

# make sure to work starting from the base directory for this project 
cd $PBS_O_WORKDIR

# source tool paths
source workflow/source_paths.sh

# extract the sample information using the PBS ARRAYID
IFS=$'\t'
samplesheet="results/samplesheets/fastq/Current-HiChIP-SRR-Samplesheet-Without-Header.tsv"
sample_info=( $(cat $samplesheet | sed -n "${PBS_ARRAYID}p") )
sample_name="${sample_info[0]}"
srr_id="${sample_info[3]}"

# extract the two download links for current SRR
unset IFS
ebi_urls="results/samplesheets/fastq/current-ebi-download-urls.txt"
download_link_1=$(grep "${srr_id}_1" ${ebi_urls})
download_link_2=$(grep "${srr_id}_2" ${ebi_urls})
# remove extra "\r" that would make url invalid
download_link_1=${download_link_1%$'\r'}
download_link_2=${download_link_2%$'\r'}

# printing sample information
echo
echo "Processing"
echo "----------"
echo "sample_name: $sample_name"
echo "srr_id: $srr_id"
echo "download link R1: $download_link_1"
echo "download link R2: $download_link_2"
echo

# make the output directory 
outdir="results/fastqs/raw/$sample_name/"
mkdir -p $outdir

# run curl command
echo "# running curl command to download R1 fastq file"
curl -L $download_link_1 -o "${outdir}/${srr_id}_1.fastq.gz"
echo "# running curl command to download R2 fastq file"
curl -L $download_link_2 -o "${outdir}/${srr_id}_2.fastq.gz"

# print end message
echo
echo "Ended: ebi_urls_download_srr_fastqs"

# print end time message
end_time=$(date "+%Y.%m.%d.%H.%M")
echo "End time: $end_time"