# check the dir presence for archived and renames
bash workflow/scripts/rename_samples/hichip-based/check_archived.sh
bash workflow/scripts/rename_samples/hichip-based/check_renames.sh

# join these results
output_fn="results/misc/rename_samples/archive/check_samples.joined.txt"
paste results/misc/rename_samples/archive/check_samples.archived.txt \
    results/misc/rename_samples/archive/check_samples.renamed.txt | \
    awk '{ \
           if($0 == "\t") \
               print $0; \
           else if($2 == $4) \
               print $2, $4, "Complete", $1, $3; \
           else \
               print $2, $4, "Missing", $1, $3; \
         }' > $output_fn
