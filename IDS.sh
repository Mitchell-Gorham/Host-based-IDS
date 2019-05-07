#!/bin/sh

#Full Path | Perms | Type | Owner | Group | Size | Last Modified Date | File Name | Checksum

#Loop through command line arguments checking for -c and -o

dir_loop () {
	# Recursively loops through each directory and file in the specified directory
	#"$(find *)" | while read i
	for i in *
	do
		if [ -d "$i" ]	# Checks if current object is directory, stores data then begins looping though it
		then
			echo -n "$(pwd)/$i" >> $1
			echo " $(ls -ld $i | sed 's/2/directory/') " >> $1
			cd $i
			dir_loop $1 $2
			cd ..
		else
		if [ -f "$i" ]	# Checks if current object is a file, stores all it's data and moves on
		then
			if [ -z "$2" ]	# If there is no second argument supplied
			then
				if [ "$(pwd)/$i" != $1 ] # checks if current file name isn't same name as passed file name
				then
					echo -n "$(pwd)/$i"  >> $1
					TEST="$(ls -l $i | awk '{print}')"
					case $TEST in
						l*)
							echo -n " $(ls -l $i | sed 's/1/symlink/') " >> $1
							;;
						*)
							echo -n " $(ls -l $i | sed 's/1/file/') " >> $1
							;;
					esac
					CHECKSUM="$(md5sum $i | awk '{print $1}')"
					echo $CHECKSUM >> $1
				fi
			else
			if [ "$(pwd)/$i" != "$1" ] && [ "$(pwd)/$i" != "$2" ] # If two args presented, check to make sure file name isn't equal to either of them
			then
				echo -n "$(pwd)/$i"  >> $1
				TEST="$(ls -l $i | awk '{print}')"
				case $TEST in
					l*)
						echo -n " $(ls -l $i | sed 's/1/symlink/') " >> $1
						;;
					*)
						echo -n " $(ls -l $i | sed 's/1/file/') " >> $1
						;;
				esac
				CHECKSUM="$(md5sum $i | awk '{print $1}')"
				echo $CHECKSUM >> $1
			fi
			fi
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

	cat $2 |
	{
		while read veri		# Detects Deletions and Modifications
		do
			COUNT=$(grep -c "$veri" $1)
			if [ $COUNT = 0 ]
			then
				deleted=`expr $deleted + 1`
				echo "$veri -d" >> $tmpfile
			fi
		done
	}

	cat $1 |
	{
		while read check	# Detects Additions and Modifications
		do
			COUNT=$(grep -c "$check" $2)
			if [ $COUNT = 0 ]
			then
				added=`expr $added + 1`
				echo "$check -a" >> $tmpfile
			fi
		done
	}
	# Save all modified file names
	#cat $tmpfile
	MODIFIED="$(sort $tmpfile | awk '{print $10}' | uniq -iD | uniq -i)"
	cat $tmpfile |
	{
		while read temp		# Detects deletions and additions
		do
			NAMES="$( echo $temp | awk '{print $10}')"
			COUNT=$(grep -c "$NAMES" $tmpfile)
			if [ $COUNT = 1 ]
			then
				DIRCHECK="$( echo $temp | awk '{print $3}')"
				if [ "$DIRCHECK" = "directory" ]
				then
					TYPE="$( echo $temp | awk '{print $11}')"
				elif [ "$DIRCHECK" = "file" ]
				then
					TYPE="$( echo $temp | awk '{print $12}')"
				else
					echo $temp
					TYPE="$( echo $temp | awk '{print $14}')" 
				fi

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
		if [ -n "$3" ]
		then
			if [ -f $3 ]
			then
				rm $3
			fi
			touch $3
		fi
		if [ -z "$ADD" ]
		then
			ADD="None"
		fi
		if [ -z "$DEL" ]
		then
			DEL="None"
		fi 
		output "Objects created: " "$ADD" "$3"
		output "Objects deleted: " "$DEL" "$3"
	}
	if [ -z "$MODIFIED" ]
	then
		MODIFIED="None"
	fi
	output "Objects modified: " "$MODIFIED" "$3"
	rm $tmpfile
}

output () {	# Takes (1)Header Text, (2)List of discrep and opt(3)Output name
	# Saves to $3 (Output name) if it exists
	if [ -n "$3" ]
	then
		echo $1 >> $3
		for i in $2
		do
			echo $i >> $3
		done
	fi
	# Display to console
	echo $1
	for i in $2
	do
		echo $i
	done
}

