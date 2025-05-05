import os
import sys
import glob
import numpy as np
import pandas as pd
import hicstraw
import config
os.chdir(config.LOOP_CATALOG_DIR)

samples = list(pd.read_csv("results/samplesheets/hicpro/revisions.top_45.hicpro.samplesheet.all.without_header.tsv", sep = "\t", header = None)[0])
chroms = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "X", "Y"]
data = []

for sample in samples:
    print(sample)
    sample_data = []
    sample_data.append(sample)
    if "biorep_merged" in sample and "phs" not in sample:
        file = "results/biorep_merged/results/loops/hiccups/chr1/{s}/{s}.hic".format(s = sample)
    elif sample == "CD34+-Cord-Blood.GSE165207.Homo_Sapiens.H3K27ac.b1":
        file = "results/loops/hiccups/chr1_all_batches/CD34+-Cord-Blood.GSE165207.Homo_Sapiens.H3K27ac.b1/CD34-Cord-Blood.GSE165207.Homo_Sapiens.H3K27ac.b1.hic"
    else:
        file = "results/loops/hiccups/chr1_all_batches/{s}/{s}.hic".format(s = sample)
    hic = hicstraw.HiCFile(file)
    for norm in ["KR", "VC", "VC_SQRT", "SCALE"]:
        for res in [5000, 10000, 25000]:
            no_converge = []
            for i in range(1, 25):
                norm_vector = hic.getMatrixZoomData(chroms[i-1], chroms[i-1], "observed", norm, "BP", res).getNormVector(i+1)
                if np.isnan(norm_vector).all():
                    no_converge.append(chroms[i-1])
            sample_data.append(no_converge)
    data.append(sample_data)

df = pd.DataFrame(data)
df.columns = ["sample_name", "KR_5kb", "KR_10kb", "KR_25kb", "VC_5kb", "VC_10kb", "VC_25kb", "VC_SQRT_5kb", "VC_SQRT_10kb", "VC_SQRT_25kb", "SCALE_5kb", "SCALE_10kb", "SCALE_25kb"]
df.to_excel("results/revisions/tables/hiccups_non_convergence.xlsx", index = False)