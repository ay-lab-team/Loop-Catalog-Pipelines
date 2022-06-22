# HiChIP Repository for the Loop Calling Pipeline

## Tasks 
- [x] Ensure new tracker is complete and ready for application @Joaquin
- [x] Setup HiCPro using new project folder structure @Kyra @Nikhil
- [x] Setup peak callers @Kyra @Nikhil
- [x] Setup loop callrs @Kyra @Nihikl

## Pipeline Details 
For our pipeline we are using:
1) Grabseqs (with fasterq-dump under the hood) for downloading fastqs
2) Split fastqs with HiC-Pro split_reads.py utility script
3) Use HiC-Pro for mapping and count processing
4) Several peak callers including: hichipper, HiChIP Peaks, etc
5) FitHiChip for loop calling

### Naming Scheme for Data
For each biological replicate (typically thought of as a sample) we are using the following naming scheme:
```
{sample_name}.{gse_id}.{organism}.{target of antibody}.b{biological_rep}
```

## Samplesheets for Data Analysis
In order to share our datasets we are storing the results of our pipelines within:
```
/mnt/BioAdHoc/Groups/vd-ay/hichip-db-loop-calling/results/
```

To track all of our data we are using a Google Sheets Document: [HiChIP Tracker](https://docs.google.com/spreadsheets/d/1myw--D1_jMa3UFEUPyLy5C3MnbfcJzLIIJEoCS_3X4k/edit?usp=sharing). This document is then converted into a FASTQ based samplesheet by a Jupyter notebook and is located here:
```
results/samplesheets/fastq/2022.03.30.fastq.samplesheet.with_header.tsv
```

After all FASTQ analyses are complete we start working at the biological replicate level for which we generate a new samplesheet using another set of conversion and tracker scripts. This sample sheet is located at:
```
results/samplesheets/hicpro/2022.03.30.hicpro.samplesheet.with_header.tsv
```

***
Note: For more information on the conversion and tracker scripts check out the README.md within:
```
hichip-db-loop-calling/workflow/scripts/trackers/
```
  
## Sharing HiC-Pro and Other Related Resources
- To share the same HiC-Pro (main) software please use:
    ```
      /mnt/BioAdHoc/Groups/vd-ay/jreyna/software/hicpro/compiled_code/HiC-Pro_3.1.0/bin/HiC-Pro
    ```
- To share the same HiC-Pro utils software please use:
  - For Python based scripts use:<br>
    ```
    /mnt/BioAdHoc/Groups/vd-ay/jreyna/software/mambaforge/envs/HiC-Pro_v3.1.0/bin/python \
         /mnt/BioAdHoc/Groups/vd-ay/jreyna/software/hicpro/compiled_code/HiC-Pro_3.1.0/bin/utils/<script_name>.py
    ```
  - For BASH based scripts use:<br>
    ```
        bash /mnt/BioAdHoc/Groups/vd-ay/jreyna/software/hicpro/compiled_code/HiC-Pro_3.1.0/bin/utils/<script_name>.sh
    ```

## Software Dependencies

- We are testing the following **HiChIP Peak Callers** (to be used in pipeline if no corresponding ChIP-seq data avaliable):<br>
    - **FitHiChIP Peak Calling Utility (`PeakInferHiChIP.sh`)**
        - *Python Dependencies*: Python 3 (>=3.4), OptionParser (optparse library), gzip, networkx, numpy
        - *R Dependencies*: R (>=3.4.3), optparse, ggplot2, data.table, splines, fdrtool, parallel, tools, plyr, dplyr
            - Bioconductor packages: GenomicRanges, EdgeR
        - *Additional Dependencies*: bedtools (>= 2.26.0), samtools (>=1.6), htslib (>=1.6), bowtie2, HiC-Pro (>=2.11.4), macs2
    - **HiChIP-Peaks** (installed via pip into env)
        - *Python Dependencies*: Python 3 (3.7 used in documentation)
        - *Additional Dependencies*: bedtools, HiC-Pro (>2.11.1)
    - **hichipper** (installed via pip into env)
        - *Python Dependencies*: make sure pyyaml <5.1 (I used 3.13)
        - *R Dependencies*: R, data.table, devtools, foreach, ggplot2, knitr, networkD3, readr, reshape2
            - Bioconductor packages: diffloop
        - *Additional Dependencies*: bedtools, OpenSSL, libcurl, libxml2, samtools, pandoc
    
- We are testing the following **HiChIP Loop Callers**:
    - **FitHiChIP**
        - see dependencies for  FitHiChIP Peak Calling Utility (PeakInferHiChIP.sh)
    - **HiCCUPS**
        - *Java Dependencies*: Java 1.7 or 1.8 JDK (hicpro2juicebox requires >1.8 JDK)

- How to migrate conda environments:
    - Create a yaml file
      ```
      conda env export > environment.yml
      ```
    - Re(create) an environment from a yaml file
      ```
      conda env create -f environment.yml
      ```
    - For more details visit: https://docs.conda.io/projects/conda/en/latest/user-guide/tasks/manage-environments.html#creating-an-environment-from-an-environment-yml-file


## Meeting Minutes
- 2022.04.05 - HiCPro Samples Ready - https://docs.google.com/document/d/1XiAUMIzygqb-6b0WFCZpSjvYjTLk-pOBjl3wWzCHXi4/edit?usp=sharing
- Older task list (2022.02.26) for Kyra: https://docs.google.com/document/d/1n6wH0OYHoLTwieS9SHblOWHaG2ixcxR81lH3bZm8oeY/edit?usp=sharing


## Running the pipeline from Top to Bottom
We have worked on making this pipeline very standardized meaning we collect samples from the GEO database, give them a standardized sample name for processing, correctly identifying the biological versus technical replicate distinction, process these samplesheets and finally process them with HiCPro followed by loop calling and peak calling. Below are the steps to run this pipeline:
1) Update the online samplesheet located at: https://docs.google.com/spreadsheets/d/1myw--D1_jMa3UFEUPyLy5C3MnbfcJzLIIJEoCS_3X4k/edit?usp=sharing (some helper scripts have been generated help with this and will be explained at a later date). For samples you would like to process please update the "Start Processing" entry to 1. 
2) Download the online samplesheet to your personal clone of this repository under `results/samplesheets/fastq` and name using the following format: YYYY.MM.DD.NN.SS.fastq.google-samplesheet.tsv. Note: always make sure to use two digits for month (MM), day (DD), minute (NN) and second (SS).
3) Save this date into the tracker package under: `workflow/scripts/trackers/tracker/__init__.py`
4) Convert this Google based samplesheet into a format(s) ready for our pipeline:
5) 
    - Convert from this Google Format into a SRR format by running `workflow/scripts/trackers/converter.google_to_fastq_samplesheet.ipynb`, 
    - Update the softlink for `Current-HiChIP-SRR-Samplesheet-Without-Header.tsv` within `results/samplesheets/fastq`:  by using: `ln -s -r -f YYYY.MM.DD.NN.SS.fastq.google-samplesheet.tsv Current-HiChIP-SRR-Samplesheet-Without-Header.tsv`,
    - Convert from the processing format into a HiCPro format by running `workflow/scripts/trackers/converter.fastq_to_hicpro_samplesheet.ipynb`,
    - Update the softlink for `current.hicpro.samplesheet.without_header.tsv` within `results/samplesheets/hicpro`: by using: `ln -s -r -f YYYY.MM.DD.NN.SS.hicpro.samplesheet.without_header.tsv Current-HiChIP-SRR-Samplesheet-Without-Header.tsv`, 
    
5) Run the download tracker to find out what samples need to be downloaded: `workflow/scripts/trackers/tracker.download_srr_fastqs.ipynb`
6) Start downloading data using the qsub command from the download tracker
7) Run the split tracker to find out what samples need to be split: `workflow/scripts/trackers/tracker.split_fastqs.ipynb`
8) Start splitting data using the qsub command from the split tracker
9) Run the HiCPro tracker to find out what samples need to be run: `workflow/scripts/trackers/tracker.run_hicpro.ipynb`
10) Start HiCPro using the qsub command from the HiCPro tracker (need to be a bit more careful with this one)

Advice on running this pipeline. Samples will fail from time to time and you'll have to manually fix them. Try to save all of this fixing until you have completely run the pipeline at least once for hopefully a majority of the samples. Don't follow this advice strictly but it will help you not get lost in the tangle of mis-run samples.
