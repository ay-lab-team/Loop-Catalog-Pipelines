#PBS -l mem=1gb
#PBS -l nodes=1:ppn=1
#PBS -l walltime=00:50:00
#PBS -o outtest.txt 
#PBS -e outerr.txt
#PBS -N combined_fithichip_hiccups_mustache
# -t 1
# -d .

# to run the code from bash use:
# bash combined_fithichip_hiccups_mustache.qarray.qsh 3

# to run the code from Qsub use:
# qsub combined_fithichip_hiccups_mustache.qarray.qsh -t 3

# allow this script to be run without qsub by assigning PBS_ARRAYID from
# # the command line using $1
if [ -z "${PBS_ARRAYID+x}" ]
then
  PBS_ARRAYID=$1
  PBS_O_WORKDIR="."
fi

#PBS_ARRAYID=1
#echo $PBS_ARRAYID=1
#fn=$(sed -n ${PBS_ARRAYID}p /mnt/BioHome/rignacio/rignacio/Scripts/samplesheet.txt)

ref=$(echo $fn | cut -d "/" -f 7)
#echo -in $file

#for v in PBS_ARRAYID; do
echo "Hi! $ref"
#echo "${#PBS_ARRAYID[@]}"



#ref=$(echo $fn | cut -d "/" -f 6)
#echo "$ref"






#/mnt/bioadhoc-temp/Groups/vd-ay/rignacio/Scripts/Library/miniconda3/miniconda3/bin/python3.10 \
#	workflow/scripts/visualizations/combined_fithichip_hiccups_mustache.py \
#		--infile results/shortcuts/hg38/loops/hichip/chip-seq/macs2/loose/293T.GSE128106.Homo_Sapiens.YY1.b1.10000.interactions_FitHiC_Q0.01.bed
#		--outfile test.out
