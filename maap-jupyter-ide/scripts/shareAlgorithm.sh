#!/bin/bash
# Ask the user for the source url
 echo "Hello, please enter the following information"
 echo -n Git HTTPS url of the source code you want to copy :
 read gitlabSourceREpo
 echo "===> The url you want to copy is : " $gitlabSourceREpo

# Ask the user for the destination url
 echo -n Git HTTPS destination url :
 read gitlabDestREpo
 echo "===> The source will be copied in : " $gitlabDestREpo

# Ask the user for the email
 
 echo  -n Email :
 read  gitlabEMail
 echo "===> The email is : " $gitlabEMail

# Ask the user for the username
 echo -n Username : 
 read gitlabUsername
 echo "===> The username is : " $gitlabUsername

# Ask the user for the password
 echo -n Password : 
 read  -s gitlabPAssword

#We extract the correct url for the source
 gitLabSourceWIthoutHttps=${gitlabSourceREpo:8}
 #We get also thename of the repository
   repoSourceName=${gitLabSourceWIthoutHttps##*/}

#We extract the correct url for the destination
 gitLabDestinationWIthoutHttps=${gitlabDestREpo:8}
   repoDestName=${gitLabDestinationWIthoutHttps##*/}
   repoDEstNameWithoutExtension=${repoDestName%.*}

#We do the the clone of the first repository
 git clone --bare https://$gitlabUsername:$gitlabPAssword@$gitLabSourceWIthoutHttps

#We move in the folder containing all of the information about the old repository
 cd $repoSourceName
 git push --mirror https://$gitlabUsername:$gitlabPAssword@$gitLabDestinationWIthoutHttps

#We remove the temporary local repository
 cd ..
 rm -rf $repoSourceName

#We clone the new repository
 git clone https://$gitlabUsername:$gitlabPAssword@$gitLabDestinationWIthoutHttps

#We copy the gitlab.yml file into the new folder, commit and push

 cd $repoDEstNameWithoutExtension
 cp /usr/bmap/.gitlab-ci.yml .

 echo "We set the git configuration: "
 sudo  git config --system --unset credential.helper
 sudo git config --system credential.helper store

 sudo git config --global user.email $gitlabEMail
 sudo git config --global user.name $gitlabUsername

 git add .gitlab-ci.yml

 git commit -m "gitlab-ci.yml added"
 git push https://$gitlabUsername:$gitlabPAssword@$gitLabDestinationWIthoutHttps --all

 
