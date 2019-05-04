"# Host-based-IDS" 
# Tasks To Be Done
## Write argument to point to Folder to be verified, if none specified, 1.~~create a dummy folder with files in it~~
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

## Encrypt verification file
### What it does:
### How it works:
## Create directory to be checked against verification file
### What it does:
### How it works:
## 3.~~Calculate check sums on all regular files~~
### What it does:
In the recursive function (called when a user enters the argument to create a verification file). When the function finds a file, it calculates a MD5 checksum to be written to the verification file to later assist in checking if any changes have been made to the file.
### How it works:
The checksum is calculated using the 'md5sum' command and the resulting checksum is retrieved using the 'awk' command to save only the check sum itself to a variable to then be written to the verification file. 
## Compare file to directory:
### To Do: ignore t.txt when checking for adiions, deletions and modifications.
### What it does:
### How it works:
## Print out specific information regarding change
### What it does:
### How it works:
## Write output to a file
### What it does:
### How it works:
## 4.~~Determine if directory, don't calculate checksums for directories~~
### What it does:
If a directory is found, it is not possible to calculate a checksum for it therefore this step will need to be skipped.
### How it works:
This is done by using if statements to firstly check if an object found is a directory and if not, if it is a file. The checksum will only be calculated if it is a file.
## Put code in functions
### What it does:
### How it works:
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

## NON-FUNCTIONAL REQUIREMENT: List files and directories in the order that they were changed (compare times) accessed
