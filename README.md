"# Host-based-IDS" 
# Tasks To Be Done
## Allow user to specify a folder to be verified. 
### What it does:
### How it works:
## If none specified, 1.~~create a dummy folder with files in it~~
### What it does:
For testing purposes, if the user wishes to create dummy files and directories they can enter the argument '-dum' when running the program.
### How it works:
When this argument is picked up by the case loop, it then goes through a for loop (iterating through numbers 1 to 3) and checks if these files and directories already exist and if not directories and files are created named dir1..3 and file1..3 respectively.
## 2.~~Create Verification File~~
### To Do:
- check if a user has entered a file name appended with .txt (if not add it)
- encrypt verification file
- check if user entered in a filename after the -c argument
### What it does:
When a user enters the -c argument into the commandline followed by a filename, a file is created with the given name and saved as a plain text file and then stores information (including full path, permissions, type, owner, group, size, last modified data, and file name) for all files and directories in the current directory (or given directory) and computes checksums against all files which is also saved to the verification file to later be checked against.
### How it works:
Using a for loop to iterate over all the given arguments, the program then uses cases to check if it can find an argument matching '-c'. If it does it then prints to the screen "Create verification file" then it uses the shift command to reset the counter for the arguments list so then the file name can be retrieved as if it was the first argument. The program then checks if the file exists using the -f tag followed by the file name (denoted by $1). If it finds the file already exists, then that file gets removed. After that the file gets created, the file name is appended to the global variable 'VER' which holds the current path.

In order to populate the verification file, a recursive function is used. In this recursive function, a for loop is used to iterate through every file and directory. It then uses if statements and the commands '-d' and '-f' to check if the object found in the iteration is a directory or a file. To write to the verification file, the echo command is used (along with the '-n' argument appended to ensure details for each file or directory are written only on one line) allow with the '>>' symbol pointing to the global variable which gives it the path to the verification file to write to, which is important especially when looping through sub directories.

If it is a directory then the path to that directory is written to the file along with the details given by the 'ls -ld' command. As we also want to go through any sub directories, the change directory command is used to go into the directory found and this recursive function is called again to iterate over the everything found inside any sub directories. To get back out, the change directory command followed by '..' is run. If it is a file then the path to that file is written to the verification file along with the details associated given the same way as as if the object was a directory. 

### To Do
The verification file needs to be able to check itself as the last action it undertakes. Its data will be saved with the execption of the md5sum.

## Encrypt verification file
### What it does:
### How it works:
## 3.~~Calculate check sums on all regular files~~
### What it does:
In the recursive function (called when a user enters the argument to create a verification file). When the function finds a file, it calculates a MD5 checksum to be written to the verification file to later assist in checking if any changes have been made to the file.
### How it works:
The checksum is calculated using the 'md5sum' command and the resulting checksum is retrieved using the 'awk' command to save only the check sum itself to a variable to then be written to the verification file. 
## 8.~~Compare verification file to current directory to produce output:~~
### What it does:
When the user specifies -o to check the current directory against the verification file the program reports any discrepencies (either to a specified file or printed to console).
### How it works:
In order to do the checks a temporary file populated the same way the verification file was. This tempoary file is then passed to a function to check against the verification file. First a second temporary file is created to hold results of the checks. Then reading each line of the verification file, using grep we count the number of times that line appears in our temporary file. If the count returns 0 then that line was not found so it is written to the second temporary file and appended with '-d' indicating that it exists in the verification file however cannot be found in the new detail file therefore must of been deleted or modified. We then repeat the process except reading the temporary file and checking for matching lines in the verification file. We then append to the second temporary file any that don't match and append with '-a' as the line is either an object added or modified. 

After this we need to separate added, modified, and deleted objects. We do this using three different variables 'MODIFIED', 'ADD', and 'DEL', these variables hold the names of the files that have been modified, added or deleted respectively. To populate 'MODIFIED' we use pipes to join multiple commands which produce the string of file names. The first command sorts our temporary file to put similar lines close together. The second command uses 'awk' to retrieve only the file name from the line (by printing the value at position 10). The second and third command 'uniq' displays only the lines that are repeated and only displays them once. The combination of these commands produces a string with file names that have been repeated in the file. If these file names have been repeated it means they must exist in both the temporary file and the verification file which indicates they have been modified but not added or deleted.

