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
	wget_file $main_path/src https://raw.githubusercontent.com/IslamAlam/sar-introduction/main/src/maap-s3.py
	
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
	
	# For PolSAR 4th Week
	wget_file $main_path https://raw.githubusercontent.com/IslamAlam/sar-introduction/main/notebooks/2021_06_21_Lecture_4.1.ipynb

	# For InSAR 5th Week
	wget_file $main_path https://raw.githubusercontent.com/IslamAlam/sar-introduction/main/notebooks/2021_06_28_Lecture_5.ipynb

	# For InSAR 6th Week
	wget_file $main_path https://raw.githubusercontent.com/IslamAlam/sar-introduction/main/notebooks/2021_07_05_Lecture_6.ipynb

	# For PolInSAR 7th Week
	wget_file $main_path https://raw.githubusercontent.com/IslamAlam/sar-introduction/main/notebooks/2021_11_22_Lecture_7.ipynb
	
	# For PolInSAR 8th Week
	wget_file $main_path https://raw.githubusercontent.com/IslamAlam/sar-introduction/main/notebooks/2021_11_29_Lecture_8.ipynb
	
	# For TomoSAR 9th Week
	wget_file $main_path https://raw.githubusercontent.com/IslamAlam/sar-introduction/main/notebooks/2021_12_06_Lecture_9.ipynb
	
	# For TomoSAR 10th Week
	wget_file $main_path https://raw.githubusercontent.com/IslamAlam/sar-introduction/main/notebooks/2021_12_12_Lecture_10.ipynb

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

	# Data for 5th Week
	if [[ ! -d $DATA_FOLDER/03-insar ]]; then
		mkdir -p $DATA_FOLDER/03-insar
		cd $DATA_FOLDER/03-insar
		gdown https://drive.google.com/uc?id=1OAf1obJRRld6fS_K5JDJGu5AjGMyVuaa
		gdown https://drive.google.com/uc?id=1rZUxpjE04m3XHXTLCJHxxFgsUt9NW1If
		cd $main_path

	fi

	# Data for 6th Week
	if [[ ! -f $DATA_FOLDER/03-insar/flat_earth_Mondah_S_2015_11_11_cut.rat ]]; then
		mkdir -p $DATA_FOLDER/03-insar
		cd $DATA_FOLDER/03-insar
		# gdown https://drive.google.com/uc?id=
		gdown https://drive.google.com/uc?id=1rBg6AwSUYUrnyXI-I0r6ZyAwJg5K52ua
		gdown https://drive.google.com/uc?id=1gUvBLOFCu9Ctw5cYqOruZPXtKoMovJqW
		gdown https://drive.google.com/uc?id=1khRB9MA1__x1nudr4kqt1vgZKEvb5Wu_
	fi

	if [[ ! -f $DATA_FOLDER/03-insar/RH100_Mondah_S_2015_11_11_cut.rat ]]; then
		mkdir -p $DATA_FOLDER/03-insar
		cd $DATA_FOLDER/03-insar
		gdown https://drive.google.com/uc?id=1T1tTWRR_zPhj9JZxKnLTZvp43ocqsJGW

	fi
 
    #### Data for 7th Week
	# if [[ ! -f $DATA_FOLDER/04-polinsar/slc_15tmpsar0302_Lhh_t01.rat ]]; then
		
		mkdir -p $DATA_FOLDER/04-polinsar
		# cd $DATA_FOLDER/04-polinsar
		# gdown https://drive.google.com/uc?id=1muO7YkEpwN0JOlzXq4qk3byLQBQj2vgh
		# incidence_15tmpsar0302_L_t01.rat
		# gdown https://drive.google.com/uc?id=1pC6Q10QSrN1NtSKq-WSRSPhanAFUupbU
		# # kz_2d_demc_15tmpsar0302_15tmpsar0303_t01.rat
		# gdown https://drive.google.com/uc?id=1DyPFk11Py2dbfZuBXLJF4q0cow7Itup5
		# gdown https://drive.google.com/uc?id=1O9sKsXMmnB3NOxZTZLj_6EckXlypNYLb
		# gdown https://drive.google.com/uc?id=1r0b3w8xoDuLp7JyIAHwECeuahLRUvW2L
		# gdown https://drive.google.com/uc?id=12SbjmOLZdr_JuPlMRZ0iJvgGnPiOGpHK
		# gdown https://drive.google.com/uc?id=1Cizvg32T0VTaEz3pHKn7hOrvEKdZEEMr
		# gdown https://drive.google.com/uc?id=1h_NUJ6wosAX8aYRVjAllSMwPA84J1mjt
		# gdown https://drive.google.com/uc?id=1WCtsS6kNw4H364s9fpEgyS6l1-l3mKPx
		# gdown https://drive.google.com/uc?id=1VUnYTiq2qzsCXcYJfvJt9eH7tAO6UAHl
		# gdown https://drive.google.com/uc?id=1oQVtUc5w1PsAhNRtlakjGLok3rz0K9WT
		# gdown https://drive.google.com/uc?id=1TRbuwkO7Pzm_lYFIXNS1uyZusD4ks4f1
		# gdown https://drive.google.com/uc?id=18Kx8gbpB9BM5dsrxjuZsH2G0l7WmznrL
		# gdown https://drive.google.com/uc?id=15h0NhqVP_bFRSUJfQfL3y1VtH4WmuVZE
		

        myFiles=(
			"incidence_15tmpsar0302_L_t01.rat"
			"kz_2d_demc_15tmpsar0302_15tmpsar0303_t01.rat"
			"Lida_r1503.rat"
			"local_slope_15tmpsar0302_L_t01.rat"
			"pha_flat_15tmpsar0302_15tmpsar0303_Lhh_t01.rat"
			"slc_15tmpsar0302_Lhh_t01.rat"
			"slc_15tmpsar0302_Lhv_t01.rat"
			"slc_15tmpsar0302_Lvh_t01.rat"
			"slc_15tmpsar0302_Lvv_t01.rat"
			"slc_coreg_15tmpsar0302_15tmpsar0303_Lhh_t01.rat"
			"slc_coreg_15tmpsar0302_15tmpsar0303_Lhv_t01.rat"
			"slc_coreg_15tmpsar0302_15tmpsar0303_Lvh_t01.rat"
			"slc_coreg_15tmpsar0302_15tmpsar0303_Lvv_t01.rat"
			)
			
        gDriveURLs=(
			"1pC6Q10QSrN1NtSKq-WSRSPhanAFUupbU"
			"1DyPFk11Py2dbfZuBXLJF4q0cow7Itup5"
			"1O9sKsXMmnB3NOxZTZLj_6EckXlypNYLb"
			"1r0b3w8xoDuLp7JyIAHwECeuahLRUvW2L"
			"12SbjmOLZdr_JuPlMRZ0iJvgGnPiOGpHK"
			"1Cizvg32T0VTaEz3pHKn7hOrvEKdZEEMr"
			"1h_NUJ6wosAX8aYRVjAllSMwPA84J1mjt"
			"1WCtsS6kNw4H364s9fpEgyS6l1-l3mKPx"
			"1VUnYTiq2qzsCXcYJfvJt9eH7tAO6UAHl"
			"1oQVtUc5w1PsAhNRtlakjGLok3rz0K9WT"
			"1TRbuwkO7Pzm_lYFIXNS1uyZusD4ks4f1"
			"18Kx8gbpB9BM5dsrxjuZsH2G0l7WmznrL"
			"15h0NhqVP_bFRSUJfQfL3y1VtH4WmuVZE"
        )
			
		for index in ${!myFiles[*]}; do
			echo ${myFiles[$index]} 
			file=${myFiles[$index]}
			fileID=${gDriveURLs[$index]}
		    if [[ ! -f $DATA_FOLDER/04-polinsar/$file ]]; then
		        cd $DATA_FOLDER/04-polinsar
				gdown https://drive.google.com/uc?id=$fileID
				cd $main_path
			fi
			# Download from S3 if GDrive fails
		    if [[ ! -f $DATA_FOLDER/04-polinsar/$file ]]; then
                echo "GDrive failed to download, switch to S3"
				wget -O $DATA_FOLDER/04-polinsar/$file --no-check-certificate --no-proxy https://dlrpolinsar.s3.eu-west-3.amazonaws.com/$file
			fi
		done
		# wget -O $FILENAME --no-check-certificate --no-proxy https://dlrpolinsar.s3.eu-west-3.amazonaws.com/$FILENAME
		# wget -O $FILENAME --no-check-certificate --no-proxy https://dlrpolinsar.s3.eu-west-3.amazonaws.com/$FILENAME
		# wget --no-check-certificate --no-proxy https://dlrpolinsar.s3.eu-west-3.amazonaws.com/slc_coreg_15tmpsar0302_15tmpsar0303_Lvv_t01.rat
		# wget --no-check-certificate --no-proxy https://dlrpolinsar.s3.eu-west-3.amazonaws.com/slc_coreg_15tmpsar0302_15tmpsar0303_Lvv_t01.rat
		# wget --no-check-certificate --no-proxy https://dlrpolinsar.s3.eu-west-3.amazonaws.com/slc_coreg_15tmpsar0302_15tmpsar0303_Lvv_t01.rat
		# wget --no-check-certificate --no-proxy https://dlrpolinsar.s3.eu-west-3.amazonaws.com/slc_coreg_15tmpsar0302_15tmpsar0303_Lvv_t01.rat
		# wget --no-check-certificate --no-proxy https://dlrpolinsar.s3.eu-west-3.amazonaws.com/slc_coreg_15tmpsar0302_15tmpsar0303_Lvv_t01.rat
		# wget --no-check-certificate --no-proxy https://dlrpolinsar.s3.eu-west-3.amazonaws.com/slc_coreg_15tmpsar0302_15tmpsar0303_Lvv_t01.rat
		# wget --no-check-certificate --no-proxy https://dlrpolinsar.s3.eu-west-3.amazonaws.com/slc_coreg_15tmpsar0302_15tmpsar0303_Lvv_t01.rat
		# wget --no-check-certificate --no-proxy https://dlrpolinsar.s3.eu-west-3.amazonaws.com/slc_coreg_15tmpsar0302_15tmpsar0303_Lvv_t01.rat
		# wget --no-check-certificate --no-proxy https://dlrpolinsar.s3.eu-west-3.amazonaws.com/slc_coreg_15tmpsar0302_15tmpsar0303_Lvv_t01.rat
		# wget --no-check-certificate --no-proxy https://dlrpolinsar.s3.eu-west-3.amazonaws.com/slc_coreg_15tmpsar0302_15tmpsar0303_Lvv_t01.rat
		# wget --no-check-certificate --no-proxy https://dlrpolinsar.s3.eu-west-3.amazonaws.com/slc_coreg_15tmpsar0302_15tmpsar0303_Lvv_t01.rat
		# wget --no-check-certificate --no-proxy https://dlrpolinsar.s3.eu-west-3.amazonaws.com/slc_coreg_15tmpsar0302_15tmpsar0303_Lvv_t01.rat
		# wget --no-check-certificate --no-proxy https://dlrpolinsar.s3.eu-west-3.amazonaws.com/slc_coreg_15tmpsar0302_15tmpsar0303_Lvv_t01.rat
		# wget --no-check-certificate --no-proxy https://dlrpolinsar.s3.eu-west-3.amazonaws.com/slc_coreg_15tmpsar0302_15tmpsar0303_Lvv_t01.rat
		
		# unzip -j polinsar.zip -d $DATA_FOLDER/04-polinsar
		# rm polsar.zip
		cd $main_path
	# fi
	
	# For TomoSAR 9th Week
	mkdir -p $DATA_FOLDER/05-tomosar
	
	wget_file $DATA_FOLDER/05-tomosar https://raw.githubusercontent.com/IslamAlam/sar-introduction/main/data/05-tomosar/pos_scatters_ground.npy
	wget_file $DATA_FOLDER/05-tomosar https://raw.githubusercontent.com/IslamAlam/sar-introduction/main/data/05-tomosar/pos_scatters_layer1.npy

	# From TomoSAR 10th Week
	# https://drive.google.com/file/d/1X6gNq7SkyuVbKiY1aKLMKngvYFBb0tDL/view?usp=sharing
	# For TomoSAR
	if [[ ! -f $DATA_FOLDER/05-tomosar/dem.rat ]]; then
		gdown https://drive.google.com/uc?id=1X6gNq7SkyuVbKiY1aKLMKngvYFBb0tDL
		
		if [[ ! -f 05-tomosar.zip ]]; then 
			echo " Please enter your login details for the MAAP to download the data"
			python $main_path/src/maap-s3.py refresh
			python $main_path/src/maap-s3.py download maap-scientific-data/shared/polinsar-data/05-tomosar.zip /projects/05-tomosar.zip
			# python maap-s3.py upload /projects/05-tomosar.zip maap-scientific-data/shared/polinsar-data/05-tomosar.zip
		fi
		unzip -j 05-tomosar.zip -d $DATA_FOLDER/05-tomosar
		rm 05-tomosar.zip
	fi

	rm -r /projects/.Trash-0/* > /dev/null 2>&1
	rm -r /tmp/* > /dev/null 2>&1
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

download_us_files()
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
	wget_file $main_path/src https://raw.githubusercontent.com/IslamAlam/sar-introduction/main/src/maap-s3.py
	
	# For SAR notebooks
	wget_file $main_path https://raw.githubusercontent.com/IslamAlam/sar-introduction/main/notebooks-us/2021_09_27_Lecture1_SAR_Part1.ipynb
	
	# wget_file $main_path https://raw.githubusercontent.com/IslamAlam/sar-introduction/main/notebooks/2021_05_31_Lecture_1.2.ipynb
	
	# For SAR DATA_FOLDER
	mkdir -p $DATA_FOLDER/01-sar
	wget_file $DATA_FOLDER/01-sar https://raw.githubusercontent.com/IslamAlam/sar-introduction/main/data/01-sar/signal1_rc.npy
	wget_file $DATA_FOLDER/01-sar https://raw.githubusercontent.com/IslamAlam/sar-introduction/main/data/01-sar/signal2_rc.npy

	# For SAR 1st week Solution
	# wget_file $main_path/notebook-solution https://raw.githubusercontent.com/IslamAlam/sar-introduction/main/notebook-solution/2021_05_31_Lecture_1.2.1st.ipynb
	# wget_file $main_path/notebook-solution https://raw.githubusercontent.com/IslamAlam/sar-introduction/main/notebook-solution/2021_05_31_Lecture_1.2.2nd.ipynb

	# For SAR 2nd week
	wget_file $main_path https://raw.githubusercontent.com/IslamAlam/sar-introduction/main/notebooks-us/2021_10_04_MAAP_PolInSAR_SAR_Part2.ipynb
	# wget_file $main_path https://raw.githubusercontent.com/IslamAlam/sar-introduction/main/notebooks/2021_06_07_Lecture_2.2.ipynb
	wget_file $DATA_FOLDER/01-sar https://raw.githubusercontent.com/IslamAlam/sar-introduction/main/data/01-sar/signal1_ac.npy
	wget_file $DATA_FOLDER/01-sar https://raw.githubusercontent.com/IslamAlam/sar-introduction/main/data/01-sar/signal2_ac.npy

	# For SAR 2nd week Solution
	# wget_file $main_path/notebook-solution https://raw.githubusercontent.com/IslamAlam/sar-introduction/main/notebook-solution/2021_06_07_Lecture_2.2_update.ipynb

	# For PolSAR 3rd Week
	wget_file $main_path https://raw.githubusercontent.com/IslamAlam/sar-introduction/main/notebooks-us/2021_10_11_MAAP_PolInSAR_PolSAR_Part1.ipynb
	# wget_file $main_path https://raw.githubusercontent.com/IslamAlam/sar-introduction/main/notebooks/2021_06_14_Lecture_3.2.ipynb
	# wget_file $main_path https://raw.githubusercontent.com/IslamAlam/sar-introduction/main/notebooks/2021_06_14_Lecture_3.3.ipynb
	
	# For PolSAR 4th Week
	wget_file $main_path https://raw.githubusercontent.com/IslamAlam/sar-introduction/main/notebooks-us/2021_10_18_MAAP_PolInSAR_PolSAR_Part2.ipynb

	# For InSAR 5th Week
	wget_file $main_path https://raw.githubusercontent.com/IslamAlam/sar-introduction/main/notebooks-us/2021_10_25_MAAP_PolInSAR_InSAR_Part1.ipynb

	# For InSAR 6th Week
	wget_file $main_path https://raw.githubusercontent.com/IslamAlam/sar-introduction/main/notebooks-us/2021_11_01_MAAP_PolInSAR_InSAR_Part2.ipynb
	
	# For PolInSAR 7th Week
	wget_file $main_path https://raw.githubusercontent.com/IslamAlam/sar-introduction/main/notebooks-us/2021_11_08_MAAP_PolInSAR_PolInSAR_Part1.ipynb
	# Slides
	# wget_file $main_path/slides https://raw.githubusercontent.com/IslamAlam/sar-introduction/main/lectures/MAAP-KP-2021-01-SARIntro-Part1.pdf
	# wget_file $main_path/slides https://raw.githubusercontent.com/IslamAlam/sar-introduction/main/lectures/MAAP-KP-2021-02-SARIntro-Part2.pdf
	# wget_file $main_path/slides https://raw.githubusercontent.com/IslamAlam/sar-introduction/main/lectures/MAAP-KP-2021-03-PolSAR-Part1-v2.pdf
	# For PolInSAR 8th Week
	wget_file $main_path https://raw.githubusercontent.com/IslamAlam/sar-introduction/main/notebooks-us/2021_11_15_MAAP_PolInSAR_PolInSAR_Part2.ipynb
	
	# For TomoSAR 9th Week
	wget_file $main_path https://raw.githubusercontent.com/IslamAlam/sar-introduction/main/notebooks-us/2021_11_29_MAAP_PolInSAR_TomoSAR_Part1.ipynb

	# For TomoSAR 10th Week
	wget_file $main_path https://raw.githubusercontent.com/IslamAlam/sar-introduction/main/notebooks-us/2021_12_06_MAAP_PolInSAR_TomoSAR_Part2.ipynb

	# Raw data SAR
	if [[ ! -f $DATA_FOLDER/01-sar/raw-img.rat ]]; then
		echo "01-sar: raw-data downloading"
		gdown_file $DATA_FOLDER/01-sar/raw-img.rat 1Fue1i8IxZC3tKbg-Ax9q8B413Ggm832n
	fi
	# For Reading RAT Files
	# wget_file $main_path https://raw.githubusercontent.com/IslamAlam/sar-introduction/main/notebooks/00-read-rat-file.ipynb

	# For PolSAR
	if [[ ! -f $DATA_FOLDER/02-polsar/slc_16afrisr0107_Phh_tcal_test.rat ]]; then
		echo "Downloading P-Band into: $DATA_FOLDER/02-polsar/"
		# echo "Remove old dir and download new dataset"
		# rm -r $DATA_FOLDER/02-polsar
		gdown https://drive.google.com/uc?id=1nWkhr0tg3G69kiPzGI5YLIuAVT28r8BI

		unzip -j polsar-P-band.zip -d $DATA_FOLDER/02-polsar
		rm polsar-P-band.zip
	fi
	if [[ ! -f $DATA_FOLDER/02-polsar/slc_16afrisr0107_Lhh_tcal_test.rat ]]; then
		gdown https://drive.google.com/uc?id=1-DRvyHlPUh0Z1C2246I12O45hO47TXnm
		unzip -j polsar.zip -d $DATA_FOLDER/02-polsar
		rm polsar.zip
	fi
	
	# Data for 5th Week
	if [[ ! -d $DATA_FOLDER/03-insar ]]; then
		mkdir -p $DATA_FOLDER/03-insar
		cd $DATA_FOLDER/03-insar
		gdown https://drive.google.com/uc?id=1OAf1obJRRld6fS_K5JDJGu5AjGMyVuaa
		gdown https://drive.google.com/uc?id=1rZUxpjE04m3XHXTLCJHxxFgsUt9NW1If
		cd $main_path

	fi
	

	# Data for 6th Week
	if [[ ! -f $DATA_FOLDER/03-insar/flat_earth_Mondah_S_2015_11_11_cut.rat ]]; then
		mkdir -p $DATA_FOLDER/03-insar
		cd $DATA_FOLDER/03-insar
		# gdown https://drive.google.com/uc?id=
		gdown https://drive.google.com/uc?id=1rBg6AwSUYUrnyXI-I0r6ZyAwJg5K52ua
		gdown https://drive.google.com/uc?id=1gUvBLOFCu9Ctw5cYqOruZPXtKoMovJqW
		gdown https://drive.google.com/uc?id=1khRB9MA1__x1nudr4kqt1vgZKEvb5Wu_
	fi

	if [[ ! -f $DATA_FOLDER/03-insar/RH100_Mondah_S_2015_11_11_cut.rat ]]; then
		mkdir -p $DATA_FOLDER/03-insar
		cd $DATA_FOLDER/03-insar
		gdown https://drive.google.com/uc?id=1T1tTWRR_zPhj9JZxKnLTZvp43ocqsJGW

	fi
	
	# Data for 7th Week
	# 1353JDM7NfTxloUdoEVi3jg92SKfS8y3Q
	# if [[ ! -f $DATA_FOLDER/04-polinsar/slc_15tmpsar0302_Lhh_t01.rat ]]; then
		
		mkdir -p $DATA_FOLDER/04-polinsar
		# cd $DATA_FOLDER/04-polinsar
		# gdown https://drive.google.com/uc?id=1muO7YkEpwN0JOlzXq4qk3byLQBQj2vgh
		# incidence_15tmpsar0302_L_t01.rat
		# gdown https://drive.google.com/uc?id=1pC6Q10QSrN1NtSKq-WSRSPhanAFUupbU
		# # kz_2d_demc_15tmpsar0302_15tmpsar0303_t01.rat
		# gdown https://drive.google.com/uc?id=1DyPFk11Py2dbfZuBXLJF4q0cow7Itup5
		# gdown https://drive.google.com/uc?id=1O9sKsXMmnB3NOxZTZLj_6EckXlypNYLb
		# gdown https://drive.google.com/uc?id=1r0b3w8xoDuLp7JyIAHwECeuahLRUvW2L
		# gdown https://drive.google.com/uc?id=12SbjmOLZdr_JuPlMRZ0iJvgGnPiOGpHK
		# gdown https://drive.google.com/uc?id=1Cizvg32T0VTaEz3pHKn7hOrvEKdZEEMr
		# gdown https://drive.google.com/uc?id=1h_NUJ6wosAX8aYRVjAllSMwPA84J1mjt
		# gdown https://drive.google.com/uc?id=1WCtsS6kNw4H364s9fpEgyS6l1-l3mKPx
		# gdown https://drive.google.com/uc?id=1VUnYTiq2qzsCXcYJfvJt9eH7tAO6UAHl
		# gdown https://drive.google.com/uc?id=1oQVtUc5w1PsAhNRtlakjGLok3rz0K9WT
		# gdown https://drive.google.com/uc?id=1TRbuwkO7Pzm_lYFIXNS1uyZusD4ks4f1
		# gdown https://drive.google.com/uc?id=18Kx8gbpB9BM5dsrxjuZsH2G0l7WmznrL
		# gdown https://drive.google.com/uc?id=15h0NhqVP_bFRSUJfQfL3y1VtH4WmuVZE
		

        myFiles=(
			"incidence_15tmpsar0302_L_t01.rat"
			"kz_2d_demc_15tmpsar0302_15tmpsar0303_t01.rat"
			"Lida_r1503.rat"
			"local_slope_15tmpsar0302_L_t01.rat"
			"pha_flat_15tmpsar0302_15tmpsar0303_Lhh_t01.rat"
			"slc_15tmpsar0302_Lhh_t01.rat"
			"slc_15tmpsar0302_Lhv_t01.rat"
			"slc_15tmpsar0302_Lvh_t01.rat"
			"slc_15tmpsar0302_Lvv_t01.rat"
			"slc_coreg_15tmpsar0302_15tmpsar0303_Lhh_t01.rat"
			"slc_coreg_15tmpsar0302_15tmpsar0303_Lhv_t01.rat"
			"slc_coreg_15tmpsar0302_15tmpsar0303_Lvh_t01.rat"
			"slc_coreg_15tmpsar0302_15tmpsar0303_Lvv_t01.rat"
			)
			
        gDriveURLs=(
			"1pC6Q10QSrN1NtSKq-WSRSPhanAFUupbU"
			"1DyPFk11Py2dbfZuBXLJF4q0cow7Itup5"
			"1O9sKsXMmnB3NOxZTZLj_6EckXlypNYLb"
			"1r0b3w8xoDuLp7JyIAHwECeuahLRUvW2L"
			"12SbjmOLZdr_JuPlMRZ0iJvgGnPiOGpHK"
			"1Cizvg32T0VTaEz3pHKn7hOrvEKdZEEMr"
			"1h_NUJ6wosAX8aYRVjAllSMwPA84J1mjt"
			"1WCtsS6kNw4H364s9fpEgyS6l1-l3mKPx"
			"1VUnYTiq2qzsCXcYJfvJt9eH7tAO6UAHl"
			"1oQVtUc5w1PsAhNRtlakjGLok3rz0K9WT"
			"1TRbuwkO7Pzm_lYFIXNS1uyZusD4ks4f1"
			"18Kx8gbpB9BM5dsrxjuZsH2G0l7WmznrL"
			"15h0NhqVP_bFRSUJfQfL3y1VtH4WmuVZE"
        )
			
		for index in ${!myFiles[*]}; do
			echo ${myFiles[$index]} 
			file=${myFiles[$index]}
			fileID=${gDriveURLs[$index]}
		    if [[ ! -f $DATA_FOLDER/04-polinsar/$file ]]; then
		        cd $DATA_FOLDER/04-polinsar
				gdown https://drive.google.com/uc?id=$fileID
				cd $main_path
			fi
			# Download from S3 if GDrive fails
		    if [[ ! -f $DATA_FOLDER/04-polinsar/$file ]]; then
                echo "GDrive failed to download, switch to S3"
				wget -O $DATA_FOLDER/04-polinsar/$file --no-check-certificate --no-proxy https://dlrpolinsar.s3.eu-west-3.amazonaws.com/$file
			fi
		done
		# wget -O $FILENAME --no-check-certificate --no-proxy https://dlrpolinsar.s3.eu-west-3.amazonaws.com/$FILENAME
		# wget -O $FILENAME --no-check-certificate --no-proxy https://dlrpolinsar.s3.eu-west-3.amazonaws.com/$FILENAME
		# wget --no-check-certificate --no-proxy https://dlrpolinsar.s3.eu-west-3.amazonaws.com/slc_coreg_15tmpsar0302_15tmpsar0303_Lvv_t01.rat
		# wget --no-check-certificate --no-proxy https://dlrpolinsar.s3.eu-west-3.amazonaws.com/slc_coreg_15tmpsar0302_15tmpsar0303_Lvv_t01.rat
		# wget --no-check-certificate --no-proxy https://dlrpolinsar.s3.eu-west-3.amazonaws.com/slc_coreg_15tmpsar0302_15tmpsar0303_Lvv_t01.rat
		# wget --no-check-certificate --no-proxy https://dlrpolinsar.s3.eu-west-3.amazonaws.com/slc_coreg_15tmpsar0302_15tmpsar0303_Lvv_t01.rat
		# wget --no-check-certificate --no-proxy https://dlrpolinsar.s3.eu-west-3.amazonaws.com/slc_coreg_15tmpsar0302_15tmpsar0303_Lvv_t01.rat
		# wget --no-check-certificate --no-proxy https://dlrpolinsar.s3.eu-west-3.amazonaws.com/slc_coreg_15tmpsar0302_15tmpsar0303_Lvv_t01.rat
		# wget --no-check-certificate --no-proxy https://dlrpolinsar.s3.eu-west-3.amazonaws.com/slc_coreg_15tmpsar0302_15tmpsar0303_Lvv_t01.rat
		# wget --no-check-certificate --no-proxy https://dlrpolinsar.s3.eu-west-3.amazonaws.com/slc_coreg_15tmpsar0302_15tmpsar0303_Lvv_t01.rat
		# wget --no-check-certificate --no-proxy https://dlrpolinsar.s3.eu-west-3.amazonaws.com/slc_coreg_15tmpsar0302_15tmpsar0303_Lvv_t01.rat
		# wget --no-check-certificate --no-proxy https://dlrpolinsar.s3.eu-west-3.amazonaws.com/slc_coreg_15tmpsar0302_15tmpsar0303_Lvv_t01.rat
		# wget --no-check-certificate --no-proxy https://dlrpolinsar.s3.eu-west-3.amazonaws.com/slc_coreg_15tmpsar0302_15tmpsar0303_Lvv_t01.rat
		# wget --no-check-certificate --no-proxy https://dlrpolinsar.s3.eu-west-3.amazonaws.com/slc_coreg_15tmpsar0302_15tmpsar0303_Lvv_t01.rat
		# wget --no-check-certificate --no-proxy https://dlrpolinsar.s3.eu-west-3.amazonaws.com/slc_coreg_15tmpsar0302_15tmpsar0303_Lvv_t01.rat
		# wget --no-check-certificate --no-proxy https://dlrpolinsar.s3.eu-west-3.amazonaws.com/slc_coreg_15tmpsar0302_15tmpsar0303_Lvv_t01.rat
		
		# unzip -j polinsar.zip -d $DATA_FOLDER/04-polinsar
		# rm polsar.zip
		cd $main_path
	# fi
	
	# For TomoSAR 9th Week
	mkdir -p $DATA_FOLDER/05-tomosar
	
	wget_file $DATA_FOLDER/05-tomosar https://raw.githubusercontent.com/IslamAlam/sar-introduction/main/data/05-tomosar/pos_scatters_ground.npy
	wget_file $DATA_FOLDER/05-tomosar https://raw.githubusercontent.com/IslamAlam/sar-introduction/main/data/05-tomosar/pos_scatters_layer1.npy

	# From TomoSAR 10th Week
	# https://drive.google.com/file/d/1X6gNq7SkyuVbKiY1aKLMKngvYFBb0tDL/view?usp=sharing
	# For TomoSAR
	if [[ ! -f $DATA_FOLDER/05-tomosar/dem.rat ]]; then
		gdown https://drive.google.com/uc?id=1X6gNq7SkyuVbKiY1aKLMKngvYFBb0tDL
		
		if [[ ! -f 05-tomosar.zip ]]; then 
			echo " Please enter your login details for the MAAP to download the data"
			python $main_path/src/maap-s3.py refresh
			python $main_path/src/maap-s3.py download maap-scientific-data/shared/polinsar-data/05-tomosar.zip /projects/05-tomosar.zip
			# python maap-s3.py upload /projects/05-tomosar.zip maap-scientific-data/shared/polinsar-data/05-tomosar.zip
		fi
		unzip -j 05-tomosar.zip -d $DATA_FOLDER/05-tomosar
		rm 05-tomosar.zip
	fi
	
	rm -r /projects/.Trash-0/* > /dev/null 2>&1
	rm -r /tmp/* > /dev/null 2>&1
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


download_polinsar_files_2022()
{
	echo  $'\nThe 3rd edition of the DLR/ESA open PolInSAR training course\n'

	#trap 'echo -e "Aborted, error $? in command: $BASH_COMMAND"; trap ERR; return 1' ERR
	filemanager_os="unsupported"
	filemanager_arch="unknown"
	main_path="/projects"
	
	DATA_FOLDER=/projects/data
	mkdir -p $DATA_FOLDER
	# pip install gdown >/dev/null
	
	cd $main_path
	

	echo "Downloading Files"
	
	# For src ste_io
	wget_file $main_path/src https://raw.githubusercontent.com/IslamAlam/sar-introduction/main/src/ste_io.py
	wget_file $main_path/src https://raw.githubusercontent.com/IslamAlam/sar-introduction/main/src/maap-s3.py

	# Link data folder from S3 Bucket to /projects folder
	# ln -sf /projects/s3-drive/user-data/polinsar/data /projects/data
    mkdir -p /projects/data
    # ln -sf /projects/s3-drive/user-data/polinsar/data/01-sar/ /projects/data
    ln -sf /projects/s3-drive/user-data/polinsar/data/02-polsar/ /projects/data
    ln -sf /projects/s3-drive/user-data/polinsar/data/03-insar/ /projects/data
	# 3. Check if ~/bin/script is a symlink.
	# if [[ -L "/projects/s3-drive/user-data/polinsar/data/03-insar/" ]]; then
	# 	rm /projects/data/03-insar
	# fi
    ln -sf /projects/s3-drive/user-data/polinsar/data/04-polinsar/ /projects/data
    # ln -sf /projects/s3-drive/user-data/polinsar/data/05-tomosar/ /projects/data
	
	
	#########################
	# Download IPython Book #
	#########################
	
	# For IPython Intro
	if [[ ! -d $main_path/cookbook-2nd-code ]]; then
		echo "Downloading Intro Book for IPython "Cookbook" "
		git clone https://github.com/ipython-books/cookbook-2nd-code.git
	fi

	# For SAR notebooks
	wget_file $main_path https://raw.githubusercontent.com/IslamAlam/sar-introduction/main/202205-notebooks/2022_05_02_MAAP_PolInSAR_SAR_Part1.ipynb
	# For SAR 1st Week
	mkdir -p $DATA_FOLDER/01-sar
	wget_file $DATA_FOLDER/01-sar https://raw.githubusercontent.com/IslamAlam/sar-introduction/main/data/01-sar/signal1_rc.npy
	wget_file $DATA_FOLDER/01-sar https://raw.githubusercontent.com/IslamAlam/sar-introduction/main/data/01-sar/signal2_rc.npy

	# For SAR 1st week Solution
	wget_file $DATA_FOLDER/01-sar https://raw.githubusercontent.com/IslamAlam/sar-introduction/main/data/01-sar/signal1_ac.npy
	wget_file $DATA_FOLDER/01-sar https://raw.githubusercontent.com/IslamAlam/sar-introduction/main/data/01-sar/signal2_ac.npy

	# Raw data SAR
	if [[ ! -f $DATA_FOLDER/01-sar/raw-img.rat ]]; then
		echo "01-sar: raw-data downloading"
		gdown_file $DATA_FOLDER/01-sar/raw-img.rat 1Fue1i8IxZC3tKbg-Ax9q8B413Ggm832n
	fi

	wget_file $main_path https://raw.githubusercontent.com/IslamAlam/sar-introduction/main/202205-notebooks/2022_05_09_MAAP_PolInSAR_SAR_Part2.ipynb

	# For PolSAR 3rd Week
	wget_file $main_path https://raw.githubusercontent.com/IslamAlam/sar-introduction/main/202205-notebooks/2022_05_16_MAAP_PolInSAR_PolSAR_Part1.ipynb
	
	# For PolSAR 4th Week
	wget_file $main_path https://raw.githubusercontent.com/IslamAlam/sar-introduction/main/202205-notebooks/2022_05_23_MAAP_PolInSAR_PolSAR_Part2.ipynb

	# For PolSAR 5th Week
	wget_file $main_path https://raw.githubusercontent.com/IslamAlam/sar-introduction/main/202205-notebooks/2022_05_30_MAAP_PolInSAR_InSAR_Part1.ipynb

	# Data for 5th & 6th Week
	if [[ ! -d $DATA_FOLDER/03-insar ]]; then
		mkdir -p $DATA_FOLDER/03-insar
		cd $DATA_FOLDER/03-insar
		gdown https://drive.google.com/uc?id=1OAf1obJRRld6fS_K5JDJGu5AjGMyVuaa
		gdown https://drive.google.com/uc?id=1rZUxpjE04m3XHXTLCJHxxFgsUt9NW1If
		gdown https://drive.google.com/uc?id=1rBg6AwSUYUrnyXI-I0r6ZyAwJg5K52ua
		gdown https://drive.google.com/uc?id=1gUvBLOFCu9Ctw5cYqOruZPXtKoMovJqW
		gdown https://drive.google.com/uc?id=1khRB9MA1__x1nudr4kqt1vgZKEvb5Wu_
		gdown https://drive.google.com/uc?id=1T1tTWRR_zPhj9JZxKnLTZvp43ocqsJGW
		gdown https://drive.google.com/uc?id=16TO2lcyBL2abr14zu9MhL8GIx8na46Bc
		gdown https://drive.google.com/uc?id=1gKYdJJjXKeZq-NAifQtWOG3f-1qdN-iy
		gdown https://drive.google.com/uc?id=1WrEMJy311sGa5McOBwr2CXj0M57E-5rF
		gdown https://drive.google.com/uc?id=1-AYTuuLmESusMd_iX_o_OiYUsfrOCpi-

	fi


	# For PolSAR 6th Week
	wget_file $main_path https://raw.githubusercontent.com/IslamAlam/sar-introduction/main/202205-notebooks/2022_06_06_MAAP_PolInSAR_InSAR_Part2.ipynb

	# For PolInSAR 7th Week
	wget_file $main_path https://raw.githubusercontent.com/IslamAlam/sar-introduction/main/202205-notebooks/2022_06_13_MAAP_PolInSAR_PolInSAR_Part1.ipynb

	cd $main_path

}

if [[ $CHE_WORKSPACE_NAME == *"us"* ]]; then
    echo "US Course!"
    version="US"
    download_us_files
elif [[ $CHE_WORKSPACE_NAME == *"polinsar"* ]]; then
    echo "PolInSAR Course 2022!"
    version="Pol InSAR Course 2022"
    download_polinsar_files_2022
else
    version="EU"
    echo "EU Course!"
    download_files
fi



echo $'\n\n\n#######################\nMade with ❤️ in Munich & Oberpfaffenhofen! \nIn case of any issue with the data and notebooks contact: \n\t polinsar@imansour.net'
echo $'\nEnjoy your Training 🥳 😊\n'
