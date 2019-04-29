#!/bin/sh

VER="$(pwd)/"

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
			echo "Output results to output file" # DEBUG - Checks to see if argument fires
			echo "IN $1" #Do stuff
			#If output name exists
			# Move to the output file name
			if [ "$#" -gt 1 ]
			then
				shift
				echo "Saving Data $1"
				# hi
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
