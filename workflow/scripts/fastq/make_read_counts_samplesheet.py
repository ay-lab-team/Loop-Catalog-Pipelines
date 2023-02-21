fns = glob.glob('/mnt/bioadhoc-temp/Groups/vd-ay/kfetter/hichip-db-loop-calling/results/fastqs/raw/*/*_1.fastq.gz')
fns += glob.glob('/mnt/bioadhoc-temp/Groups/vd-ay/kfetter/hichip-db-loop-calling/results/fastqs/raw/*/*_R1.fastq.gz')

outfn = 'results/samplesheets/fastq/read_counts.tsv'
with open(outfn, 'w') as fw:
    for fn in fns:
        
        file_info = fn.split('/')
        sample_name = file_info[10]
        db_accession = sample_name.split('.')[2]
        source = 'dbgap' if 'phs' in db_accession else 'geo'
        if source == 'geo':
            srr_id = file_info[11]
        else:
            srr_id = file_info[11].split('_R1')[0]
            
        # write out the samplesheet
        s = [sample_name, srr_id]
        s = '\t'.join(s)
        fw.write('{}\n'.format(s))
        
