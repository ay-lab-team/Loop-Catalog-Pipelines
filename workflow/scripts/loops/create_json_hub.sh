#!/bin/sh

# geneates a hub.config.json file given a folder containing the WashU formatted 
# files all samples desired (see to_washu.sh)

# input washu folder with all individual sample washu tracks
washu_folder='/mnt/BioAdHoc/Groups/vd-ay/kfetter/hichip-db-loop-calling/results/loops/hiccups/threshold_200_10kb_loops/washu/'
cd $washu_folder

# create empty hub json file
out_hub='out_hub.config.json'
touch $out_hub

# build json file
echo "[" >> $out_hub
for sample in $washu_folder*'.txt.gz'; do
		sample_name=$(basename $sample '_out_washu.txt.gz')
cat <<EOT >> ${out_hub}
	{
	"type":"longrange",
	"url":"https://informaticsdata.liai.org/BioAdHoc/Groups/vd-ay/kfetter/hichip-db-loop-calling/results/loops/hiccups/threshold_200_10kb_loops/washu/${sample_name}_out_washu.txt.gz",
	"name":"${sample_name}",
	"showOnHubLoad": true,
	"options": {
		"height":300,
		"color":"#A95C68",
		"displayMode":"arc"
		}
	},

EOT
done

echo "]" >> $out_hub

# remove comma from last entry
edit_hub='hub.config.json'
touch $edit_hub
awk -v line=$(($(wc -l < $out_hub)-2)) '{if (NR==line) {print "\t}"} else {print $0}}'  $out_hub > $edit_hub
rm $out_hub