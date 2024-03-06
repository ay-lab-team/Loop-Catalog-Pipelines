import os
import sys
import glob
import pandas as pd

os.chdir('results/comm_detect/louvain/All_Samples/')

sample = sys.argv[1]

sub_crank_list = glob.glob(sample + "/S5/*/*/crank_scores.txt")

if len(sub_crank_list) != 0:

    valid_chroms = set([sub_crank.strip().split("/")[2] for sub_crank in sub_crank_list])

    # annotate all sub_crank files across all chromosomes with respective parent communities
    # save annotate file to appropriate comm folder as crank_scores.annotated.txt
    for sub_crank in sub_crank_list:
        chrom = sub_crank.strip().split("/")[2]
        comm = sub_crank.strip().split("/")[3]
        df = pd.read_csv(sub_crank, sep = "\t")
        df["Parent_Community"] = "Cmt" + comm[4:]
        df.to_csv(sample + "/S5/" + chrom + "/" + comm + "/crank_scores.annotated.txt", sep = "\t", header = True, index = False)

    # concatenate sub_crank files into one file and save as crank_scores.subcommunity.txt
    # merge subcommunity and community crank files and save as crank_scores.merged.txt
    for chrom in valid_chroms:
        
        # concatenate
        df = pd.DataFrame()
        sub_crank_files = glob.glob(sample + "/S5/" + chrom + "/*/crank_scores.annotated.txt")
        for file in sub_crank_files:
            f = pd.read_csv(file, sep = "\t")
            df = pd.concat([df, f])
        df = df.sort_values(by = "Parent_Community")
        df.to_csv(sample + "/S5/" + chrom + "/" + "crank_scores.subcommunity.txt", sep = "\t", header = True, index = False)

        # merge
        parent = pd.read_csv(sample + "/S5/" + chrom + "/" + "crank_scores.txt", sep = "\t")
        child = pd.read_csv(sample + "/S5/" + chrom + "/" + "crank_scores.subcommunity.txt", sep = "\t")
        df = parent.merge(child, left_on = "Community", right_on = "Parent_Community")
        df.insert(loc = 0, column = "Chromosome", value = chrom)
        df.columns = ["Chromosome", "Community", "CRank", "Conductance", "Modularity", "Random", "SubCommunity", "CRank_SubCmt", "Conductance_SubCmt", "Modularity_SubCmt", "Random_SubCmt", "Parent_Community"]
        df = df.drop(columns = "Parent_Community")
        df.to_csv(sample + "/S5/" + chrom + "/" + "crank_scores.merged.txt", sep = "\t", header = True, index = False)

    # concatenate across chromosomes and save as crank_scores.final.txt
    df = pd.DataFrame()
    merged_files = glob.glob(sample + "/S5/*/crank_scores.merged.txt")
    for file in merged_files:
        f = pd.read_csv(file, sep = "\t")
        df = pd.concat([df, f])
    df = df.sort_values(by = "Chromosome")
    df.to_csv(sample + "/S5/crank_scores.final.txt", sep = "\t", header = True, index = False)
