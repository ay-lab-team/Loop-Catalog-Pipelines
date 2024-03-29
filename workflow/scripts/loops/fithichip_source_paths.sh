fithichip_python="/mnt/BioAdHoc/Groups/vd-ay/kfetter/packages/mambaforge/envs/hichip-db/bin/python"
#fithichip_sitepack="/mnt/BioAdHoc/Groups/vd-ay/kfetter/packages/mambaforge/envs/hichip-db/lib/python3.9/site-packages/"
fithichip_r="/mnt/BioAdHoc/Groups/vd-ay/kfetter/packages/mambaforge/envs/hichip-db/bin/R"
#fithichip_r_library="/mnt/BioAdHoc/Groups/vd-ay/kfetter/packages/mambaforge/envs/hichip-db/lib/R/library/"
fithichip_call_loops="/mnt/BioAdHoc/Groups/vd-ay/kfetter/packages/fithichip/FitHiChIP/FitHiChIP_HiCPro.sh"
fithichip_analysis="/mnt/BioAdHoc/Groups/vd-ay/kfetter/packages/fithichip/FitHiChIP/Analysis/"
fithichip_src="/mnt/BioAdHoc/Groups/vd-ay/kfetter/packages/fithichip/FitHiChIP/src/"
samtools="/mnt/BioAdHoc/Groups/vd-ay/Database_HiChIP_eQTL_GWAS/Packages/samtools/samtools-1.14/samtools"
#htslib="/mnt/BioAdHoc/Groups/vd-ay/Database_HiChIP_eQTL_GWAS/Packages/htslib/htslib-1.14"
htslib_bin="/mnt/BioAdHoc/Groups/vd-ay/Database_HiChIP_eQTL_GWAS/Packages/htslib/htslib-1.14/bin"
#bcftools="/mnt/BioAdHoc/Groups/vd-ay/Database_HiChIP_eQTL_GWAS/Packages/bcftools/bcftools-1.14"
bcftools_bin="/mnt/BioAdHoc/Groups/vd-ay/Database_HiChIP_eQTL_GWAS/Packages/bcftools/bcftools-1.14/bin"
bowtie2="/mnt/BioAdHoc/Groups/vd-ay/Database_HiChIP_eQTL_GWAS/Packages/bowtie2/bowtie2-2.4.5-linux-x86_64"
bowtie2_scripts="/mnt/BioAdHoc/Groups/vd-ay/Database_HiChIP_eQTL_GWAS/Packages/bowtie2/bowtie2-2.4.5-linux-x86_64/scripts"

PATH=/mnt/BioAdHoc/Groups/vd-ay/jreyna/software/hicpro/compiled_code/HiC-Pro_3.1.0/bin:$PATH
add_paths="$(dirname $fithichip_python):$(dirname $fithichip_r):$(dirname $fithichip_call_loops):"
add_paths+="$fithichip_analysis:$fithichip_src:$(dirname $samtools):$htslib_bin:$bcftools_bin:$(dirname $bowtie2)"
PATH="$add_paths:$PATH"