case_func () {
  for i in "$@"
  do
	case $i in
		-c)	# Requires name of file after argument
			# Create verifcation with the file name given as next argument.
			shift
			if [ -n "$1" ] && [ `echo "$1"|awk -F . '{print $NF}'` = "txt" ] && [ $1 != "txt" ] && [ $1 != ".txt" ]	# Makes sure an argument is present.
			then
				echo "Creating verification file called $1"
				# Check if user even entered an argument for -c
				# Check if entered argument ends in .txt, if it doesn't add it.
				if [ -f $1 ]	# Checks to see if file with same name exists
				then
					rm $1	# Removes existing file of the same name if it exists
				fi
				touch $1	# Creates file with the name specified by the user
				VER="$(pwd)/$1" # Stores location of verification file
				dir_loop $VER	# Run the verification file creation script
				NEWVER="$(pwd)/$1.enc" # Stores location of encrypted verification file
				`openssl enc -aes-256-cbc -salt -in "$VER" -out "$NEWVER"` # Encrypts verification file
				rm $VER # Removes old verification file (plain text verison)
				echo "Verification file encrypted"
				return 1
			else
				echo "Error - Expected file name ending in .txt after -c."
				return 0
			fi
			exit 126
			;;
		-o)	# Requires verification file and (Optionally)  output file name IN THIS ORDER
			# Write results to file given as the next argument.
			shift
			if [ -n "$1" ] && [ `echo "$1"|awk -F . '{print $NF}'` = "txt" ] && [ $1 != "txt" ] && [ $1 != ".txt" ]	# Makes sure an argument is present.
			then
				if [ -f "$1.enc" ]
				then
					checkfile=$(mktemp)
					CPTH="$checkfile"
					VER="$(pwd)/$1"
					ENCVER="$(pwd)/$1.enc"
					`openssl enc -aes-256-cbc -d -in "$ENCVER" -out "$VER"`
					rm $ENCVER
					dir_loop $CPTH $VER
					if [ "$#" -gt 1 ]	# Checks if user has supplied an output file to save results to
					then
						shift
						echo "Writing results to file: $1"
						check_files_loop $CPTH $VER $1
					else
						echo "Writing results to terminal"
			 			check_files_loop $CPTH $VER
					fi
					# Re-encrypt verification file
					echo "Please re-enter password to re-encrypt verification file: "
					`openssl enc -aes-256-cbc -salt -in "$VER" -out "$ENCVER"`
					rm $VER # Remove plain text verification file`
					return 1
				else
					echo "Error - No file named "$1" found, please double check the file name."
					return 0
				fi
			else
				echo "Error - Expected verification file name ending in .txt after -o."
				return 0 # Error here
			fi
			exit 126
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
			return 1
			;;
  		-?*)	# Potential room for argument catchall (out of scope)
			echo "$i isn't a valid argument"
			;;
		esac
		if [ "$#" -gt 1 ] # if num arguments greater than 1
		then
			#echo "PreShift $1"
			shift
			#echo "PostShift $1"
		fi
	done
}

#
#MAIN
#

if [ "$#" = 0 ]
then
	while :
	do
		echo "Please choose from the following options:"
		echo "1 - Intrusion Detection Program"
		echo "2 - Exit"
		read -p "Enter 1 or 2: " ch #accepting user input to run program or exit
		case $ch in
			1)
				echo "Do you want files and folders to be created?"
				read -p "Enter y for yes or any key for no: " yorn
				if [ "$yorn" = "y" ]
				then 
					case_func '-dum' #calls case_func and creates dummy files and folders
				fi
				echo "Do you want to list all current files and folders?"
				read -p "Enter y for yes or any key for no: " yorn
				if [ "$yorn" = "y" ]
				then
					echo -n "Current list of file and folders in : "
					echo "$PWD" | sed 's!.*/!!'
					ls -l
				fi
				read -p "Enter a name for the verification file: " fname
				ext=`echo $fname | grep ".txt"`
				if [ -n "$ext" ]
				then
					if  case_func '-c' "$fname"  #calls case_func to create a verification file and gives it a file name
					then
						echo "The program terminated due to bad input."
						exit 0
					fi
				else
					fname="$fname.txt"
					echo "The file name you entered does not have a valid text file extension."
					echo "This has been fixed for you: $fname"
					if  case_func '-c' "$fname" 
					then
						echo "The program terminated due to bad input."
						exit 0
					fi
				fi
				echo "Please make changes to your file system manually."
				read -p "Press any key and enter when you're done: " yorn
				if [ "$#" -ge 0 ]
				then
					if  case_func '-o' "$fname" 'output.txt'
					then
						echo "Program terminated due to bad input."
						exit 0
					fi
				fi
				;;
			2)
				#exit
				echo "Exiting program."
				exit 0
				;;
		esac
	done
else
	case_func "$@"
	while [ "$#" -ge 2 ]
	do
		shift
		shift
		case_func "$@"
	done
fi
