# Usage: We recommend running this on one sample at a time.
# ./workflow/scripts/split_fastqs <sample folder name 1> <sample folder name 2> <...>

for sample in $@
do
    scriptfile=`pwd`'/split_fastqs_'${sample}'.sh'

echo '' > ${scriptfile}
cat <<EOT >> ${scriptfile}
#!/bin/bash -ex
#PBS -l nodes=1:ppn=1
#PBS -l mem=20GB
#PBS -l walltime=50:00:00
#PBS -m ae
#PBS -j eo
#PBS -V
source ~/.bashrc
hostname
TMPDIR=/scratch
cd \$PBS_O_WORKDIR

fastqfolder="results/fastqs/raw/${sample}/"
outdir="results/fastqs/parallel/${sample}/"

for fq in \$fastqfolder*'.fastq.gz';
    do
        /mnt/BioAdHoc/Groups/vd-ay/jreyna/software/mambaforge/envs/HiC-Pro_v3.1.0/bin/python /mnt/BioAdHoc/Groups/vd-ay/jreyna/software/hicpro/compiled_code/HiC-Pro_3.1.0/bin/utils/split_reads.py --results_folder \$outdir --nreads 50000000 \$fq
    done
EOT

	chmod +x ${scriptfile}
	qsub ${scriptfile}

done
