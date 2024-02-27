This is a sub-pipeline for the Loop Catalog ChIP-seq samples.

The idea behing this pipeline is that we are processing publically
available ChIP-seq samples that may share control samples. In order
to avoid redundant downloads I [Joaquin] developed a slightly different 
pipeline that first downloads all unique SRR FASTQs. From there, SRR 
are concatinated based on their belonging to either a single GSM as the 
main set of reads or a control dataset composed of multiple SRRs. Control
samples are then pre-aligned and finally ChIPLine is applied. Below are the 
steps rewritten as a bulleted list: 

1) Download all unique SRRs
2) Combine SRRs according to main ChIP-seq samples or control samples
3) Control samples are aligned to their respective genomes in preparation for ChIPLine
3) Run the ChIPLine pipeline
