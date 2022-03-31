for sample in lee2021-gse179545-rna_pol_ii-hct116-wt-dpnii-rep1 lee2021-gse179545-rna_pol_ii-hct116-wt-dpnii-rep2 lee2021-gse179545-rna_pol_ii-hct116-auxin-dpnii-rep1 lee2021-gse179545-rna_pol_ii-hct116-auxin-dpnii-rep2
do
    awk -F["\t"] '{if (NR>0) {print $1"\t"$2"\t"$3"\t"($3-$2)}}' ${sample}/MACS2_ExtSize/out_macs2_peaks.narrowPeak > out_peak_sizes_${sample}.txt 
done