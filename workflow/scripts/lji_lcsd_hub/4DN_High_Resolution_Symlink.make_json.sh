#!/bin/bash

# Input file name
input_file="results/lji_lcsd_hub/release-0.1/hub/hg38/loops/hic/mustache/summary.txt"

# Output file name
output_file="results/lji_lcsd_hub/release-0.1/hub/hg38/loops/hic/mustache/summary.json"

# Start writing to the output file
echo "[" > "$output_file"

# Read each line from the input file
while IFS=$'\t' read -r sample field1 field2 field3; do
    # Start constructing JSON object
    echo -n "{ \"sample_name\": \"$sample\", \"resolution\": \"$field1\", \"normalization\": \"$field2\", \"num_loops\": \"$field3\" }," >> "$output_file"
done < "$input_file"

# Remove the trailing comma from the last object
truncate -s -1 "$output_file"

# End the JSON array
echo "]" >> "$output_file"
