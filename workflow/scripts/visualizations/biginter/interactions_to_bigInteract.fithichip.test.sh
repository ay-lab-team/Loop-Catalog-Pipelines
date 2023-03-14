set -euo pipefail
IFS=$'\n\t'

# defining a list of chromsize files
hg38_chromsize="/mnt/BioAdHoc/Groups/vd-ay/Database_HiChIP_eQTL_GWAS/Data/RefGenome/chrsize/hg38.chrom.sizes"
mm10_chromsize="/mnt/BioAdHoc/Groups/vd-ay/Database_HiChIP_eQTL_GWAS/Data/RefGenome/chrsize/mm10.chrom.sizes"
t2t_chromsize="/mnt/bioadhoc-temp/Groups/vd-ay/kfetter/hichip-db-loop-calling/ref_genome/chm13_refgenome/chrsize/chm13.chrom.sizes"

# defining a list of input variables
input="results/shortcuts/hg38/loops/hichip/chip-seq/macs2/loose/Monocyte_1829-RH-1.phs001703v3p1.Homo_Sapiens.H3K27ac.b1.5000.interactions_FitHiC_Q0.01.bed"
output="results/shortcuts/hg38/loops/hichip/chip-seq/macs2/loose/Monocyte_1829-RH-1.phs001703v3p1.Homo_Sapiens.H3K27ac.b1.5000.interactions_FitHiC_Q0.01.interaction.bb"
chromsize=$hg38_chromsize
autosql="results/refs/ucsc/interact.autoSql.txt"
type="fithichip"

echo "input: $input"
echo "output: $output"
echo "chromsize: $chromsize"
echo "autosql: $autosql"
echo "type: $type"

# running the interact_to_bigbed.py script
echo 'running the interact_to_bigbed.py script'
cmd="/mnt/bioadhoc-temp/Groups/vd-ay/rignacio/Scripts/Library/miniconda3/miniconda3/bin/python3.10 \
  workflow/scripts/visualizations/biginter/interactions_to_bigInteract.py \
    --input-file $input \
		--output-file $output \
    --chromsize $chromsize \
    --autosql $autosql \
    --type $type"
echo "Running: $cmd"
eval $cmd