#!/bin/bash

#===============
# A stand alone executable which takes input the 
# base directory containing HiC-pro generated reads
# obtained by processing HiChiP alignment files
# different sets of reads generated from HiC-pro pipeline
# are then used to infer HiChIP peaks

# author: Sourya Bhattacharyya
# Vijay-AY lab
# La Jolla Institute for Allergy and Immunology
#===============

#===============
# sample execution command for this script:
# ./PeakInferHiChIP.sh -H /home/HiCPROREADSDIR -D /home/OutPeakDir -R 'hs' -M '--nomodel --extsize 147 -q 0.01'
#===============

usage(){
cat << EOF

Options:
   	-H 	HiCProDir 			Directory containing the reads generated by HiC-pro pipeline
   	-D  OutDir				Directory containing the output set of peaks. Default: current directory
   	-R 	refGenome			Reference genome string used for MACS3. Default is 'hs' for human chromosome. For mouse, specify 'mm'
   	-M 	MACS3
	ParamStr		String depicting the parameters for MACS3. Default: "--nomodel --extsize 147 -q 0.01"
   	-L 	ReadLengthR1		Length of reads for the R1 HiC-pro generated reads. Default 75
	-G  ReadLengthR2		Length of reads for the R2 HiC-pro generated reads. Default 75
   	-p  prev 				If 1, use previous implementation, where the coordinates are 	
   							assumed to be midpoints of the reads. Default = 0, means the 
   							current implementation is used, where coordinates and strand 
   							information is used to decide the reads.
EOF
}

#==============
# default parameters
OutDir=`pwd`'/'
HiCProBasedir=""
refGenome='hs'
MACS3ParamStr='--nomodel --extsize 147 -q 0.01'
ReadLengthR1=75
ReadLengthR2=75
UsePrevCode=0	# using the current code
#==============

while getopts "H:D:R:M:L:G:p:" opt;
do
	case "$opt" in
		H) HiCProBasedir=$OPTARG;;
		D) OutDir=$OPTARG;;
		R) refGenome=$OPTARG;;
		M) MACS3ParamStr=$OPTARG;;
		L) ReadLengthR1=$OPTARG;;
		G) ReadLengthR2=$OPTARG;;
		p) UsePrevCode=$OPTARG;;
		\?) usage
			echo "error: unrecognized option -$OPTARG";
			exit 1
			;;
	esac
done

#===================
# verify the input parameters
#===================
if [[ -z $HiCProBasedir ]]; then
	echo 'User should provide the directory containing HiC-pro output reads - exit !!'
	exit 1
fi

if [[ $(( $ReadLengthR1 % 2 )) -eq 0 ]]; then
	halfreadlenR1=`expr $ReadLengthR1 / 2`
else
	t=`expr $ReadLengthR1 - 1`
	halfreadlenR1=`expr $t / 2`
fi

if [[ $(( $ReadLengthR2 % 2 )) -eq 0 ]]; then
	halfreadlenR2=`expr $ReadLengthR2 / 2`
else
	t=`expr $ReadLengthR2 - 1`
	halfreadlenR2=`expr $t / 2`
fi

echo "ReadLengthR1 : "$ReadLengthR1
echo "halfreadlenR1: "$halfreadlenR1
echo "ReadLengthR2 : "$ReadLengthR2
echo "halfreadlenR2: "$halfreadlenR2
echo "UsePrevCode: "$UsePrevCode

#===================
# create the output directory
#===================
mkdir -p $OutDir

macs3dir=$OutDir'/MACS3_ExtSize'
mkdir -p $macs3dir
PREFIX='out_macs3'

# file containing input reads 
# to be applied for MACS3
mergedfile=$OutDir'/MACS3_input.bed'
if [[ -f $mergedfile ]]; then
	rm $mergedfile
fi

#=========================
# check the specified HiC-pro directory
# and read different categories of files
#=========================

# DE read
cntDE=0
for f in `find $HiCProBasedir -type f -name *.DEPairs`; do
	DEReadFile=$f
	cntDE=`expr $cntDE + 1`
done
if [[ $cntDE == 0 ]]; then
	echo 'There is no HiC-pro file containing DE reads !!'
	# exit 1
fi

# SC read
cntSC=0
for f in `find $HiCProBasedir -type f -name *.SCPairs`; do
	SCReadFile=$f
	cntSC=`expr $cntSC + 1`
done
if [[ $cntSC == 0 ]]; then
	echo 'There is no HiC-pro file containing SC reads !!'
	# exit 1
fi

# RE read
cntRE=0
for f in `find $HiCProBasedir -type f -name *.REPairs`; do
	REReadFile=$f
	cntRE=`expr $cntRE + 1`
done
if [[ $cntRE == 0 ]]; then
	echo 'There is no file containing RE reads!!'
	# exit 1
fi

# validpairs file
cntValid=0
if [[ -f $HiCProBasedir'/rawdata_allValidPairs' ]]; then
	ValidReadFile=$HiCProBasedir'/rawdata_allValidPairs'
	cntValid=`expr $cntValid + 1`
