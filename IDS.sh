#!/bin/sh

VER="$(pwd)/verification.txt"

#Loop through command line arguments checking for -c and -o

dir_loop () {	# CD FIRST then call me over
	#I love loops - I loop through directories
	for i in *
	do
		if [ -d $i ]
		then
			echo $i >> $VER
			cd $i
			dir_loop
			cd ..
		else
		if [ -f $i ]
		then
			echo "$(pwd)"/$i >> $VER
			echo -n "$(ls -l $i) " >> $VER
			CHECKSUM="$(md5sum $i | awk '{print $1}')"
			echo $CHECKSUM >> $VER
		fi
		fi
	done
}


for i in "$@"
do
	case $i in
		-c)
			#Create verifcation with the file name given as next argument.
			echo "Create verification file"
			if [ -f verification.txt ]
			then
				rm verification.txt
			fi
			touch verification.txt
			echo $VER
			dir_loop
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
