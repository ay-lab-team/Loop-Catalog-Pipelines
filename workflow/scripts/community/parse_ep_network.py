import numpy as np
import pandas as pd
import json
import argparse
import seaborn as sns

""" 
    example run: 
    python parse_ep_network.py \
        --subcomm-file /loopcatalog_storage/release-0.1/hub/hg38/comm_detect/Nonclassical_Monocyte_1800.phs001703v4p1.Homo_Sapiens.H3K27ac.b2/S5/chr2/comm2/community.txt \
        --network-file /loopcatalog_storage/release-0.1/hub/hg38/comm_detect/Nonclassical_Monocyte_1800.phs001703v4p1.Homo_Sapiens.H3K27ac.b2/S5/chr2/network.annotated.txt \
        --cytoscape-json-file /loopcatalog_storage/release-0.1/hub/hg38/comm_detect/Nonclassical_Monocyte_1800.phs001703v4p1.Homo_Sapiens.H3K27ac.b2/S5/chr2/comm2/network.annotated.cytoscape.json
"""

#########################################################################################
# make the commandline interface
#########################################################################################

parser = argparse.ArgumentParser()
parser.add_argument('--subcomm-file', dest='subcomm_fn', type=str, required=True, help="Input subcommunity file (community level).")
parser.add_argument('--network-file', dest='network_fn', type=str, required=True, help="Input network file at the chromosomal network level.")
parser.add_argument('--cytoscape-json-file', dest='cytoscape_fn', type=str, required=True, help="Output network file at the community level.")
args = parser.parse_args()

#########################################################################################
# load the subcommunity nodes
#########################################################################################
print('# load the subcommunity nodes')

subcomms = []
with open(args.subcomm_fn) as fr:   
    for line in fr:
        info = line.strip().split()
        csubcomm_name = info[0]
        nodes = info[1:]
        csubcomms = [[csubcomm_name, x] for x in nodes]
        subcomms.extend(csubcomms)
subcomms_df = pd.DataFrame(subcomms, columns=['subcomm', 'node'])
subcomms_sr = subcomms_df.set_index('node').squeeze()

#########################################################################################
# extract community network from the full chromosomal network
#########################################################################################
network_df = pd.read_table(args.network_fn)
network_df = network_df.loc[(network_df.source.isin(subcomms_df['node'])) & (network_df.target.isin(subcomms_df['node'])) ]

#########################################################################################
# transform the comm data into cytoscape json format
#########################################################################################
print('# transform the data into cytoscape json format')

uniq_subcomms = subcomms_sr.unique()

shape_dict = {'E': 'star', 'P': 'round-rectangle', 'O': 'ellipse'}
colors = sns.color_palette("bright",len(uniq_subcomms)).as_hex()
colors_dict = {}
for i, subcomm in enumerate(uniq_subcomms):
    colors_dict[subcomm] = colors[i]
    
#print('colors_dict:', colors_dict)
#print('network_df.shape[0]:', network_df.shape[0])
#print('network_df:\n', network_df.values)
#print('', subcomms_sr.unique())

unique_nodes = sorted(set(network_df['source_gene_name'].tolist() + network_df['target_gene_name'].tolist()))
nodes = []
edges = []
unique_nodes = set()
for i, sr in network_df.iterrows():

    # handle the source node
    subcomm_source = subcomms_sr[sr.source]
    if sr.source_gene_name not in unique_nodes:
        unique_nodes.add(sr.source_gene_name)    
        cnode = {}

        # add data details
        cnode['data'] = {}
        cnode['data']['id'] = sr.source_gene_name

        # add style details
        cnode['style'] = {}
        cnode['style']['background-color'] = colors_dict[subcomm_source]
        cnode['style']['shape'] = shape_dict[sr.source_annotation]

        # # add position details
        # cnode['position'] = {}
        # cnode['position']['x'] = i
        # cnode['position']['y'] = i

        # add the node
        nodes.append(cnode)

    # handle the target node
    subcomm_target = subcomms_sr[sr.target]
    if sr.target_gene_name not in unique_nodes:
        unique_nodes.add(sr.target_gene_name)    
        cnode = {}

        # add data details
        cnode['data'] = {}
        cnode['data']['id'] = sr.target_gene_name

        # add style details
        cnode['style'] = {}
        cnode['style']['background-color'] = colors_dict[subcomm_target]
        cnode['style']['shape'] = shape_dict[sr.target_annotation]

        # # add position details
        # cnode['position'] = {}
        # cnode['position']['x'] = i
        # cnode['position']['y'] = i

        # add the node
        nodes.append(cnode)

    # handle the edge
    cedge = {}
    cedge['data'] = {}
    cedge['data']['id'] = sr.source_gene_name + ',' + sr.target_gene_name
    cedge['data']['source'] = sr.source_gene_name
    cedge['data']['target'] = sr.target_gene_name
    cedge['data']['portsource'] = sr.source_gene_name
    cedge['data']['porttarget'] = sr.target_gene_name
    cedge['data']['qval'] = sr['-log10-Q-Value_Bias']
    cedge['data']['weight'] = sr['-log10-Q-Value_Bias']

    # add style details
    cedge['style'] = {}
    if subcomm_source == subcomm_target:
        cedge['style']['line-color'] = colors_dict[subcomm_source]
    else: 
        cedge['style']['line-color'] = 'black'

    edges.append(cedge)

#########################################################################################
# save the json data
#########################################################################################
print('# save the json data')

json_data = nodes + edges
json_conv = json.dumps(json_data, indent=4)
with open(args.cytoscape_fn, 'w') as fw:
    fw.write(json_conv)
