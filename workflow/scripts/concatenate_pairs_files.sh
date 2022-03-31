for sample in lee2021-gse179545-rna_pol_ii-hct116-auxin-dpnii-rep2 lee2021-gse179545-rna_pol_ii-hct116-wt-dpnii-rep1 lee2021-gse179545-rna_pol_ii-hct116-wt-dpnii-rep2 #lee2021-gse179545-rna_pol_ii-hct116-auxin-dpnii-rep1
do
    scriptfile=`pwd`'/concatenate_'${sample}'.sh'

echo '' > ${scriptfile}
cat <<EOT >> ${scriptfile}
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

basedir='/mnt/BioAdHoc/Groups/vd-ay/kfetter/2022_hichip_database/hicpro/lee_et_al_2021/HiCPro_Results/hic_results/data/${sample}/'
outdir='/mnt/BioAdHoc/Groups/vd-ay/kfetter/2022_hichip_database/hicpro/lee_et_al_2021/concatenated_pairs/${sample}/'

cat \$basedir*'.DEPairs' > \$outdir'all_${sample}.bwt2pairs.DEPairs'
cat \$basedir*'.SCPairs' > \$outdir'all_${sample}.bwt2pairs.SCPairs'
cat \$basedir*'.REPairs' > \$outdir'all_${sample}.bwt2pairs.REPairs'
cat \$basedir*'.validPairs' > \$outdir'all_${sample}.bwt2pairs.validPairs'
cat \$basedir*'.allValidPairs' > \$outdir'${sample}.allValidPairs'
EOT

	chmod +x ${scriptfile}
	qsub ${scriptfile}

done