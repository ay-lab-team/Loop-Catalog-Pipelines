import sys
import pandas as pd

df = pd.read_csv(sys.argv[2], sep="\t", header=1)
df2 = df[(df["GSE ID"]==sys.argv[1])]
for srr in df2["SRR ID"]:
    print(srr)