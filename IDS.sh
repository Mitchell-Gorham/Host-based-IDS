#!/bin/sh

VER="$(pwd)/"
CPTH="$(pwd)/" #CHECKPATH variable that stores the path to the check file

#Full Path | Perms | Type | Owner | Group | Size | Last Modified Date | File Name | Checksum

#Loop through command line arguments checking for -c and -o

dir_loop () {	# CD FIRST then call me over
	# Recursively loops through each directory and file in the specified directory
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
check_loop () {
	# Recursively loops through each directory and file, checking them against the verification file
	for i in *
	do
		if [ -d $i ]
		then
			echo -n "$(pwd)"/$i >> $CPTH
			echo " $(ls -ld $i) " >> $CPTH
			cd $i
			check_loop
			cd ..
		else
		if [ -f $i ]
		then
			echo -n "$(pwd)"/$i  >> $CPTH
			echo -n " $(ls -l $i) " >> $CPTH
			CHECKSUM="$(md5sum $i | awk '{print $1}')"
			echo $CHECKSUM >> $CPTH
		fi
		fi
	done

}
check_files_loop () {
	#Compare check file to verification file and print differences
	added=0 	#counter to show how many files have been added
	deleted=0	#counter to show how many files have been deleted

	cat $VER | while read veri
	do
		grep -n "$veri" $CPTH 
	done

}
##
for i in "$@"
do
	case $i in
		-c)	# Requires name of file after argument
			# Create verifcation with the file name given as next argument.
			echo "Create verification file"
			shift
			# Check if user even entered an argument for -c
			# Check if entered argument ends in .txt, if it doesn't add it.
			echo "File Name: $1"	# DEBUG - Display name of file
			if [ -f $1 ]	# Checks to see if file with same name exists
			then
				rm $1	# Removes existing file of the same name if it exists
			fi
			touch $1	# Creates file with the name specified by the user
			VER="$VER$1"
			dir_loop	# Run the verification file creation script
			;;

		-o)	# Requires verification file and (Optionally)  output file name IN THIS ORDER
			# Write results to file given as the next argument.
			shift
			echo "Checking against verification file: $1" #Do stuff
			if [ -f "check.txt" ]
			then
				rm "check.txt"	#
			fi
			touch "check.txt"	#
			CPTH="${CPTH}check.txt"
			VER="$VER$1"
			check_loop	#
			check_files_loop
			#If output name exists
			# Move to the output file name
			if [ "$#" -gt 1 ]
			then
				shift
				echo "Writing results to file: $1"	
			fi
			# If user
			# echo
			;;

		-dum)	#
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
		#*)
		#	echo "You screwed up"
		#	;;
	esac
	if [ "$#" -gt 1 ] # if num arguments greater than 1
	then
#		echo "PreShift $1"
		shift
#		echo "PostShift $1"
	fi
done
