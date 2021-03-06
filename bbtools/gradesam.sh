#!/bin/bash
#gradesam in=<infile> out=<outfile>

function usage(){
	echo "Written by Brian Bushnell"
	echo "Last modified May 23, 2014"
	echo ""
	echo "Description:  Grades mapping correctness of a sam file of synthetic reads with headers generated by RandomReads3.java"
	echo ""
	echo "Usage:	gradesam.sh in=<sam file> reads=<number of reads>"
	echo ""
	echo "Parameters:"
	echo "in=<file>     	Specify the input sam file, or stdin."
	echo "reads=<int>    Number of reads in mapper's input (i.e., the fastq file)."
	echo "thresh=20     	Max deviation from correct location to be considered 'loosely correct'."
	echo "blasr=f       	Set to 't' for BLASR output; fixes extra information added to read names."
	echo "ssaha2=f      	Set to 't' for SSAHA2 or SMALT output; fixes incorrect soft-clipped read locations."
	echo "quality=3     	Reads with a mapping quality of this or below will be considered ambiguously mapped."
	echo "bitset=t      	Track read ID's to detect secondary alignments."
	echo "              	Necessary for mappers that incorrectly output multiple primary alignments per read."
	echo ""
	echo "Please contact Brian Bushnell at bbushnell@lbl.gov if you encounter any problems."
	echo ""
}

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/"
CP="$DIR""current/"
EA="-ea"
set=0

if [ -z "$1" ] || [[ $1 == -h ]] || [[ $1 == --help ]]; then
	usage
	exit
fi

function gradesam() {
	#module unload oracle-jdk
	#module unload samtools
	#module load oracle-jdk/1.7_64bit
	#module load samtools
	#module load pigz
	local CMD="java $EA -Xmx200m -cp $CP align2.GradeSamFile $@"
#	echo $CMD >&2
	$CMD
}

gradesam "$@"
