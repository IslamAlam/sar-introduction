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

gdown_file()
{
	# cd 
	gdown https://drive.google.com/uc?id=$2 -O $1 2>&1 >/dev/null
}

gdown_file_override()
{
	# cd 
	rm $1 2> /dev/null || true
	gdown https://drive.google.com/uc?id=$2 -O $1 2>&1 >/dev/null
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

	# For SAR 1st week Solution
	wget_file $main_path/notebook-solution https://raw.githubusercontent.com/IslamAlam/sar-introduction/main/notebook-solution/2021_05_31_Lecture_1.2.1st.ipynb
	wget_file $main_path/notebook-solution https://raw.githubusercontent.com/IslamAlam/sar-introduction/main/notebook-solution/2021_05_31_Lecture_1.2.2nd.ipynb

	# For SAR 2nd week
	wget_file $main_path https://raw.githubusercontent.com/IslamAlam/sar-introduction/main/notebooks/2021_06_07_Lecture_2.1.ipynb
	wget_file $main_path https://raw.githubusercontent.com/IslamAlam/sar-introduction/main/notebooks/2021_06_07_Lecture_2.2.ipynb
	wget_file $DATA_FOLDER/01-sar https://raw.githubusercontent.com/IslamAlam/sar-introduction/main/data/01-sar/signal1_ac.npy
	wget_file $DATA_FOLDER/01-sar https://raw.githubusercontent.com/IslamAlam/sar-introduction/main/data/01-sar/signal2_ac.npy

	# For SAR 2nd week Solution
	wget_file $main_path/notebook-solution https://raw.githubusercontent.com/IslamAlam/sar-introduction/main/notebook-solution/2021_06_07_Lecture_2.2_update.ipynb

	# For PolSAR 3rd Week
	wget_file $main_path https://raw.githubusercontent.com/IslamAlam/sar-introduction/main/notebooks/2021_06_14_Lecture_3.1.ipynb
	wget_file $main_path https://raw.githubusercontent.com/IslamAlam/sar-introduction/main/notebooks/2021_06_14_Lecture_3.2.ipynb
	wget_file $main_path https://raw.githubusercontent.com/IslamAlam/sar-introduction/main/notebooks/2021_06_14_Lecture_3.3.ipynb
	
	# Slides
	wget_file $main_path/slides https://raw.githubusercontent.com/IslamAlam/sar-introduction/main/lectures/MAAP-KP-2021-01-SARIntro-Part1.pdf
	wget_file $main_path/slides https://raw.githubusercontent.com/IslamAlam/sar-introduction/main/lectures/MAAP-KP-2021-02-SARIntro-Part2.pdf
	wget_file $main_path/slides https://raw.githubusercontent.com/IslamAlam/sar-introduction/main/lectures/MAAP-KP-2021-03-PolSAR-Part1-v2.pdf

	# Raw data SAR
	if [[ ! -f $DATA_FOLDER/01-sar/raw-img.rat ]]; then
		echo "01-sar: raw-data downloading"
		gdown_file $DATA_FOLDER/01-sar/raw-img.rat 1Fue1i8IxZC3tKbg-Ax9q8B413Ggm832n
	fi
	# For Reading RAT Files
	wget_file $main_path https://raw.githubusercontent.com/IslamAlam/sar-introduction/main/notebooks/00-read-rat-file.ipynb

	# For PolSAR
	if [[ ! -f $DATA_FOLDER/02-polsar/slc_16afrisr0107_Phh_tcal_test.rat ]]; then
		echo "Downloading P-Band into: $DATA_FOLDER/02-polsar/"
		# echo "Remove old dir and download new dataset"
		# rm -r $DATA_FOLDER/02-polsar
		gdown https://drive.google.com/uc?id=1nWkhr0tg3G69kiPzGI5YLIuAVT28r8BI

		unzip -j polsar-P-band.zip -d $DATA_FOLDER/02-polsar
		rm polsar-P-band.zip
	fi
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

echo $'\n\n\n#######################\nMade with ❤️  in Munich! \nIn case of any issue with the data and notebooks contact: \n\t polinsar@imansour.net'
echo $'\nEnjoy your Training 🥳 😊\n'
