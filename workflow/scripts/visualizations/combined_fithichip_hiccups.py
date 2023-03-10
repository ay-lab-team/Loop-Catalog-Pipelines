import argparse
import pandas as pd
import math
import os
from subprocess import call

parser = argparse.ArgumentParser()
parser.add_argument('--inputfile', type=str, required=True)
parser.add_argument('--chromsize',type=str, required=True)
parser.add_argument('--autosql',type=str,required=True)
parser.add_argument('--outfile',type=str, required=True)
parser.add_argument('--type',type=int,required=True,default=0)
args = parser.parse_args()

#0 is HicCUPS file
#1 is FitHiCHIP file
argstype = 0
inputfile = args.inputfile
inputfilename = os.path.basename(inputfile)
inputfilename = inputfilename.rsplit('.', maxsplit=1)[0]
inputfiledir = os.path.dirname(inputfile)
outputfilename = "Clean_"+inputfilename

if args.type == 0:
    bed = pd.read_csv(inputfile, delimiter='\t')
    bed = bed[bed['x1'].notnull()]
    bed['chr1'] = bed['#chr1']
    for item in ['chr1','chr2','x1','x2','y1','y2']:
        #Convert
        try:
            bed[item] = bed[item].astype(int)
        except:
            continue
    #Get beginning of chromsome (Same Chromosome)
    bed['schr'] = bed[bed['chr1']==bed['chr2']][['x1','y1']].min(axis=1)
    #Get end of chromosome (Same Chromosome)
    bed['echr'] = bed[bed['chr1']==bed['chr2']][['x2','y2']].max(axis=1)

    #Get beginning of chromsome (Different Chromsome)
    bed.loc[bed['chr1']!=bed['chr2'],'schr'] = bed[['x1']].max(axis=1)
    #Get end of chromosome (Different Chromsome)
    bed.loc[bed['chr1']!=bed['chr2'],'echr'] = bed[['x2']].max(axis=1)

    begin = bed['x1'].min()
    end = bed['y2'].max()

    entries = []
    for row in bed.to_dict('records'):
        entry = {}
        if row['chr1'][0:3] == "chr":
            entry['#chrom'] = str(row['chr1'])
        else:
            entry['#chrom'] = 'chr'+str(row['chr1'])
        entry['chromStart'] = int(row['schr'])
        entry['chromEnd'] = str(row['echr'])
        entry['name'] = "."
        entry['score'] = str(int(round(-math.log(row['fdrDonut'],10),0)))
        entry['value'] = str(0)
        entry['exp'] = "."
        entry['color'] = str(0)
        if row['chr1'][0:3] == "chr":
            entry['sourceChrom'] = str(row['chr1'])
        else:
            entry['sourceChrom'] = 'chr'+str(row['chr1'])
        entry['sourceStart'] = str(row['x1'])
        entry['sourceEnd'] = str(row['x2'])
        entry['sourceName'] = "."
        entry['sourceStrand'] = "."
        if row['chr2'][0:3] == "chr":
            entry['targetChrom'] = str(row['chr2'])
        else:
            entry['targetChrom'] = 'chr'+str(row['chr2'])
        entry['targetStart'] = str(row['y1'])
        entry['targetEnd'] = str(row['y2'])
        entry['targetName'] = "."
        entry['targetStrand'] = "."
        entries.append(entry)
    
if args.type == 1:
    bed = pd.read_csv(inputfile, delimiter='\t')

    #Get beginning of chromsome (Same Chromosome)
    bed['schr'] = bed[bed['chr1']==bed['chr2']][['s1','s2']].min(axis=1)
    #Get end of chromosome (Same Chromosome)
    bed['echr'] = bed[bed['chr1']==bed['chr2']][['e1','e2']].max(axis=1)

    #Get beginning of chromsome (Different Chromsome)
    bed.loc[bed['chr1']!=bed['chr2'],'schr'] = bed[['s1']].max(axis=1)
    #Get end of chromosome (Different Chromsome)
    bed.loc[bed['chr1']!=bed['chr2'],'echr'] = bed[['e1']].max(axis=1)

    begin = bed['s1'].min()
    end = bed['e2'].max()

    entries = []
    for row in bed.to_dict('records'):
        entry = {}
        entry['#chrom'] = str(row['chr1'])
        entry['chromStart'] = int(row['schr'])
        entry['chromEnd'] = str(row['echr'])
        entry['name'] = "."
        entry['score'] = str(int(round(-math.log(row['Q-Value_Bias'],10),0)))
        entry['value'] = str(0)
        entry['exp'] = "."
        entry['color'] = str(0)
        entry['sourceChrom'] = str(row['chr1'])
        entry['sourceStart'] = str(row['s1'])
        entry['sourceEnd'] = str(row['e1'])
        entry['sourceName'] = "."
        entry['sourceStrand'] = "."
        entry['targetChrom'] = str(row['chr2'])
        entry['targetStart'] = str(row['s2'])
        entry['targetEnd'] = str(row['e2'])
        entry['targetName'] = "."
        entry['targetStrand'] = "."
        entries.append(entry)
    
ucscdata = pd.DataFrame(entries)
ucscdata= ucscdata.sort_values(by=['#chrom','chromStart'])
###new_row = pd.DataFrame({'#chrom':"track type=interact name='interact Example Two' description='Chromatin interactions' useScore=off maxHeightPixels=200:100:50 visibility=full"},index=[0])

###ucscdata = pd.concat([new_row,ucscdata.loc[:]]).reset_index(drop=True)
ucscdata.fillna('', inplace=True)
######Edit save path below
savepath = os.path.join(inputfiledir,outputfilename+".bed")
ucscdata.to_csv(savepath,sep='\t',index=False,header=None)


cmd = '/mnt/bioadhoc-temp/Groups/vd-ay/hichip-db-loop-calling/workflow/scripts/ucsc/bedToBigBed -type=bed5+13 -as={autosql}  {bednoheader} {chromsize} {outfile}'
cmd = cmd.format(autosql=args.autosql, bednoheader=savepath, chromsize=str(args.chromsize), outfile=args.outfile)

call(cmd, shell=True)
