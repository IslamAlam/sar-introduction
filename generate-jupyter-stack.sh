
export DOCKER_ID_USER="imansour"
export VERSION="0.0.16"

docker build -t maap-sar-intro -t $DOCKER_ID_USER/maap-sar-intro:$VERSION -t $DOCKER_ID_USER/maap-sar-intro:latest .
# docker tag maap-jupyterlab $DOCKER_ID_USER/maap-esa-jupyterlab:$VERSION
docker push $DOCKER_ID_USER/maap-sar-intro:$VERSION
docker push $DOCKER_ID_USER/maap-sar-intro:latest

#to push in orange registry. 
#docker tag maap-jupyterlab registry.eu-west-0.prod-cloud-ocb.orange-business.com/cloud-biomass-maap/maap-esa-jupyterlab:$VERSION
#docker push registry.eu-west-0.prod-cloud-ocb.orange-business.com/cloud-biomass-maap/maap-esa-jupyterlab:$VERSION
