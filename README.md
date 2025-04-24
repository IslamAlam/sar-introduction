# DLR ESA SAR Introduction Course

The tutorial can be deployed either locally using Docker or on the ESA Multi-Mission Algorithm and Analysis Platform (MAAP), a collaborative project between NASA and ESA.

Docker Hub: [Image](https://hub.docker.com/repository/docker/imansour/maap-sar-intro/tags?page=1&ordering=last_updated)

## Option 1: Deploy on ESA MAAP Platform

### Manual Setup Steps:

1. Access the ESA MAAP Dashboard:
   - Navigate to: https://che.ade.esa-maap.org/dashboard/
   - Log in with your ESA MAAP username and password
![image](https://github.com/user-attachments/assets/804f1208-8d58-4261-ba52-b4c4da0b69f4)
![image](https://github.com/user-attachments/assets/9bff947f-ae8b-4ada-8e25-38e6c40c66a5)

2. Create New Workspace:
   - Use the following repository URL:
     ```
     https://github.com/IslamAlam/sar-introduction.git
     ```
![image](https://github.com/user-attachments/assets/17ab67f1-cc3e-4661-9c9c-227cfc16a218)
![image](https://github.com/user-attachments/assets/ddf121a4-13d8-4be7-ba26-e8b6e5b2808c)

   - Wait for the workspace to initialize and start
![image](https://github.com/user-attachments/assets/065adcbe-8085-44a1-b564-5f491515d256)
![image](https://github.com/user-attachments/assets/51172245-7598-4d46-a35f-5a6d457ae06c)
![image](https://github.com/user-attachments/assets/0dfd383e-3c86-4960-9a51-22a9130e5b13)
![image](https://github.com/user-attachments/assets/e871d437-e859-4e03-98e4-2e5e0bf58e06)
Voilà! It works! 🎉 🚀 ✨

Note: Please ensure you have valid ESA MAAP credentials before attempting to access the platform.

## Option 2: Deploy Locally

### Using Docker

#### To Start the container:
```bash
$ docker run -d -p 3100:3100 --name=dlr-sar-intro -v "$(pwd)"/data:/projects imansour/maap-sar-intro:latest
