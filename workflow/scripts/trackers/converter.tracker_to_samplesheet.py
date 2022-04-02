#!/usr/bin/env python
# coding: utf-8

# In[1]:


import os
import sys
import pandas as pd
os.chdir('/mnt/BioAdHoc/Groups/vd-ay/hichip-db-loop-calling/')


# In[2]:


# setting input and output with jupyter notebook in context 
if 'ipykernel_launcher.py' in sys.argv[0]:
    input_fn = 'results/samplesheets/hicpro/2022.03.30-HiChIP-Tracker.tsv'
    output_prefix = 'results/samplesheets/hicpro/2022.03.30-HiChIP-Samplesheet.tsv'
else:
    input_fn = sys.argv[1]
    output_prefix = sys.argv[2]


# In[3]:


# loading the samplesheet
df = pd.read_table(input_fn, skiprows=1)

# extract those samples which are ready for processing
ready_df = df.loc[df['Start Processing'] == 'Yes']

# extract only the columns needed
major_cols = ['Sample Name (as used in the server)',
 'GSE ID',
 'GSM ID',
 'SRR ID',
 'Organism',
 'Biological Replicate Serial No',
 'Technical Replicate Serial No',
 'ChIP-seq Pull Down',
 'Restriction Enzyme']
ready_df = ready_df[major_cols]

# reformat the organism column
def parse_organism(string):
    new_words = []
    for word in string.split():
        new_words.append(word.capitalize())
        new_string = '_'.join(new_words)
    return(new_string)
ready_df.loc[:, 'Organism'] = ready_df.loc[:, 'Organism'].apply(parse_organism)

# In[4]:


# getting the sample names
sample_names = []
for i, sr in ready_df.iterrows():
    sample_name = '{sample_name}.{gse_id}.{organism}.{antibody_target}.b{biological_rep}'
    sample_name = sample_name.format(sample_name=sr[0],
                                     gse_id=sr[1],
                                     organism=sr[4],
                                     antibody_target=sr[7], 
                                     biological_rep=sr[5])
    sample_names.append(sample_name)
ready_df.loc[:, 'sample_name'] = sample_names


# In[5]:


# renaming the columns for easy computational use 
ready_df.columns = ['sample_name', 'gse_id', 'gsm_id', 'srr_id',
                    'organism', 'bio_rep', 'tech_rep', 'antibody_target',
                    'restriction_enzyme', 'std_sample_name']


# In[6]:


# reorder the columns
reorder = ['std_sample_name',
             'gse_id',
             'gsm_id',
             'srr_id',
             'organism',
             'bio_rep',
             'tech_rep',
             'antibody_target',
             'restriction_enzyme',
             'sample_name']

ready_df = ready_df[reorder]


# In[7]:


ready_df


# In[8]:


header_output = '{}.with_header.tsv'.format(output_prefix)
ready_df.to_csv(header_output, header=True, index=False, sep='\t')


# In[9]:


without_header_output = '{}.without_header.tsv'.format(output_prefix)
ready_df.to_csv(without_header_output, header=False, index=False, sep='\t')


# In[10]:


without_header_output


# In[ ]:




