# DLR ESA SAR Introduction Course

The tutorial can be deployed to a local computer using the docker image available in Docker Hub or to the Multi-Mission Algorithm and Analysis Platform (MAAP), a collaborative project between NASA and ESA.

Docker Hub: [Image](https://hub.docker.com/repository/docker/imansour/maap-sar-intro/tags?page=1&ordering=last_updated)


#### To Start the container (open the browser):
To open Jupyter lab open the browser [http://localhost:3100](http://localhost:3100)

    $ docker run -d -p 3100:3100 --name=dlr-sar-intro -v "$(pwd)"/data:/projects imansour/maap-sar-intro:latest
    
#### To Stop the container: 
    $ docker container stop dlr-sar-intro
    
#### To Remove the container: 
    $ docker container rm dlr-sar-intro
