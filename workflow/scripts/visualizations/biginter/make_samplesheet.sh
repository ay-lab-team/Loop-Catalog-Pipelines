fn="workflow/scripts/visualizations/biginter/samplesheet.txt"

# loops from ChIP-seq
ls results/shortcuts/hg38/loops/hichip/chip-seq/macs2/*/*.*.interactions_FitHiC_Q0.01.bed > $fn

# loops from hichip
ls results/shortcuts/hg38/loops/hichip/hichip/fithichip-utility/*/*.*.interactions_FitHiC_Q0.01.bed > $fn