elif [[ -f $HiCProBasedir'/rawdata.allValidPairs' ]]; then
	ValidReadFile=$HiCProBasedir'/rawdata.allValidPairs'
	cntValid=`expr $cntValid + 1`
else
	for f in `find $HiCProBasedir -type f -name *.validPairs`; do
		ValidReadFile=$f
		cntValid=`expr $cntValid + 1`
	done
fi
if [[ $cntValid == 0 ]]; then
	echo 'There is no file containing valid pairs!! - need to exit !!'
	exit 1
fi

if [[ $cntDE -gt 0 ]]; then
	echo 'File containing DE reads: '$DEReadFile
fi
if [[ $cntSC -gt 0 ]]; then
	echo 'File containing SC reads: '$SCReadFile
fi
if [[ $cntRE -gt 0 ]]; then
	echo 'File containing RE reads: '$REReadFile
fi
if [[ $cntValid -gt 0 ]]; then
	echo 'File containing valid pairs: '$ValidReadFile
fi

# process the valid pairs file
# and write individual reads by spanning through the read length values
# first process the DE, SC, and RE pairs
if [[ $UsePrevCode == 1 ]]; then
	## using the previous implementation
	## use the coordinates mentioned in the HiC-pro output reads 
	## as the midpoints of the corresponding reads
	if [[ $cntDE -gt 0 ]]; then
		awk -v l="$halfreadlen" '{print $2"\t"($3-l)"\t"($3+l)"\n"$5"\t"($6-l)"\t"($6+l)}' $DEReadFile >> $mergedfile
	fi
	if [[ $cntSC -gt 0 ]]; then
		awk -v l="$halfreadlen" '{print $2"\t"($3-l)"\t"($3+l)"\n"$5"\t"($6-l)"\t"($6+l)}' $SCReadFile >> $mergedfile
	fi
	if [[ $cntRE -gt 0 ]]; then
		awk -v l="$halfreadlen" '{print $2"\t"($3-l)"\t"($3+l)"\n"$5"\t"($6-l)"\t"($6+l)}' $REReadFile >> $mergedfile
	fi
else 
	## latest implementation
	## check the strand information, and use the current coordinate as the starting point of the corresponding read
	if [[ $cntDE -gt 0 ]]; then
		awk -v R="$ReadLengthR1" -v L="$ReadLengthR2" '{if ($4=="+") {print $2"\t"$3"\t"($3+R-1)} else {print $2"\t"($3-R+1)"\t"$3}; if ($7=="+") {print $5"\t"$6"\t"($6+L-1)} else {print $5"\t"($6-L+1)"\t"$6}}' $DEReadFile >> $mergedfile
	fi
	if [[ $cntSC -gt 0 ]]; then
		awk -v R="$ReadLengthR1" -v L="$ReadLengthR2" '{if ($4=="+") {print $2"\t"$3"\t"($3+R-1)} else {print $2"\t"($3-R+1)"\t"$3}; if ($7=="+") {print $5"\t"$6"\t"($6+L-1)} else {print $5"\t"($6-L+1)"\t"$6}}' $SCReadFile >> $mergedfile
	fi
	if [[ $cntRE -gt 0 ]]; then
		awk -v R="$ReadLengthR1" -v L="$ReadLengthR2" '{if ($4=="+") {print $2"\t"$3"\t"($3+R-1)} else {print $2"\t"($3-R+1)"\t"$3}; if ($7=="+") {print $5"\t"$6"\t"($6+L-1)} else {print $5"\t"($6-L+1)"\t"$6}}' $REReadFile >> $mergedfile
	fi
fi

# then process the valid pairs file
# only CIS pairs and reads with length < 1 Kb
if [[ $UsePrevCode == 1 ]]; then
	## using the previous implementation
	## use the coordinates mentioned in the HiC-pro output reads 
	## as the midpoints of the corresponding reads	
	awk -v l="$halfreadlen" 'function abs(v) {return v < 0 ? -v : v} {if (($2==$5) && (abs($6-$3)<1000)) {print $2"\t"($3-l)"\t"($3+l)"\n"$5"\t"($6-l)"\t"($6+l)}}' $ValidReadFile >> $mergedfile
else
	## latest implementation
	## check the strand information, and use the current coordinate as the starting point of the corresponding read
	awk -v R="$ReadLengthR1" -v L="$ReadLengthR2" 'function abs(v) {return v < 0 ? -v : v} {if (($2==$5) && (abs($6-$3)<1000)) {if ($4=="+") {print $2"\t"$3"\t"($3+R-1)} else {print $2"\t"($3-R+1)"\t"$3}; if ($7=="+") {print $5"\t"$6"\t"($6+L-1)} else {print $5"\t"($6-L+1)"\t"$6}}}' $ValidReadFile >> $mergedfile
fi

# call MACS3 for peaks (FDR threshold = 0.01)
macs3 callpeak -t ${mergedfile} -f BED -n ${PREFIX} --outdir ${macs3dir} -g $refGenome $MACS3ParamStr