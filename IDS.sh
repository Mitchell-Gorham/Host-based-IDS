#!/bin/sh

VER="$(pwd)/"

#Full Path | Perms | Type | Owner | Group | Size | Last Modified Date | File Name | Checksum

#Loop through command line arguments checking for -c and -o

dir_loop () {	# CD FIRST then call me over
	#I love loops - I loop through directories
	for i in *
	do
		if [ -d $i ]
		then
			echo -n "$(pwd)"/$i >> $VER
			echo " $(ls -ld $i) " >> $VER
			cd $i
			dir_loop
			cd ..
		else
		if [ -f $i ]
		then
			echo -n "$(pwd)"/$i  >> $VER
			echo -n " $(ls -l $i) " >> $VER
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
			X=$1; shift
			echo $1
			if [ -f $1 ]
			then
				rm $1
			fi
			touch $1
			VER="$VER$1"
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
	if [ "$#" -gt 1 ]
	then
		shift
	fi
done
