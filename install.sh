#!/bin/bash

#Baseball/Softball Statistical Recordkeeping System -- Linux Install Script -- George McGinn (06/07/2022)
#Version 1.0 -- June 7, 2022
#

### Library with all FUNCTIONS
. setupFunctions


##### Start of script

### Set color variables for echo commands
RED="\033[31m"
REDBOLD="\033[1;31m"
REDBG="\033[1;41m"
GREEN="\033[32m"
GREENBOLD="\033[1;32m"
BLUE="\033[34m"
YELLOW="\033[33m"
YELLOWBOLD="\033[1;33m"
RESET="\033[0m"


### Check to see if the user provided the help argument (--help or -h) as the first argument.
if [ $# == 1 ]; then
	if [ $@ == "--help" ]; then
		help
		exit 0
	elif [ $@ == "-h" ]; then
		help
		exit 0
	else
		echo -e "${REDBG}ERROR: Unknown single argument passed to install. Please fix and resubmit.$RESET"
		echo
		help
		exit 1
	fi
fi


### Display banner
clear
echo
echo -e "${YELLOWBOLD}+------------------------------------------------------------+$RESET"
echo -e "${YELLOWBOLD}| Baseball/Softball Statistical System Install Help - v1.0.0 |$RESET"
echo -e "${YELLOWBOLD}+------------------------------------------------------------+$RESET"
echo
echo "Starting installation of the Baseball/Softball Statistical Recordkeeping System..."
echo 


### Set the OS/Processor types (Fail if not Linux, as this is the Linux install script)
ostype
if [ $OS != "LINUX" ]; then
	echo -e "${REDBG}ERROR: Install must run on a Linux OS. Please fix and resubmit.$RESET"
	echo
	exit 1
fi


### Make sure we're not running as root (To be tested for future versions)
if [ $EUID == "0" ]; then
  echo -e "${REDBG}ERROR: You are trying to run this script as root. This is highly unrecommended. Script Terminated.$RESET"
  exit 1
fi


### Display the number of arguments passed and their values
echo "Number of arguments passed: $#"
echo "Arguments: $@"
echo


### If no compiler options are found, display error message, qb64 help and terminate
if [ $# == 0 ]; then												
	echo -e "${REDBG}ERROR: No arguments passed. Make sure you use one of the ones below. Script terminated.$RESET"
	echo
	help
	exit 1
fi


### Setup BOOL variables and parse out the arguments based on associated switches
option_s=False
option_d=False
option_b=False
option_q=False
option_r=False
delete_qb64=False
rdms="mysql"
qb64_dir=""

while getopts s:d:q:r:b option
	do
	case "${option}"
		in
		s) source_directory=${OPTARG} 
		   option_s=True;;
		d) destination_directory=${OPTARG}
		   option_d=True;;
		q) qb64_directory=${OPTARG}
		   option_q=True;;
		r) rdms=${OPTARG}
		   option_r=True;;
		b) option_b=True;;
        *) help                              		# If an unknown ARG is passed, display HELP and exit.
		   exit 0;;
	esac
done


### Validate the RDMS argument passed. If not either 'mysql' or 'mariadb', terminate script
if [ $rdms != "mariadb" ] && [ $rdms != "mysql" ]; then
	echo -e "${REDBG}ERROR: Invalid value for -r: $rdms. Must be either mariadb or mysql. Please fix and resubmit.$RESET"
	echo
	exit 1
fi


### Build the source and destination directories
if [ "$source_directory" == "" ]; then				# If source directory isn't provided, then set current working directory as source_directory   	
	source_directory="$PWD"
fi
if [ "$destination_directory" == "" ]; then			# If destination directory isn't provided, then set current working directory as destination_directory   	
	destination_directory="$PWD"
fi


### Set up bin and src and create destination directory if it does not exist
bin_directory=$source_directory"/bin"
src_directory=$source_directory"/src"
if [ -d "$destination_directory" ];
then
    echo "Destination Directory: $destination_directory already exists - deleting everything in it and recreating it..."
    echo
    rm -r $destination_directory
    mkdir $destination_directory
else
	echo "Destination Directory: $destination_directory directory does not exist. Creating it..."
	mkdir $destination_directory
	echo
fi


### Do not allow installation into the same directory as the source directory
if [ $source_directory == $destination_directory ]; then
	echo 
	echo -e "${REDBG}ERROR: destination directory cannot be the same as the source directory. Please fix and resubmit.$RESET"
	echo
	exit 1
fi


