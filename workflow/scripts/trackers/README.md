# Samplesheet Converters 
To run different jobs we need a samplesheet and these sample sheets are 
created by these converters. 
converter.google_to_fastq_samplesheet - converts between the samplesheet on Google Docs to the fastq samplesheet.
scripts/trackers/converter.fastq_to_hicpro_samplesheet.ipynb - converts between the fastq download spreadsheet to the hicpro samplesheet. 


# Trackers
Check logs from each script and get samples that needed to be run/re-run.
workflow/scripts/fastq/download_srr_fastqs.qarray.qsh - tracker.download_srr_fastqs.[py|ipynb]
workflow/scripts/hicpro/split_fastqs.qarray.qsh - tracker.split_fastqs.[py|ipynb]
workflow/scripts/hicpro/run_hicpro.sh - tracker.run_hicpro.ipynb


# Other
- Using the dot language to show connections between different notebooks
    - https://en.wikipedia.org/wiki/DOT_(graph_description_language)