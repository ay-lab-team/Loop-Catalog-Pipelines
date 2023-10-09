#PBS -l mem=4gb
#PBS -l nodes=1:ppn=1
#PBS -l walltime=00:50:00
#PBS -o results/shortcuts/logs/interactions_to_longrange/
#PBS -e results/shortcuts/logs/interactions_to_longrange/
#PBS -N interactions_to_longrange.hiccups
# -t 1
# -d .

set -euo pipefail
IFS=$'\n\t'

# to run the code from bash use:
# bash workflow/scripts/visualizations/longrange/interactions_to_longrange.hiccups.qarray.sh 3

# to run the code from Qsub use:
# qsub workflow/scripts/visualizations/longrange/interactions_to_longrange.hiccups.qarray.sh -d . -t 3

# to run ALL samples with qsub use:
# qsub workflow/scripts/visualizations/longrange/interactions_to_longrange.hiccups.qarray.sh -d . -t 1-438

# allow this script to be run without qsub by assigning PBS_ARRAYID from
# # the command line using $1
if [ -z "${PBS_ARRAYID+x}" ]
then
  PBS_ARRAYID=$1
  PBS_O_WORKDIR="."
fi

# source tool paths
source workflow/source_paths.sh

# extracting the input file name
info=$(sed -n ${PBS_ARRAYID}p workflow/scripts/visualizations/samplesheets/samplesheet.hiccups.wc.txt)
input=$(echo $info | cut -d " " -f 1)
num_loops=$(echo $info | cut -d " " -f 2)

if [[ $num_loops -lt 1 ]]
then
  echo "No loops found for $input"
  exit 0
fi

# defining a list of input variables
output=$(echo $input | sed 's/bed$/longrange.bed.gz/')
prefix=$(echo $input | sed 's/\.bed$//')

echo "input: $input"
echo "output: $output"


# helper function to convert from fithichip to longrange
function fithichip_to_longrange() {

    input=$1
    prefix=$2
    temp="${prefix}.longrange.bed"

    # convert to longrange format
    awk 'BEGIN{OFS="\t"}; {score=-log($18)/log(10); if (NR > 2) {print $1, $2, $3, $4 ":" $5 "-" $6, score "\n" $4, $5, $6, $1 ":" $2 "-" $3, score}}' $input | sort -k1,1 -k2,2n > $temp
cl
    # compress and index the output 
    $bgzip -f $temp
    $tabix -f -p bed "${temp}.gz"

}

# running the interact_to_bigbed.py script
echo 'running the fithichip_to_longrange function'
cmd="fithichip_to_longrange $input $prefix"
echo "Running: $cmd"
eval $cmd