for sample in lee2021-gse179545-rna_pol_ii-hct116-auxin-dpnii-rep1 lee2021-gse179545-rna_pol_ii-hct116-auxin-dpnii-rep2 lee2021-gse179545-rna_pol_ii-hct116-wt-dpnii-rep1 lee2021-gse179545-rna_pol_ii-hct116-wt-dpnii-rep2
do
    scriptfile=`pwd`'/split_fastqs_'${sample}'.sh'

echo '' > ${scriptfile}
cat <<EOT >> ${scriptfile}
#!/bin/bash -ex
#PBS -l nodes=1:ppn=1
#PBS -l mem=20GB
#PBS -l walltime=50:00:00
#PBS -M kfetter@lji.org
#PBS -m ae
#PBS -j eo
#PBS -V
source ~/.bashrc
hostname
TMPDIR=/scratch
cd $PBS_O_WORKDIR

export PATH=/home/kfetter/miniconda3/bin:$PATH
source activate HiC-Pro_v3.1.0

fastqfolder="results/fastqs/raw/${sample}/"
outdir="results/fastqs/parallel/${sample}/"

for fq in \$fastqfolder*'.fastq.gz';
    do
        python /home/kfetter/packages/hicpro/compiled_code/HiC-Pro_3.1.0/bin/utils/split_reads.py --results_folder \$outdir --nreads 50000000 \$fq
    done
EOT

	chmod +x ${scriptfile}
	qsub ${scriptfile}

done
