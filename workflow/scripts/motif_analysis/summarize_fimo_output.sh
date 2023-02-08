#PBS -l nodes=1:ppn=1
#PBS -l mem=10gb
#PBS -l walltime=5:00:00
#PBS -e results/motif_analysis/logs/
#PBS -o results/motif_analysis/logs/
#PBS -N summarize_fimo_output
#PBS -V

# run bash in strict mode
set -euo pipefail
IFS=$'\n\t'

# make sure to work starting from the github base directory for this script 
cd $PBS_O_WORKDIR

# source tool paths
source workflow/source_paths.sh

# extract the sample information using the PBS ARRAYID
samplesheet="results/samplesheets/hicpro/current.mouse.hicpro.samplesheet.without_header.tsv"
sample_info=( $(cat $samplesheet | sed -n "${PBS_ARRAYID}p") )
sample_name="${sample_info[0]}"
org="${sample_info[2]}"
protein="${sample_info[4]}"

base="results/motif_analysis/meme/fimo/${sample_name}"
fasta="${base}/input_fasta.fa"
fimo="${base}/fimo_out_jaspar/fimo.tsv"
loops="results/motif_analysis/meme/fimo/${sample_name}/anchors.txt"

outdir="${base}/summarize_results"
out="${outdir}/summary.txt"

mkdir -p $outdir

# compile all motifs into motifs.txt with coordiates at the beginning of each line
awk -F["\t"] '{if (/^MA/) {print $3"\t"$4"\t"$5"\t"$1"\t"$2"\t"$6"\t"$7"\t"$8"\t"$9"\t"$10}}' $fimo | sort -k1,1 -k2,2n > $outdir/motifs.txt

# compile all chipseq peaks used as input into peaks.txt
awk -F'[>: -]' '{if (/^>/) {print $2"\t"$3"\t"$4"\t"$5}}' $fasta > $outdir/peaks.txt

# intersect motif coords with peaks to associate each peak with its overlapping motifs 
bedtools intersect -a "$outdir/peaks.txt" -b "$outdir/motifs.txt" -wa -wb | uniq > "$outdir/peaks_overlap_motifs.txt"





with open(fimo) as fi, open(fasta) as fa, open(loops) as lp:
    for line in fi:
        info = []
        
        if "chr" in line:
            parse = line.strip().split("\t")
            mstart = int(parse[3])
            mend = int(parse[4])
            info.append(parse[0])
            info.append(parse[1])
            info.append(parse[2])
            info.append(mstart)
            info.append(mend)
            info.append(parse[5])
            info.append(float(parse[6]))
            info.append(float(parse[7]))
            info.append(float(parse[8]))
            info.append(parse[9])
            
            for line in fa:
                if ">" in line:
                    coords = line[1:-1].strip().split(' ')[0]
                    astart = int(coords.split(":")[1].split("-")[0])
                    aend = int(coords.split(":")[1].split("-")[1])
            
                    if mstart >= astart and mend <= aend:
                        loop = line[1:-1].strip().split(' ')[1]
                        info.append(coords.split(":")[0])
                        info.append(astart)
                        info.append(aend)
                        info.append(loop)
                        anchors.append(info)
                        for line in lp:
                            if loop in line:
                                parse = line.strip().split("\t")
                                info.append(int(parse[1]))
                                info.append(int(parse[2]))
                                break
                            lp.seek(0)
                        break
                fa.seek(0)
            
            fimo_motifs_full.append(info)

motifs_df_full = pd.DataFrame(fimo_motifs_full)
motifs_df_full.to_csv(base + "summary_output.txt", sep="\t")