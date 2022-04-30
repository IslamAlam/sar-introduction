#!/bin/bash
# My first script

#Initialisation of variables
pwd=`pwd`

templateInitialisation() {

	echo "#### Project initialisation is started in the folder $pwd ####"	
	unzip /usr/bmap/Project_template.zip -d $pwd
	mv $pwd/Project_template/* $pwd
	rm -rf Project_template
	rm main.py
}

#Invokation of the function
templateInitialisation
