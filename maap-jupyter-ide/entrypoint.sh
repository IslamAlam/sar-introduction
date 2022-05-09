#!/bin/bash 
  
# Reconstruct Che preview url
THE_MACHINE=''

# Get the Che machine name from either MACHINE_NAME, used by Che v6, or CHE_MACHINE_NAME, used by Che v7 
if [[ -z "${MACHINE_NAME}" ]]; then
  THE_MACHINE=`echo $CHE_MACHINE_NAME | tr 'a-z' 'A-Z' | tr '-' '_'`
else
  THE_MACHINE="${MACHINE_NAME}"
fi


# Dump all env variables into file so they exist still though SSH
env | grep _ >> /etc/environment

# Add conda bin to path
export PATH=$PATH:/opt/conda/bin
cp /root/.bashrc ~/.bash_profile

service ssh start

#Dowload a script from the env variable MAAP_INIT_SCRIPT_URL1  (git or s3 public by http)
mkdir -p /projects/.maap
wget -O /projects/.maap/maap_init.sh $MAAP_INIT_SCRIPT_URL3
chmod +x /projects/.maap/maap_init.sh
/projects/.maap/maap_init.sh

jupyter lab --ip=0.0.0.0 --port=3100 --allow-root --NotebookApp.token='' --no-browser --debug --NotebookApp.tornado_settings='{"headers":{"Content-Security-Policy":"frame-ancestors self *.esa-maap.org; report-uri /api/security/csp-report"}}'
