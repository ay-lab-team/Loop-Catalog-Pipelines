samplesheet="workflow/scripts/visualizations/biginter/samplesheet.fithichip_cp.txt"
wc_output="workflow/scripts/visualizations/biginter/samplesheet.fithichip_cp.wc.txt.v2"
if [[ -f $output ]]; then
  rm $wc_output
else
  touch $wc_output
fi

# count the number of lines in each file
for fn in $(cat $samplesheet); do
  sample_wc=$(wc -l $fn |awk '{print $1}')
  sample_wc=$(expr $sample_wc - 1)
  echo -e "$fn\t$sample_wc" >> $wc_output
done