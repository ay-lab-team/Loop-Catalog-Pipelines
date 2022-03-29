# HiChIP repository for the loop calling pipeline

## Pipeline Details 
For our pipeline we are using:
1) HiC-Pro for mapping
2) Several peak callers including: hichipper, HiChIP Peaks, etc
3) FitHiChip for loop calling

For each sample we are using the following naming scheme:

**{sample_name}.{gse_id}.{gsm_id}.{srr_id}.{organism}.{treatment (wt or stimulated)}.{target of antibody}.b{biological_rep}**

And fastqs from technical replicates will be stored in it's biological replicate directory. 

## Tasks 
- [ ] Ensure new tracker is complete and ready for application @Joaquin
- [ ] Setup HiCPro using new project folder structure @Kyra @Nikhil
- [ ] Setup peak callers @Kyra @Nikhil
- [ ] Setup loop callrs @Kyra @Nihikl


## Sharing HiC-Pro and Other Resources
- To share the same HiC-Pro (main) software please use:
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

## Documentation
We have the following documentation to help us in the development of this project:
- Repository stored at: /mnt/BioAdHoc/Groups/vd-ay/hichip-db-loop-calling
- HiChIP Tracker:<br>
  https://docs.google.com/spreadsheets/d/1myw--D1_jMa3UFEUPyLy5C3MnbfcJzLIIJEoCS_3X4k/edit?usp=sharing 
- We are testing the following HiChIP Peak Callers:<br>
  https://docs.google.com/document/d/1n6wH0OYHoLTwieS9SHblOWHaG2ixcxR81lH3bZm8oeY/edit?usp=sharing
- We are testing the following HiChIP Loop Callers: **TBD**

## Other Documentation
Older task list (2022.02.26) for Kyra: https://docs.google.com/document/d/1n6wH0OYHoLTwieS9SHblOWHaG2ixcxR81lH3bZm8oeY/edit?usp=sharing
