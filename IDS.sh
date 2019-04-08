#!/bin/sh

#Loop through command line arguments checking for -c and -o
for i in "$@"
do
	case $i in
		-c)
			#Create verifcation with the file name given as next argument.
			echo "Create verification file"
			;;
		-o)
			#Write results to file given as the next argument.
			echo "Output results to output file"
			;;
	esac
done
