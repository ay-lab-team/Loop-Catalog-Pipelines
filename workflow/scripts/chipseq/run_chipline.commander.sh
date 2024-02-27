#!/bin/bash

# set strict mode
set -euo pipefail 
IFS=$'\n\t'

# get sample info
sample_name=$1
sample_no=$2

# get date
curr_date=$(date '+%Y.%m.%d.%H.%M')

# run the main program
output="results/peaks/chipline_v2/logs/run_chipline/run_chipline.${sample_name}.${curr_date}.out"
error="results/peaks/chipline_v2/logs/run_chipline/run_chipline.${sample_name}.${curr_date}.err"

debug=0
#debug=1
if [ "${debug}" == 1 ];
then
    cmd="bash workflow/scripts/chipseq/run_chipline.qsh ${sample_no}"
else
    cmd="bash workflow/scripts/chipseq/run_chipline.qsh ${sample_no} > ${output} 2> ${error}"
fi

echo "Running: $cmd"
eval $cmd
