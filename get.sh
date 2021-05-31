#!/usr/bin/env bash
#
#           File Downloader Script
#
#   GitHub: https://github.com/IslamAlam/sar-introduction
#   Issues: https://github.com/IslamAlam/sar-introduction/issues
#   Requires: bash, mv, rm, tr, type, grep, sed, curl/wget, tar (or unzip on OSX and Windows)
#
#   This script download files required for the SAR-Intro Training.
#   Usage:
#
#       $ curl -fsSL https://raw.githubusercontent.com/IslamAlam/sar-introduction/main/get.sh | bash
#   	  or
#   	$ wget -qO- https://raw.githubusercontent.com/IslamAlam/sar-introduction/main/get.sh | bash
#   
#
wget_file()
{
	wget -nc -q -P $1 $2 2>&1 >/dev/null
}

wget_file_override()
{
	wget -q -P $1 $2 2>&1 >/dev/null
}

download_files()
{
	#trap 'echo -e "Aborted, error $? in command: $BASH_COMMAND"; trap ERR; return 1' ERR
	filemanager_os="unsupported"
	filemanager_arch="unknown"
	main_path="/projects"
	
	DATA_FOLDER=/projects/data
	mkdir -p $DATA_FOLDER
	# pip install gdown >/dev/null
	
	cd $main_path
	
	
	#########################
	# Download IPython Book #
	#########################
	
	# For IPython Intro
	if [[ ! -d $main_path/cookbook-2nd-code ]]; then
		echo "Downloading Intro Book for IPython "Cookbook" "
		git clone https://github.com/ipython-books/cookbook-2nd-code.git
	fi
	########################
	# Download and extract #
	########################
    	#echo "Downloading File Browser for $filemanager_os/$filemanager_arch..."
	echo "Downloading Files"
	
	# For src ste_io
	wget_file $main_path/src https://raw.githubusercontent.com/IslamAlam/sar-introduction/main/src/ste_io.py
	
	# For SAR notebooks
	wget_file $main_path https://raw.githubusercontent.com/IslamAlam/sar-introduction/main/notebooks/2021_05_31_Lecture_1.1.ipynb
	wget_file $main_path https://raw.githubusercontent.com/IslamAlam/sar-introduction/main/notebooks/2021_05_31_Lecture_1.2.ipynb
	
	# For SAR DATA_FOLDER
	mkdir -p $DATA_FOLDER/01-sar
	wget_file $DATA_FOLDER/01-sar https://raw.githubusercontent.com/IslamAlam/sar-introduction/main/data/01-sar/signal1_rc.npy
	wget_file $DATA_FOLDER/01-sar https://raw.githubusercontent.com/IslamAlam/sar-introduction/main/data/01-sar/signal2_rc.npy

	# For Reading RAT Files
	wget_file $main_path https://raw.githubusercontent.com/IslamAlam/sar-introduction/main/notebooks/00-read-rat-file.ipynb

	# For PolSAR
	if [[ ! -d $DATA_FOLDER/02-polsar ]]; then
		gdown https://drive.google.com/uc?id=1-DRvyHlPUh0Z1C2246I12O45hO47TXnm
		unzip -j polsar.zip -d $DATA_FOLDER/02-polsar
		rm polsar.zip
	fi

	return 1
	# For TomoSAR
	if [[ ! -d $DATA_FOLDER/05-tomosar ]]; then
		gdown https://drive.google.com/uc?id=1RTX4_Q5H_64js6NzRQYFet0YStADD8Yk
		unzip -j tomosar.zip -d $DATA_FOLDER/05-tomosar
		rm tomosar.zip
	fi
	

	
	# For InSAR
	if [[ ! -d $DATA_FOLDER/02-polsar ]]; then
		gdown https://drive.google.com/uc?id=1-DRvyHlPUh0Z1C2246I12O45hO47TXnm
		unzip -j polsar.zip -d $DATA_FOLDER/03-polsar
		rm polsar.zip
	fi
	
	# For Pol-InSAR
	if [[ ! -d $DATA_FOLDER/02-polsar ]]; then
		gdown https://drive.google.com/uc?id=1-DRvyHlPUh0Z1C2246I12O45hO47TXnm
		unzip -j polsar.zip -d $DATA_FOLDER/03-polsar
		rm polsar.zip
	fi


}
download_files

echo $'\n\n\n#######################\nMade with ❤️  in Munich! \nIn case of any issue with the data and notebooks contact: \n\tIslam Mansour (polinsar@imansour.net)'
echo $'\nEnjoy your Training 🥳 😊\n'
