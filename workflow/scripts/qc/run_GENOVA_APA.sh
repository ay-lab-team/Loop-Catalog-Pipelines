#PBS -l nodes=1:ppn=1
#PBS -l mem=20gb
#PBS -l walltime=1:00:00
#PBS -e results/qc/logs/
#PBS -o results/qc/logs/
#PBS -N GENOVA_APA
#PBS -V

# run bash in strict mode
set -euo pipefail
IFS=$'\n\t'

cd $PBS_O_WORKDIR
source workflow/source_paths.sh

CODE=${PBS_O_WORKDIR}/workflow/scripts/qc/GENOVA_APA.R
Rscript="${HOME}/packages/mambaforge/envs/hichip-db/lib/R/bin/Rscript"

for rep in b1 b2 b3; do
	for norm in kr_unique vc_unique overlaps; do
		loops="results/loops/overlaps/hiccups_vc_kr/K562.GSE101498.Homo_Sapiens.H3K27ac.${rep}_5000_${norm}_sorted.bed"
		#hic_file="results/loops/hiccups_chr1/GM12878.GSE101498.Homo_Sapiens.H3K27ac.b1/hic_input/GM12878.GSE101498.Homo_Sapiens.H3K27ac.b1.allValidPairs.hic"
		sig_file="results/hicpro/K562.GSE101498.Homo_Sapiens.H3K27ac.${rep}/hic_results/matrix/K562.GSE101498.Homo_Sapiens.H3K27ac.${rep}/iced/5000/K562.GSE101498.Homo_Sapiens.H3K27ac.${rep}_5000_iced.matrix"
		indicies_file="results/hicpro/K562.GSE101498.Homo_Sapiens.H3K27ac.${rep}/hic_results/matrix/K562.GSE101498.Homo_Sapiens.H3K27ac.${rep}/raw/5000/K562.GSE101498.Homo_Sapiens.H3K27ac.${rep}_5000_abs.bed"
		res="5000"
		min="0"
		max="50"
		out="results/qc/genova/K562.GSE101498.Homo_Sapiens.H3K27ac.${rep}/"
		outfile="results/qc/genova/K562.GSE101498.Homo_Sapiens.H3K27ac.${rep}/K562.GSE101498.Homo_Sapiens.H3K27ac.${rep}_5000_${norm}.pdf"

		mkdir -p $out
		touch $outfile

		## FitHiC
		$Rscript $CODE --loops $loops --signal_file $sig_file --indicies_file $indicies_file --chr_name 1 --resolution $res --min_lim $min	--outfile $outfile
	
	done

done
