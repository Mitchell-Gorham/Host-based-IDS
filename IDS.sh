#!/bin/sh

#Loop through command line arguments checking for -c and -o
for i in "$@"
do
	case $i in
		-c)
			#Create verifcation with the file name given as next argument.
			echo "Create verification file"
			rm verification.txt
			touch verification.txt
			for i in *
			do
				echo "$(ls -l $i)" >> verification.txt
				CHECKSUM="$(md5sum $i | awk '{print $1}')"
				echo $CHECKSUM >> verification.txt
			done
			;;
		-o)
			#Write results to file given as the next argument.
			echo "Output results to output file"
			;;
		-dum)
			#Create dummy folders and files
			for i in 1 2 3
			do
				if [ ! -d "dir$i" ]
				then
					mkdir "dir$i"
				fi
				if [ ! -f "file$i" ]
				then
					touch "file$i.txt"
				else
					echo "$i exists"
				fi
			done
			;;
	esac
done
