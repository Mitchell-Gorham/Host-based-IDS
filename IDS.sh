#!/bin/sh


#Full Path | Perms | Type | Owner | Group | Size | Last Modified Date | File Name | Checksum

#Loop through command line arguments checking for -c and -o

dir_loop () {
	# Recursively loops through each directory and file in the specified directory
	for i in *
	do
		if [ -d $i ]	# Checks if current object is directory, stores data then begins looping though it
		then
			echo -n "$(pwd)"/$i >> $1
			echo " $(ls -ld $i) " >> $1
			cd $i
			dir_loop
			cd ..
		else
		if [ -f $i ]	# Checks if current object is a file, stores all it's data and moves on
		then
			if [ -z "$2" ]	# If there is no second argument supplied
			then
				if [ "$(pwd)"/$i != $1 ] # checks if current file name isn't same name as passed file name
				then
					echo -n "$(pwd)"/$i  >> $1
					echo -n " $(ls -l $i) " >> $1
					CHECKSUM="$(md5sum $i | awk '{print $1}')"
					echo $CHECKSUM >> $1
				fi
			else
			if [ "$(pwd)"/$i != "$1" ] && [ "$(pwd)"/$i != "$2" ] # If two args presented, check to make sure file name isn't equal to either of them
			then
				echo "i is $(pwd)"/$i	#
				echo "1 is "$1		#DEBUG
				echo "2 is "$2		#
				echo ""			#

				echo -n "$(pwd)"/$i  >> $1
				echo -n " $(ls -l $i) " >> $1
				CHECKSUM="$(md5sum $i | awk '{print $1}')"
				echo $CHECKSUM >> $1
			fi
			fi
		fi
		fi
	done
}

check_files_loop () {
	#Compare check file to verification file and print differences
	if [ -f "t.txt" ]	# Checks to see if file with same name exists
	then
		rm "t.txt"	# Removes existing file of the same name if it exists
	fi
	touch "t.txt"

	added=0 	#counter to show how many files have been added
	deleted=0	#counter to show how many files have been deleted

	cat $1 |
	{
		while read veri		# Detects Deletions and Modifications
		do
			COUNT=$(grep -c "$veri" $2)
			if [ $COUNT = 0 ]
			then
				deleted=`expr $deleted + 1`
				echo "$veri -d" >> "t.txt"
			fi
		done
	}

	cat $2 |
	{
		while read check	# Detects Additions and Modifications
		do
			COUNT=$(grep -c "$check" $1)
			if [ $COUNT = 0 ]
			then
				added=`expr $added + 1`
				echo "$check -a" >> "t.txt"
			fi
		done
	}
	# Save all modified file names
	MODIFIED="$(sort t.txt | awk '{print $10}' | uniq -iD | uniq -i)"
	cat "t.txt" |
	{
		while read temp		# Detects deletions and additions
		do
			NAMES="$( echo $temp | awk '{print $10}')"
			COUNT=$(grep -c "$NAMES" "t.txt")
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

		if [ "$#" -gt 2 ]	# Checks if user has supplied an output file to save results to
		then
			echo "Files created: " $ADD >> $3
			echo "Files deleted: " $DEL >> $3
		else
			# Outputs results to the console
			echo "Files created: " $ADD
			echo "Files deleted: " $DEL
		fi
	}

	if [ "$#" -gt 2 ]	# Checks if user has supplied an output file to save results to
	then
		echo "Files modified: " $MODIFIED >> $3
	else
		echo "Files modified: " $MODIFIED
	fi
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
			# Check if user even entered an argument for -c
			# Check if entered argument ends in .txt, if it doesn't add it.
			if [ -f $1 ]	# Checks to see if file with same name exists
			then
				rm $1	# Removes existing file of the same name if it exists
			fi
			touch $1	# Creates file with the name specified by the user
			VER="$(pwd)/"$1
			dir_loop $VER	# Run the verification file creation script
			shift
			;;

		-o)	# Requires verification file and (Optionally)  output file name IN THIS ORDER
			# Write results to file given as the next argument.
			shift
			echo "Checking against verification file: $1"
			if [ -f "check.txt" ]	# Temp File Creation mangement
			then
				rm "check.txt"
			fi
			touch "check.txt"
			CPTH="$(pwd)/check.txt"
			VER="$(pwd)/"$1
			dir_loop $CPTH $VER

			#If output name exists
			# Move to the output file name
			if [ "$#" -gt 1 ]	# Checks if user has supplied an output file to save results
			then
				shift
				echo "Writing results to file: $1"
				check_files_loop $VER $CPTH $1
			else			# Displays output to screen if no output supplied
				check_files_loop $VER $CPTH
			fi
			shift
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
			#for i in 1 2
			#do
			#	if [ ! -L "slink" ]
			#	then
			#		ln -s file$i.txt slink$i
			#		#ls -l file$i.txt slink$i
			#	fi
			#done
			shift
			;;
		-?*)	# Potential room for argument catchall (out of scope)
			echo "Invalid arguement: " $1
			echo "Arguements available are: "
			echo "-c to create verfication file"
			echo "-o to display output or write output to file"
			shift
			;;
	#if [ "$#" -gt 1 ] # if num arguments greater than 1
	#then
	#	echo "PreShift $1"
	#	shift
	#	echo "PostShift $1"
	#fi
	esac
done
