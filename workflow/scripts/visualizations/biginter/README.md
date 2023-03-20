# Running scripts
#### Main Steps
`bash make_samplesheet.fithichip_hp.sh` - Creates the samplesheet needed for the processing of these files.
`bash assess_samples.fithichip_hp.sh` - Creates a derivative samplesheet file with the number of loops per file.
`interactions_to_bigInteract.fithichip_hp.qarray.sh` - Converts fithichip derived samples bigInteract files via Qsub array jobs.
`report.sample_wc.fithichip.ipynb` - Reporter that shows the number of visualization files we should have generated.

#### The main script
`interactions_to_bigInteract.py` - Python script with logic to convert several types of interaction files into bigInteract files.