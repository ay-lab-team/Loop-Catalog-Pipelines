# Running scripts
#### Main Steps
`bash make_samplesheet.fithichip.sh` - Creates the samplesheet needed for the processing of these files.
`bash assess_samples.sh` - Creates a derivative samplesheet file with the number of loops per file.
`interactions_to_bigInteract.fithichip.qarray.sh` - Converts fithichip derived samples bigInteract files via Qsub array jobs.
`report.sample_wc.ipynb` - Reporter that determines the number of visualization files we should generate.

#### The main script
`interactions_to_bigInteract.py` - Python script with logic to convert several types of interaction files into bigInteract files.