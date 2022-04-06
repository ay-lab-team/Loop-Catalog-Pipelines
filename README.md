# HiChIP Repository for the Loop Calling Pipeline

## Tasks 
- [x] Ensure new tracker is complete and ready for application @Joaquin
- [x] Setup HiCPro using new project folder structure @Kyra @Nikhil
- [ ] Setup peak callers @Kyra @Nikhil
- [ ] Setup loop callrs @Kyra @Nihikl

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
        - *Java Dependencies*: Java 1.7 or 1.8 JDK

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