### Check for dependencies and install
echo "Software Dependencies"
echo "---------------------------------------------------"
# Check to make sure user isn't trying to install mariadb with mysql already installed and vise-versa.
if [ $option_r == True ]; then
	if [ $rdms == "mariadb" ]; then 
		if dpkg -l 'mysql-server' | grep mysql-server > /dev/null; then        # Check for mySQL if running on a Linux x86_64
			echo -e "${REDBG}ERROR: You already have a RDMS (mysql-server) installed. Install terminated.$RESET"
			abend
		fi
	elif [ $rdms == "mysql" ]; then
		if dpkg -l 'mariadb-server' | grep maraidb-server > /dev/null; then    # Check for mySQL if running on a Linux x86_64
			echo -e "${REDBG}ERROR: You already have a RDMS (mariadb-server) installed. Install terminated.$RESET"
			abend
		fi
	fi
fi

#Determine hardware setting, and check to see if the proper or selected RDMS needs to be installed
if $(cat /proc/cpuinfo | grep "Raspberry Pi" > /dev/null); then
	if dpkg -l 'mariadb-server' | grep mariadb-server > /dev/null; then        # Check for mariaDB if running on a Raspberry Pi
		echo -e "${GREENBOLD}mariaDB: Installed$RESET"
	else 
		echo -e "${REDBOLD}mariaDB: Not found. Will be Installed$RESET"
	fi
else
	if dpkg -l $rdms"-server" | grep $rdms"-server" > /dev/null; then          # Check for mySQL if running on a Linux x86_64
		echo -e "${GREENBOLD}$rdms: Installed$RESET"
	else 
		echo -e "${REDBOLD}$rdms: Not found. Will be Installed$RESET"
	fi
fi
if dpkg -l 'zenity' | grep zenity > /dev/null; then                       # Check for Zenity
	echo -e "${GREENBOLD}Zenity: Installed$RESET"
else 
	echo -e "${REDBOLD}Zenity: Not found. Will be Installed$RESET"
fi


### Install missing/required packages & dependencies
GET_WGET=
install_dependencies
echo


### Display installation directories
echo "Installation/Compile Directories"
echo "---------------------------------------------------"
echo "QB64 Compiler Directory: " $qb64_directory
echo "       Source Directory: " $source_directory
echo "  Destination Directory: " $destination_directory
echo "  Source Code Directory: " $src_directory
echo "      Include Directory: " $destination_directory"/include"
echo "  Binary File Directory: " $bin_directory
echo 


### If QB64 is not found, Install/Compile it
### First, determine if it is in the PATH variable.
### If not, then check for the existence of the provided directory
if [ $option_q == True ]; then
	if [ -d "$qb64_directory" ]; then
		qb64_dir=$qb64_directory"/"
		echo -e "${GREEN}QB64 directory exist. Using this location for compiler.$RESET"
		echo
	else
		delete_qb64=True
		echo -e "${RED}QB64 does not exist. QB64 will be installed/compiled as temporary file.$RESET"
		echo
		mkdir $qb64_directory
		cd $source_directory"/qb64"
		echo "Copying qb64 to $qb64_directory..."
		cp -r * $qb64_directory
		echo -e "${GREEN}QB64 copy sucessfull. Now installing QB64...$RESET"
		cd $qb64_directory
		install_qb64
		qb64_dir=$qb64_directory"/"
	fi
else
	if $(qb64 --help | grep 'QB64 Compiler' > /dev/null); then
		echo -e "${GREEN}QB64 was found in your PATH variable. Will use this for compiles.$RESET"
		qb64_directory=`which qb64 | xargs dirname`
		qb64_dir=$qb64_directory"/"
		echo
		delete_qb64=False
	else     											# QB64 not in PATH. Check for provided directory
		delete_qb64=True
		echo -e "${RED}QB64 cannot be found on your system. Please use the -q ARG to temporarily install it and rerun.$RESET"
		echo
		abend
	fi
fi


### Copy all files/directories needed for executing application
echo "Installing all files/directories required for execution..."
cd $source_directory
cp -r ./fonts $destination_directory"/fonts"
cp -r ./help $destination_directory"/help"
cp -r ./logs $destination_directory"/logs"
cp -r ./sql $destination_directory"/sql"
cp -r ./licenses $destination_directory"/licenses"
cp -r ./include $destination_directory"/include"
cp "baseballStats.png" $destination_directory
cp "baseballStats.ico" $destination_directory
cp "config.ini" $destination_directory
echo


### If install from binaries is selected, copy the binaries into the destination folder and quit
if [ $option_b == True ]; then
	echo "Installing from compiled binaries..." 
	echo
	cd $bin_directory
	cp -r * $destination_directory
	cd $destination_directory
	echo -e "${GREEN}System installed from pre-compiled Linux binary files. $RESET"
	echo
	echo "Baseball/Softball Statistical Recordkeeping System successfully installed."
	exit 0
fi


### If here, we're doing compiles. Copy the temorary files needed to compile application
### Copy source code to compile system
echo && echo "Copy temporary source code/forms files to compile programs..."
cd $src_directory
cp -r *.h $destination_directory
cp -r *.bas $destination_directory
cd $source_directory
echo


