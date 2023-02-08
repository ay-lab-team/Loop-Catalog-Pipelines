import os
import sys
import glob
import numpy as np
import pandas as pd

os.chdir('/mnt/bioadhoc-temp/Groups/vd-ay/kfetter/hichip-db-loop-calling')

sample = "GM12878.GSE101498.Homo_Sapiens.H3K27ac.b1"

base = "results/motif_analysis/meme/fimo/{s}/".format(s = sample)
fasta = base + "input_fasta.fa"
fimo = base + "fimo_out_jaspar/fimo.tsv"
loops = "results/motif_analysis/meme/fimo/{s}/anchors.txt".format(s = sample)

fimo_motifs_full = []
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