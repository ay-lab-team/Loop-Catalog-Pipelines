# Running scripts for HP samples
These instructions are give for fithichip samples but the cp and hiccups equivalents 
are identical. 

#### Main Steps
Create the samplesheet needed for the processing of these files.
```
cd ../samplesheets/
bash ../make_samplesheet.fithichip_hp.sh
```

Create a derivative samplesheet file with the number of loops per file.
```
bash assess_samples.fithichip_hp.sh
```

Convert fithichip derived samples to longrange files via Qsub array jobs.
```
qsub -t start:end -d . fithichip_to_washu.sh
```

#### The main script
`fithichip_to_washu.sh` - Python script with logic to convert several types of interaction files into bigInteract files.

`hiccups_to_washu.sh` - Python script with logic to convert several types of interaction files into bigInteract files.


#### Other
Run reporter that shows the number of visualization files we should have generated.
```
report.sample_wc.fithichip.ipynb
```