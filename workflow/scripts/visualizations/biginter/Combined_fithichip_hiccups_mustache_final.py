import argparse
import pandas as pd
import math
import os
from subprocess import call


parser = argparse.ArgumentParser()
parser.add_argument('--inputfile', type=str, required=True)
parser.add_argument('--chromsize',type=str, required=True)
parser.add_argument('--autosql',type=str,required=True)
parser.add_argument('--type',type=str,required=True,choices=['hiccups', 'fithichip','mustache'])
args = parser.parse_args()

bed = pd.read_csv(args.inputfile, delimiter='\t')
 
inputfilename = os.path.basename(args.inputfile)
inputfilename = inputfilename.rsplit('.', maxsplit=1)[0]
inputfiledir = os.path.dirname(args.inputfile)
print(inputfiledir)
outputfilename = "Clean_"+inputfilename

if args.type == "hiccups":
    bed = pd.read_csv(args.inputfile, delimiter='\t')
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
        try:
            entry['score'] = str(int(round(-math.log(row['fdrDonut'],10),0)))
        except:
            entry['score'] = 0
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

if args.type == "fithichip":
    bed = pd.read_csv(args.inputfile, delimiter='\t')

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
        try:
            entry['score'] = str(int(round(-math.log(row['Q-Value_Bias'],10),0)))
        except:
            entry['score'] = 0
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

if args.type == "mustache":
    tsv = pd.read_csv(args.inputfile, delimiter='\t')

    for item in ['BIN1_CHR','BIN2_CHROMOSOME','BIN1_START','BIN1_END','BIN2_START','BIN2_END']:
        tsv[item] = tsv[item].astype(int)



    #Get beginning of chromsome (Same Chromosome)
    tsv['schr'] = tsv[tsv['BIN1_CHR']==tsv['BIN2_CHROMOSOME']][['BIN1_START','BIN1_END']].min(axis=1)
    #Get end of chromosome (Same Chromosome)
    tsv['echr'] = tsv[tsv['BIN1_CHR']==tsv['BIN2_CHROMOSOME']][['BIN2_START','BIN2_END']].max(axis=1)

    #Get beginning of chromsome (Different Chromsome)
    tsv.loc[tsv['BIN1_CHR']!=tsv['BIN2_CHROMOSOME'],'schr'] = tsv[['BIN1_START']].max(axis=1)
    #Get end of chromosome (Different Chromsome)
    tsv.loc[tsv['BIN1_CHR']!=tsv['BIN2_CHROMOSOME'],'echr'] = tsv[['BIN2_START']].max(axis=1)

    entries = []
    for row in tsv.to_dict('records'):
        entry = {}
        entry['#chrom'] = 'chr'+str(row['BIN1_CHR'])
        entry['chromStart'] = str(row['schr'])
        entry['chromEnd'] = str(row['echr'])
        entry['name'] = "."
        try:
            entry['score'] = str(int(round(-math.log(row['FDR'],10),0)))
        except:
            entry['score'] = str(0)
        entry['value'] = str(0)
        entry['exp'] = "."
        entry['color'] = str(0)
        entry['sourceChrom'] = 'chr'+str(row['BIN1_CHR'])
        entry['sourceStart'] = str(row['BIN1_START'])
        entry['sourceEnd'] = str(row['BIN1_END'])
        entry['sourceName'] = "."
        entry['sourceStrand'] = "."
        entry['targetChrom'] = 'chr'+str(row['BIN2_CHROMOSOME'])
        entry['targetStart'] = str(row['BIN2_START'])
        entry['targetEnd'] = str(row['BIN2_END'])
        entry['targetName'] = "."
        entry['targetStrand'] = "."
        entries.append(entry)

data_types_dict = {'chromStart':int,
                   'chromEnd':int,
                   'score': int,
                   'value':int,
                   'color':int,
                   'sourceStart':int,
                   'sourceEnd':int,
                   'targetStart':int,
                   'targetEnd':int}

ucscdata = pd.DataFrame(entries)
ucscdata.fillna('', inplace=True)
ucscdata = ucscdata.astype(data_types_dict)
ucscdata= ucscdata.sort_values(by=['#chrom','chromStart'])
###new_row = pd.DataFrame({'#chrom':"track type=interact name='interact Example Two' description='Chromatin interactions' useScore=off maxHeightPixels=200:100:50 visibility=full"},index=[0])

###ucscdata = pd.concat([new_row,ucscdata.loc[:]]).reset_index(drop=True)
ucscdata.fillna('', inplace=True)
######Edit save path below
tmppath = os.path.join(inputfiledir,outputfilename+".bed")
ucscdata.to_csv(tmppath,sep='\t',index=False,header=None)
finalfile = os.path.join(inputfiledir,outputfilename+".bb.interact")
print(finalfile)
cmd = '/mnt/BioAdHoc/Groups/vd-ay/kfetter/packages/ucsc_genome_browser/bedToBigBed -type=bed5+13 -as={autosql}  {bednoheader} {chromsize} {outfile}'
cmd = cmd.format(autosql=args.autosql, bednoheader=tmppath, chromsize=str(args.chromsize), outfile=finalfile)

call(cmd, shell=True)

os.remove(tmppath)
