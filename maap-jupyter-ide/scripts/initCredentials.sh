#!/bin/bash
# Ask the user for the source url
 echo "Hello, please enter the following information to be connected to Gitlab; You have to run this 
script once per workspace."

# Ask the user for the email
 echo -n Enter your email :
 read email
 echo "===> The url you want to copy is : " $email

# Ask the user for the password
 echo -n Enter your password : 
 read  -s password

 sudo git config --system --unset credential.helper
 sudo git config --system credential.helper store
 sudo git config --global user.email "$email"
 sudo git config --global user.name "$password"
