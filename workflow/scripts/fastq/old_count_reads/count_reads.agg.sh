set -euo pipefail 

###############################################################################
## make a file with sample information for second run
###############################################################################
#echo "# make a file with sample information"
sample_tmp="results/tables/read_counts/sample_info.temp.txt"
#ls results/fastqs/stats/*/*.*.num_reads.txt | sort | parallel basename {} | sed "s/.num_reads.txt//" | sed "s/\.SRR/\tSRR/g" > $sample_tmp
#
###############################################################################
## make a file with read count information 
###############################################################################
#echo "# make a file with read count information"
read_tmp="results/tables/read_counts/read_count.temp.txt"
#ls results/fastqs/stats/*/*.*.num_reads.txt | sort | parallel cat {} > $read_tmp
#
###############################################################################
## paste together
###############################################################################
## paste together
#echo "# paste together"
results_fn="results/tables/read_counts/fastq.read_counts.v2.tsv"
#paste $sample_tmp $read_tmp > $results_fn 
#
#echo "Agg file: $results_fn"
#


###############################################################################
# temporarily make a version that stitches version 1 and 2 together
###############################################################################
# this is necessary because some of the fastqs cannot be recalculated from 
# scractch since their symlink is broken. Will look for the files later on.
results1_fn="results/tables/read_counts/fastq.read_counts.v1.correct_div-two.tsv"
results2_fn="results/tables/read_counts/fastq.read_counts.v2.tsv"
results3_manual_fn="results/tables/read_counts/fastq.read_counts.manual_entries.v2.tsv"
results_fn="results/tables/read_counts/fastq.read_counts.final.tsv"
tmp_fn="results/tables/read_counts/fastq.read_counts.temp.tsv"

# remove results2 samples from result1, some have been re-run and improved
# then adding this to the results
results2_tmp_fn="results/tables/read_counts/fastq.read_counts.v2.tsv.tmp"
cut -f 1,2 $results2_fn > $results2_tmp_fn
grep -v -f $results2_tmp_fn $results1_fn | sed '1d' | awk 'NF == 3' > $tmp_fn

# adding all of results2 
cat $results2_fn $results3_manual_fn | awk 'NF == 3' >> $tmp_fn

# sorting the final data
sort $tmp_fn | uniq > $tmp_fn.sorted
mv $tmp_fn.sorted $tmp_fn

# building the final file with a header 
cat $results1_fn | head -1 > $results_fn
cat $tmp_fn >> $results_fn

echo "final file: $results_fn"

###############################################################################
## remove the temp files
###############################################################################
rm -f $sample_tmp $read_tmp $results2_tmp_fn $tmp_fn
#wc -l $results1_fn $results2_fn $results_fn