### Compile programs & strip ELF modules of symbols
cd $destination_directory
echo -e "${YELLOWBOLD}Compiling QB64/C++ Source Code$RESET"
echo -e "${YELLOWBOLD}---------------------------------------------------$RESET"
echo
echo -e "${YELLOWBOLD}Compiling program baseballConfig.bas...$RESET"
$qb64_dir"qb64" -x -o $destination_directory"/baseballConfig" $destination_directory"/baseballConfig.bas"
if [ $? != 0 ]; then    						  	   
	echo -e "${REDBG}ERROR: Program Program \"baseballConfig.bas\" did not compile successfully. Please fix and retry.$RESET"
	echo "Output of compilelog.txt (incase there is a c++ error detected)"
	echo & echo "---------------------------------------------------------------"
	cat $qb64_directory"/internal/temp/compilelog.txt"
	echo
	abend
else
	strip baseballConfig
	echo -e "${GREEN}Program \"baseballConfig.bas\" compiled successfully.$RESET"
	echo " "
fi

echo -e "${YELLOWBOLD}Compiling program baseballStats.bas...$RESET"
$qb64_dir"qb64" -x -o $destination_directory"/baseballStats" $destination_directory"/baseballStats.bas"
if [ $? != 0 ]; then    						  	   
	echo -e "${REDBG}ERROR: Program Program \"baseballStats.bas\" did not compile successfully. Please fix and retry.$RESET"
	echo " "
	abend
else
	strip baseballStats
	echo -e "${GREEN}Program \"baseballStats.bas\" compiled successfully.$RESET"
	echo " "
fi

echo -e "${YELLOWBOLD}Compiling program battingStats.bas...$RESET"
$qb64_dir"qb64" -x -o $destination_directory"/battingStats" $destination_directory"/battingStats.bas" 
if [ $? != 0 ]; then    						  	   
	echo -e "${REDBG}ERROR: Program Program \"battingStats.bas\" did not compile successfully. Please fix and retry.$RESET"
	echo " "
	abend
else
	strip battingStats
	echo -e "${GREEN}Program \"battingStats.bas\" compiled successfully.$RESET"
	echo " "
fi

echo -e "${YELLOWBOLD}Compiling program pitchingStats.bas...$RESET"
$qb64_dir"qb64" -x -o $destination_directory"/pitchingStats" $destination_directory"/pitchingStats.bas" 
if [ $? != 0 ]; then    						  	   
	echo -e "${REDBG}ERROR: Program Program \"pitchingStats.bas\" did not compile successfully. Please fix and retry.$RESET"
	echo " "
	abend
else
	strip pitchingStats
	echo -e "${GREEN}Program \"pitchingStats.bas\" compiled successfully.$RESET"
	echo " "
fi

echo -e "${YELLOWBOLD}Compiling program leagueStats.bas...$RESET"
$qb64_dir"qb64" -x -o $destination_directory"/leagueStats" $destination_directory"/leagueStats.bas" 
if [ $? != 0 ]; then    						  	   
	echo -e "${REDBG}ERROR: Program Program \"leagueStats\" did not compile successfully. Please fix and retry.$RESET"
	echo " "
	abend
else
	strip leagueStats
	echo -e "${GREEN}Program \"leagueStats\" compiled successfully.$RESET"
	echo " "
fi


### Adding baseballStats menu/desktop entry
#echo "Adding BaseballStats menu entry..."
#cat > ~/.local/share/applications/BaseballStats.desktop <<EOF
#[Desktop Entry]
#Name=Baseball/Softball Recordkeeping System
#GenericName=Baseball/Softball Statistical Analysis System
#Comment=Store, track and use baseball/softball game statistics for any number of teams or league
#Exec=$destination_directory/baseballStats
#Icon=$$destination_directory/baseballStats.ico
#Terminal=false
#Type=Application
#Categories=Education;Sports;Database;DataVisualization;NumericalAnalysis;
#Keywords=Baseball;Softball;Statistics;Analytics;Sabrmetrics;
#Path=$$destination_directory
#StartupNotify=false
#EOF
#echo -e "${GREEN}Desktop menu entry for BaseballStats added sucessfully."
#echo

### Delete source code and temporary directories from binary (destination) directory and exit
rm *.bas
rm *.h
rm -r ./include


### If QB64 created temporarilly, then delete it
if [ $delete_qb64 == True ]; then
	echo "Deleting QB64 directories and files from destination..." 
	rm -r $qb64_directory
	echo -e "${GREEN}QB64 sucessfully removed from destination directory$RESET"
	echo
fi

echo -e "${GREEN}Temporary files deleted$RESET"
echo
echo -e "${GREENBOLD}Baseball/Softball Statistical Recordkeeping System successfully installed.$RESET"
exit 0
