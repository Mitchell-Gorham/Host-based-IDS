#!/bin/sh

VER="$(pwd)/"
CPTH="$(pwd)" #CHECKPATH variable that stores the path to the check file

#Full Path | Perms | Type | Owner | Group | Size | Last Modified Date | File Name | Checksum

#Loop through command line arguments checking for -c and -o

dir_loop () {
	# Recursively loops through each directory and file in the specified directory
	for i in *
	do
		if [ -d $i ]	# Checks if current object is directory, stores data then begins looping though it
		then
			echo -n "$(pwd)"/$i >> $1
			echo " $(ls -ld $i | sed 's/2/directory/') " >> $1
			cd $i
			dir_loop
			cd ..
		else
		if [ -f $i ]	# Checks if current object is a file, stores all it's data and moves on
		then
			echo -n "$(pwd)"/$i  >> $1
			echo -n " $(ls -l $i | sed 's/1/file/') " >> $1
			CHECKSUM="$(md5sum $i | awk '{print $1}')"
			echo $CHECKSUM >> $1
		fi
		fi
	done
}
#
#	Checks directory against verification file and generates output
#
check_files_loop () {
	#Compare check file to verification file and print differences
	tmpfile=$(mktemp) # Create temporary file

	added=0 	#counter to show how many files have been added
	deleted=0	#counter to show how many files have been deleted

	cat $VER |
	{
		while read veri		# Detects Deletions and Modifications
		do
			COUNT=$(grep -c "$veri" $CPTH)
			if [ $COUNT = 0 ]
			then
				deleted=`expr $deleted + 1`
				echo "$veri -d" >> $tmpfile
			fi
		done
	}

	cat $CPTH |
	{
		while read check	# Detects Additions and Modifications
		do
			COUNT=$(grep -c "$check" $VER)
			if [ $COUNT = 0 ]
			then
				added=`expr $added + 1`
				echo "$check -a" >> $tmpfile
			fi
		done
	}
	# Save all modified file names
	MODIFIED="$(sort $tmpfile | awk '{print $10}' | uniq -iD | uniq -i)"
	cat $tmpfile |
	{
		while read temp		# Detects deletions and additions
		do
			NAMES="$( echo $temp | awk '{print $10}')"
			COUNT=$(grep -c "$NAMES" $tmpfile)
			if [ $COUNT = 1 ]
			then
				TYPE="$( echo $temp | awk '{print $12}')"
				if [ "$TYPE" = "-a" ]
				then
					ADD="$ADD $NAMES"
				else
				if [ "$TYPE" = "-d" ]
				then
					DEL="$DEL $NAMES"
				fi
				fi
			fi
		done
		#rm t.txt - #remove temp file - uncomment when needed

		if [ "$#" -gt 0 ]	# Checks if user has supplied an output file to save results to
		then
			echo "Files created: " $ADD >> $1
			echo "Files deleted: " $DEL >> $1
		else
			# Outputs results to the console
			echo "Files created: " $ADD
			echo "Files deleted: " $DEL
		fi
	}
	if [ "$#" -gt 0 ]	# Checks if user has supplied an output file to save results to
	then
		echo "Files modified: " $MODIFIED >> $1
	else
		echo "Files modified: " $MODIFIED
	fi
	rm $tmpfile
}
##
##	MAIN
##
for i in "$@"
do
	case $i in
		-c)	# Requires name of file after argument
			# Create verifcation with the file name given as next argument.
			shift
			echo "Creating verification file called $1"
			#shift
			# Check if user even entered an argument for -c
			# Check if entered argument ends in .txt, if it doesn't add it.
			if [ -f $1 ]	# Checks to see if file with same name exists
			then
				rm $1	# Removes existing file of the same name if it exists
			fi
			touch $1	# Creates file with the name specified by the user
			VER="$VER$1"
			dir_loop $VER	# Run the verification file creation script
			;;

		-o)	# Requires verification file and (Optionally)  output file name IN THIS ORDER
			# Write results to file given as the next argument.
			shift
			echo "Checking against verification file: $1"
			if [ -f "check.txt" ]	# Temp File Creation mangement
			then
				rm "check.txt"
			fi
			checkfile=$(mktemp)
			CPTH="$checkfile"
			VER="$VER$1"
			dir_loop $CPTH

			#check_files_loop
			#If output name exists
			# Move to the output file name
			if [ "$#" -gt 1 ]	# Checks if user has supplied an output file to save results to
			then
				shift
				echo "Writing results to file: $1"
				check_files_loop $1
			else
				check_files_loop
			fi
			;;

		-dum)	# Creates dummy directories and files
			echo "Creating example directories and files to work with"
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
			# Creates a symbolic link
			#if [ ! -L "slink" ]
			#then
			#	ln -s file1.txt slink1
			#	ls -l file1.txt slink1
			#fi
			;;

		-?*)	# Potential room for argument catchall (out of scope)
			echo "$i isn't valid"
			;;
	esac
	if [ "$#" -gt 1 ] # if num arguments greater than 1
	then
		#echo "PreShift $1"
		shift
		#echo "PostShift $1"
	fi
done
