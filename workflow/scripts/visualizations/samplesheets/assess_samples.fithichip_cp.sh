samplesheet="workflow/scripts/visualizations/samplesheets/samplesheet.fithichip_cp.txt"
wc_output="workflow/scripts/visualizations/samplesheets/samplesheet.fithichip_cp.wc.txt"
if [[ -f $wc_output ]]; then
  rm $wc_output
else
  touch $wc_output
fi

# count the number of lines in each file
for fn in $(cat $samplesheet); do
  sample_wc=$(wc -l $fn |awk '{print $1}')
  sample_wc=$(expr $sample_wc - 1)
  if [[ $sample_wc -lt 0 ]];
  then
    sample_wc=0
  fi
  echo -e "$fn\t$sample_wc" >> $wc_output
done