Next the added and deleted variables need to be populated. To do this we read through each line of the second temporary file, similar to how the other two files were read. This time using 'awk' the program checks for the file name and makes sure it is not repeated in the file (otherwise it would already exist in our 'MODIFIED' variable). If the file name only appears once, then using 'awk' again the last value in the line is checked to see if it is an '-a' or '-d'. If it is an '-a' then the file name gets appended to the 'ADD' variable and if it is a '-d' then it gets appended to the 'DEL' variable.

Once these variables are populated they then need to either be written to the console or to a output file. If the user specified an output file, it would of been passed to the program as a parameter, if not only the temporary file and verification files would of been passed. Therefore to check if an output file is specified, the number of parameters entered is checked, and if greater than two, then the output is written to the specified file, otherwise it prints to the console.
## Print out specific information regarding change
### What it does:
### How it works:
## 7.~~Write output to a file~~
### What it does:
Once a verification file has been created, the user has the ability to run the script again with the '-o' argument. The script will then check each of the files in the directory for any additions, deletions or modifications to the files within and then display them to the user. This is displayed through the terminal and optionally to an output file specifed by the user.
### How it works:
Before entering the function which checks the current file system against the verification file, first there is a check to see if the user has entered the argument based on the number after '-o' has been entered. If the argument is greater than 1 then the user has specified an output file name and that will be passed to the function. Otherwise nothing will be passed to the function. Then once we've entered the check function, there is a check to see if the number of parameters is greater than 0. If so then write the outputs to the file specified. File provided or not, the results of the script will be displayed to the console displaying the additions, deletions and modifications made to the files.
## 4.~~Determine if directory, don't calculate checksums for directories~~
### What it does:
If a directory is found, it is not possible to calculate a checksum for it therefore this step will need to be skipped.
### How it works:
This is done by using if statements to firstly check if an object found is a directory and if not, if it is a file. The checksum will only be calculated if it is a file.
## Put code in functions
### What it does:
### How it works:
### dir_loop
Loops through main directory and any subdirectories adding any objects found to the file provided for it's argument. It will not add any files that share the same name as the passed file name(s).
### check_files_loop
Loops through its provided files and compares the differences between them, duplicates names with different permissions size, md5 sum etc, are declared as modifications. Files missing from the verification file yet present in the validation file are declared as additions and the reverse is seen as deletions. These are then catagorized and displayed to the user and optionally saved into a requested file.
### output
Takes the data provided from check_files_loop, saves it to a file and displays it to the terminal.
### case_func
Interprets the entered arguments to determine which function to perform
### main
Handles user interaction should they not have entered any arguments or entered incorrect ones

## 5.~~Add ability to iterate through directories without creating duplicate verification files in each directory~~
### What it does:
During verification file creation, we want to write the details of not only everything in the current or given directory but also any sub directories. The difficulty faced here is that once we start entering the sub directories, we still need to ensure we can write to the one verification file initally created.
### How it works:
When the user enters the argument -c followed by the filename, the filename gets appended to a global variable which holds the path to the current directory. This global variable is then used in the recursive function so whenever details of a file or directory are retrieved they can then be written using the '>>' command followed by the global variable in order to write the output of the echo statement to the file found at the specific path. 
## 6.~~Directories' paths added to verification file~~
### What it does:
As we also need details for all directories and sub directories, we need to also record where these sub directories are, hence why we need to save the full path.
### How it works:
In the function used to populate the verification file, when the if statement picsk up that it is a directory, then it uses the 'pwd' command to retrieve the path and it is written to the file.
## 9.~~Change the file types written to verification file to string instead of number~~
### What it does:
By default when using the 'ls -l' command to retrieve details on the objects in a directory, the type is specified by a number with 1 being a file, 2 being a directory and links to files still be specified as 1. The program replaces these numeric values with string specifiying File, Directory and Symbolic Links.
### How it works:
In the function used to populate the verification file, looping through all the directories, 'ls -l' is used in conjunction with 'sed' to find the first instance of either 1 or 2 (depending on whether the object in that iteration is a file or directory) and replacing it with the corresponding text (i.e. 1 replaced by File and 2 replaced by Directory). If the object in iteration is a file, then an additional check is performed with the use of 'awk' to determine if the line returned by 'ls -l' starts with an l and if so it is a symbolic link therefore the 1 is replaced by the text 'Symbolic Link'.


## NON-FUNCTIONAL REQUIREMENT: List files and directories in the order that they were changed (compare times) accessed
### Catch errors and display appropriate error mesage. Allow user to try again
### Allow user to navigate through programs functionalities
