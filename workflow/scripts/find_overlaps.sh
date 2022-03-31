#!/bin/bash -ex
#PBS -l nodes=1:ppn=1
#PBS -l mem=20GB
#PBS -l walltime=01:00:00
#PBS -M kfetter@lji.org
#PBS -m ae
#PBS -j eo
#PBS -V
source ~/.bashrc
hostname
TMPDIR=/scratch
cd $PBS_O_WORKDIR

HiCProBaseDir='/mnt/BioAdHoc/Groups/vd-ay/kfetter/2022_hichip_database/hicpro/lee_et_al_2021/concatenated_pairs/'
HiCProDir='/mnt/BioAdHoc/Groups/vd-ay/kfetter/2022_hichip_database/hicpro/lee_et_al_2021/concatenated_pairs/${sample}/'
PeaksFile='/mnt/BioAdHoc/Groups/vd-ay/kfetter/2022_hichip_database/fithichip/peak_calling/lee_et_al_2021/${sample}/MACS2_ExtSize/out_macs2_peaks.narrowPeak'
ReadLength=101

awk -F['\t'] '{print \$1"\t"\$2"\t"\$3}' \$PeaksFile > \$HiCProBaseDir'mac2_peaks_${sample}.bed'

sort -k1,1 -k2,2n \$HiCProBaseDir'mac2_peaks_${sample}.bed' > \$HiCProBaseDir'mac2_peaks_sorted_${sample}.bed'

awk -v len=\$ReadLength -F['\t'] 'function abs(v) {return v < 0 ? -v : v} {if ((\$2==\$5) && (abs(\$6-\$3)<1000)) {if (\$4=="+" && \$7=="+") {print \$2"\t"\$3"\t"\$3+len"\t"\$5"\t"\$6"\t"\$6+len}
          else if (\$4=="+" && \$7=="-") {print \$2"\t"\$3"\t"\$3+len"\t"\$5"\t"\$6-len"\t"\$6}
          else if (\$4=="-" && \$7=="+") {print \$2"\t"\$3-len"\t"\$3"\t"\$5"\t"\$6"\t"\$6+len}
          else if (\$4=="-" && \$7=="-") {print \$2"\t"\$3-len"\t"\$3"\t"\$5"\t"\$6-len"\t"\$6}
}}' \$HiCProDir'all_${sample}.bwt2pairs.validPairs' > \$HiCProBaseDir'expanded_validpairs_${sample}.bedpe'

cat \$HiCProDir*'all_${sample}.bwt2pairs.DEPairs' \$HiCProDir'all_${sample}.bwt2pairs.REPairs' \$HiCProDir'all_${sample}.bwt2pairs.SCPairs' > \$HiCProBaseDir'DE_RE_SC_pairs_${sample}.txt'

awk -v len=\$ReadLength -F['\t'] '{if (\$4=="+" && \$7=="+") {print \$2"\t"\$3"\t"\$3+len"\t"\$5"\t"\$6"\t"\$6+len}
          else if (\$4=="+" && \$7=="-") {print \$2"\t"\$3"\t"\$3+len"\t"\$5"\t"\$6-len"\t"\$6}
          else if (\$4=="-" && \$7=="+") {print \$2"\t"\$3-len"\t"\$3"\t"\$5"\t"\$6"\t"\$6+len}
          else if (\$4=="-" && \$7=="-") {print \$2"\t"\$3-len"\t"\$3"\t"\$5"\t"\$6-len"\t"\$6}
}' \$HiCProBaseDir'DE_RE_SC_pairs_${sample}.txt' > \$HiCProBaseDir'expanded_DE_RE_SC_pairs_${sample}.bedpe'

cat \$HiCProBaseDir'expanded_DE_RE_SC_pairs_${sample}.bedpe' \$HiCProBaseDir'expanded_validpairs_${sample}.bedpe' > \$HiCProBaseDir'expanded_all_pairs_${sample}.bedpe'

uniq \$HiCProBaseDir'expanded_all_pairs_${sample}.bedpe' > \$HiCProBaseDir'expanded_all_pairs_rmdup_${sample}.bedpe'

sort -k1,1 -k2,2n \$HiCProBaseDir'expanded_all_pairs_rmdup_${sample}.bedpe' > \$HiCProBaseDir'expanded_all_pairs_rmdup_sorted_${sample}.bedpe'

bedtools pairtobed -a \$HiCProBaseDir'expanded_all_pairs_rmdup_sorted_${sample}.bedpe' -b \$HiCProBaseDir'mac2_peaks_sorted_${sample}.bed' > \$HiCProBaseDir'overlaps_${sample}.txt'

uniq \$HiCProBaseDir'overlaps_${sample}.txt' > \$HiCProBaseDir'overlaps_rmdup_${sample}.txt'

NumTotalReads=\$(wc -l \$HiCProBaseDir'expanded_all_pairs_rmdup_sorted_${sample}.bedpe')
NumOverlappingReads=\$(wc -l \$HiCProBaseDir'overlaps_rmdup_${sample}.txt')

echo "Number of reads used in FitHiChIP peak calling: "
echo \$NumTotalReads
echo "Number of overlapping reads: "
echo \$NumOverlappingReads
echo "Percentage of overlapping reads: "
echo \$PercentageOverlappingReads

rm \$HiCProBaseDir'mac2_peaks_${sample}.bed'
rm \$HiCProBaseDir'mac2_peaks_sorted_${sample}.bed'
rm \$HiCProBaseDir'expanded_validpairs_${sample}.bedpe'
rm \$HiCProBaseDir'DE_RE_SC_pairs_${sample}.txt'
rm \$HiCProBaseDir'expanded_DE_RE_SC_pairs_${sample}.bedpe'
rm \$HiCProBaseDir'expanded_all_pairs_${sample}.bedpe'
rm \$HiCProBaseDir'expanded_all_pairs_rmdup_${sample}.bedpe'
rm \$HiCProBaseDir'expanded_all_pairs_rmdup_sorted_${sample}.bedpe'
rm \$HiCProBaseDir'overlaps_${sample}.txt'