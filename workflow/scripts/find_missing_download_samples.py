#!/usr/bin/env python
# coding: utf-8

# In[69]:


import os
import sys
import pandas as pd
os.chdir('/mnt/BioAdHoc/Groups/vd-ay/hichip-db-loop-calling/')


# In[78]:


# setting input and output with jupyter notebook in context 
if 'ipykernel_launcher.py' in sys.argv[0]:
    output_fn = 'results/samplesheets/hicpro/missing_download_samples.txt'
else:
    input_fn = sys.argv[1]
    output_fn = sys.argv[2]


# In[79]:


# load the data
df = pd.read_table('results/samplesheets/hicpro/Current-HiChIP-Samplesheet.tsv', header=None)


# In[80]:


# get the download path
download_tpl = 'results/fastqs/raw/{}/'
df.loc[:, 'download_output'] = df[0].apply(lambda x: download_tpl.format(x))


# In[81]:


# get all serial ID's which have not been run
not_run = []
for i, sr in df.iterrows():
    if not os.path.exists(sr.download_output):
        not_run.append(i + 1)


# In[82]:


def convert_to_short_format(serial_list):
    
    small_num = serial_list[0]
    serial_list_short = []
    for i in range(1, len(serial_list)):

        prev_num = serial_list[i -1]
        next_num = serial_list[i]

        if (prev_num + 1) != next_num:

            if small_num == prev_num:
                curr_range = '{}'.format(small_num)
                serial_list_short.append(curr_range)
                small_num = next_num

            else:
                curr_range = '{}-{}'.format(small_num, prev_num)
                serial_list_short.append(curr_range)
                small_num = next_num

    if small_num == next_num:
        curr_range = '{}'.format(small_num,)
        serial_list_short.append(curr_range)
    else:
        curr_range = '{}-{}'.format(small_num, next_num)
        serial_list_short.append(curr_range)
        
    return(serial_list_short)


# In[83]:


# convert not run serial IDs to ranges/short format
not_run_short = convert_to_short_format(not_run)


# In[84]:


# generate a string version of not_run
not_run = [str(x) for x in not_run]
final_not_run = ','.join(not_run)

# generate a string version of not_run_short
final_not_run_short = ','.join(not_run_short)


# In[90]:


# write the final IDs that still need processing 
with open(output_fn, 'w') as fw:
    fw.write('\nLong Format:\n{}\n\n'.format(final_not_run))
    fw.write('Short Format:\n{}\n\n'.format(final_not_run_short))


# In[ ]:





# In[ ]:





# In[ ]:




