#!/usr/local/bin/python
import sys, getopt
import requests
import json
import sys
import os
import time
import math
import os.path as path
# Import getopt module
import getopt


MAAP_ENV_TYPE = os.getenv("MAAP_ENV_TYPE")
CLIENT_ID = os.getenv("CLIENT_ID")
BEARER=""
#if windows we take the current folder
if sys.platform == 'win32':
   USER_INFO_FILE_PATH=os.getcwd()+"\maap-s3-userinfo.json"
   USER_LAST_UPLOAD_INFO_FILE_PATH=os.getcwd()+"\maap-s3-multipartinfo.json"
else :
   USER_INFO_FILE_PATH="/usr/bmap/maap-s3-userinfo.json"
   USER_LAST_UPLOAD_INFO_FILE_PATH="/usr/bmap/maap-s3-multipartinfo.json"
   
userinfo = {}
multipartinfo = {}

def display_help():
    print('Usage: [option...] {upload|download|list|delete|refresh|resume}')
    #print('-i                                                                   Get a fresh token before any request. It ask for email and password')
    print('upload     myFile.tiff locally          path/myFile.tiff in the S3    Upload data in the S3')
    print('download   myFileName.tiff              path/in/S3/file.tiff          Download a data from the S3')
    print('list       folder/path                                                List data in a subfolder')
    print('delete     path/in/S3/file.tiff                                       Delete an existing data on S3')
    print('refresh                                                               Refresh credentials and password')
    print('token      email                        password                      Return a bearer token')
    print('login      email                        password                      Login the user')
    print('resume                                                                Resume last interrupted multipart upload')
    sys.exit(2)


#########################
# Init the bearer       #
#########################
def init():

        
    if os.path.isfile(USER_INFO_FILE_PATH):
        print("[INFO] Personal user info is find")
        #Check if the file is created less than one hour
        if is_file_older_than_x_hour(USER_INFO_FILE_PATH):
            print("[INFO] Token is expired, we generate a new one")
            #Get the email and password info
            with open(USER_INFO_FILE_PATH) as json_file:
                userinfo = json.load(json_file)
            #Get the info
            email=userinfo['email']
            password=userinfo['password']
            #Regenerate token
            #Function to generate a new token
            generate_token(email, password)            

        else:
            print("[INFO] Token is still valid")

    else:
        print("[INFO] Personal user info is not found")
        refresh()


###########################
# Refresh token and save #
###########################
def refresh():
    email = input("Your email: ")
    #password
    password = input("Your password: ")           
    #Function to generate a new token
    generate_token(email, password)


###################################
# Login using email dans password #
###################################
def login(email, password):
    if email and password:
        print("[INFO] Get an existing or fresh token")         
        #Function to generate a new token
        generate_token(email, password)
    else:
        print("[ERROR] Please check your email or password") 

###########################
# Generate token and save #
###########################
def generate_token(email, password): 
        
    print("[INFO] Start retrieving token for authent")
    #Set the bearer
    url = "https://iam."+MAAP_ENV_TYPE.lower()+".esa-maap.org/oxauth/restv1/token"
    print (url)
    print (CLIENT_ID)
    response = requests.post(url, data={'client_id': CLIENT_ID, 'username': email, 'password': password, "grant_type": "password", "scope": "openid+profile"})
    print(response)
    #Convert the string to json to fecth access_token
    data = json.loads(response.text)
    token = data['access_token']

    # add the token in the json info file
    #Create a json with email and password
    userinfo = {
        'email': email,
        'password': password,
        'token': token
    }

    if token: 
        #add the json in the file
        with open(USER_INFO_FILE_PATH, 'w') as outfile:
            json.dump(userinfo, outfile)
           
        print("[INFO] Token saved for one hour and ready to be used "+token)
        
    else:
        print("[ERROR] Token is empty. Please 1) run refresh (-r) function and check your password")
        # Terminate the script
        sys.exit(2)


################################
# Generate token and return it #
###############################
def get_token(email, password): 
        
    #print("[INFO] Start retrieving token for authent")
    #Set the bearer
    url = "https://iam."+MAAP_ENV_TYPE.lower()+".esa-maap.org/oxauth/restv1/token"
    response = requests.post(url, data={'client_id': CLIENT_ID, 'username': email, 'password': password, "grant_type": "password", "scope": "openid+profile"})
    #Convert the string to json to fecth access_token
    data = json.loads(response.text)
    token = data['access_token']
    print (token)
    return token



#########################
# Check if file is older#
#########################
def is_file_older_than_x_hour(file, hour=1): 
    file_time = path.getmtime(file) 
    # Check against 214 hour 
    return ((time.time() - file_time) > 3600*hour)

#########################
# Upload the data in S3 #
#########################
def upload(sourceFile, destination):
    print("[INFO] Source file is : ", sourceFile)
    print("[INFO] Destination file is : ", destination) 

    if sourceFile and destination:
        print("[INFO] Get an existing or fresh token")
        #Generate or get a token
        init()

            
        # If the file is less that 100 MB we upload directly
        #Check file size
        fileSize = os.stat(sourceFile).st_size
        print("Size "+ str(fileSize))
    
        #We have more than 5GB
        if fileSize > 5000000000:
            #We upload the multi part data
            print("[INFO] Starting multi part upload")
            upload_multipart(sourceFile, destination)

        else: 
            with open(USER_INFO_FILE_PATH) as json_file:
                userinfo = json.load(json_file)
                #Get the info
                token=userinfo['token']

            print("[INFO] Starting retrieving the presigned url for the creation of the file with token "+ token)
            #files = {'upload_file': open(sourceFile,'rb')}
            url = "https://gravitee-gateway."+MAAP_ENV_TYPE.lower()+".esa-maap.org/s3/"+destination

            response = requests.put(url, headers = {'Authorization': 'Bearer '+token}, allow_redirects=False)
            location = response.headers['Location']
            print("[INFO] Location is "+ location)

            if location:
                print("[INFO] Start uploading the file")
                with open(sourceFile, 'rb') as f:
                    response = requests.put(location, data=f)
                    print(response)
                #files = {'file': open(sourceFile, 'rb')}
                #r = requests.put(location, files=files)
                
            else:
                print("[ERROR] Presigned url not generated. Please re run refresh or contact admin if the error persist")

    else:
        display_help()



###########################################################
# Upload the data in S3, the data is split chunk by chunk #
###########################################################
def upload_multipart(sourceFile, destination):

    #Get the token
    with open(USER_INFO_FILE_PATH) as json_file:
        userinfo = json.load(json_file)
        #Get the info
        token=userinfo['token']

    #Set variables
    filePath = sourceFile
    key = destination

    fileSize = os.stat(filePath).st_size
    print("Size "+ str(fileSize))
    #Set max to split to 5M
    max_size = 5 * 1024 * 1024 # Approach 1: Assign the size 
    nbParts = math.ceil(fileSize/max_size)    #calculate nbParts
    print("[INFO] We will have "+ str(nbParts)+" parts")
            
    
    url = "https://gravitee-gateway."+MAAP_ENV_TYPE.lower()+".esa-maap.org/s3/generateUploadId"
    params={'bucketName': 'bmap-catalogue-data', 'objectKey': key}
    response = requests.get(url, params = params,  headers = {'Authorization': 'Bearer '+token})
 
    print("[INFO] uploadId "+ response.text)
    #Save upload id
    uploadId = response.text

    #Generate presigned urls 
    url = "https://gravitee-gateway."+MAAP_ENV_TYPE.lower()+".esa-maap.org/s3/generateListPresignedUrls"
    params={'bucketName': 'bmap-catalogue-data', 'objectKey': key, 'nbParts': nbParts, 'uploadId': uploadId}
    response = requests.get(url, params = params, headers = {'Authorization': 'Bearer '+token})

    stringList = response.text
    str1 = stringList.replace(']','').replace('[','')
    listPresignedUrl  = str1.replace('"','').split(",")

    # we load the data
    #print(listPresignedUrl)
    parts = []

    #sys.stdout = open("log.txt", "w")
    with open(filePath, 'rb') as f:    
        i = 0
        while i < nbParts:
            print("Upload part "+ str(i))
            file_data = f.read(max_size)
            headers={'Content-Length': str(max_size)}
            #print(listPresignedUrl[i])
            response = requests.put(listPresignedUrl[i], data=file_data, headers=headers)
            #print(response.headers)
            #print(response.text)
            etag = response.headers['ETag']  
            parts.append({'eTag': etag, 'partNumber': int(i+1)})
            print(parts)
            i = i+1
            #We save also the multipart
            #So we can resume it if upload failed
            multipartinfo = {
                'uploadId': uploadId,
                'partsUpploaded': parts,
                'sourceFile': sourceFile,
                'destination': destination
            }
            
            #add the json in the file
            with open(USER_LAST_UPLOAD_INFO_FILE_PATH, 'w') as outfile:
                json.dump(multipartinfo, outfile)


    #sys.stdout.close()
    #complete the multi part
    url = "https://gravitee-gateway."+MAAP_ENV_TYPE.lower()+".esa-maap.org/s3/completeMultiPartUploadRequest"
    params={'bucketName': 'bmap-catalogue-data', 'objectKey': key, 'nbParts': nbParts, 'uploadId': uploadId}
    response = requests.get(url, data=str(parts),  params = params, headers = {'Authorization': 'Bearer '+token})
    #delete the file of multipart info because upload was success
    os.remove(USER_LAST_UPLOAD_INFO_FILE_PATH) 




###################################
# Resume failed multi part upload #
###################################
def resume():
    print("[INFO] Resume the last multipart upload")
    print("[INFO] Check last multipart upload metadata")

    if os.path.isfile(USER_LAST_UPLOAD_INFO_FILE_PATH):
        
        #Generate or get a token
        init()
        print("[INFO] Previous multi part upload file found")
        token=''
        #Get the token
        with open(USER_INFO_FILE_PATH) as json_file:
            userinfo = json.load(json_file)
            #Get the info
            token=userinfo['token']
        
        #Get the data in the json file
        with open(USER_LAST_UPLOAD_INFO_FILE_PATH) as json_file:
            multipartinfo = json.load(json_file)
            #Get the info
            uploadId=multipartinfo['uploadId']
            destination=multipartinfo['destination']
            sourceFile=multipartinfo['sourceFile']
            partsUpploaded=multipartinfo['partsUpploaded']
            
            #We get the presigned url
            fileSize = os.stat(sourceFile).st_size
            print("Size "+ str(fileSize))
            #Set max to split to 5M
            max_size = 5 * 1024 * 1024 # Approach 1: Assign the size 
            nbParts = math.ceil(fileSize/max_size)    #calculate nbParts
            finalPart = nbParts - len(partsUpploaded)
            print("[INFO] We will have "+ str(nbParts)+" parts minus already uploaded parts. We have to push "+ str(finalPart) +" parts")
                        
            #Generate presigned urls 
            
            url = "https://gravitee-gateway."+MAAP_ENV_TYPE.lower()+".esa-maap.org/s3/generateListPresignedUrls"
            params={'bucketName': 'bmap-catalogue-data', 'objectKey': destination, 'nbParts': finalPart, 'uploadId': uploadId}
            response = requests.get(url, params = params, headers = {'Authorization': 'Bearer '+token})

            stringList = response.text
            str1 = stringList.replace(']','').replace('[','')
            listPresignedUrl  = str1.replace('"','').split(",")    
            
            #Get the json uploaded list
            
            #we iterate over the data and repush
            with open(sourceFile, 'rb') as f:    
                i = 0
                presignedUrlIndex = 0
                while i < nbParts:
                    
                    file_data = f.read(max_size)
                    #We upload only if we have new nn uploaded part
                    if i > len(partsUpploaded):
                        
                        print("Upload part "+ str(i))
                        headers={'Content-Length': str(max_size)}
                        #print(listPresignedUrl[i])
                        response = requests.put(listPresignedUrl[presignedUrlIndex], data=file_data, headers=headers)
                        #print(response.headers)
                        #print(response.text)
                        etag = response.headers['ETag']  
                        partsUpploaded.append({'eTag': etag, 'partNumber': int(i+1)})                        
                        presignedUrlIndex = presignedUrlIndex + 1
                        #We save also the multipart
                        #So we can resume it if upload failed
                        multipartinfo = {
                            'uploadId': uploadId,
                            'partsUpploaded': partsUpploaded,
                            'sourceFile': sourceFile,
                            'destination': destination
                        }
                        
                        #add the json in the file
                        with open(USER_LAST_UPLOAD_INFO_FILE_PATH, 'w') as outfile:
                            json.dump(multipartinfo, outfile)
                    
                    #We increase the data
                    i = i+1  
              
            #complete the multi part
            url = "https://gravitee-gateway."+MAAP_ENV_TYPE.lower()+".esa-maap.org/s3/completeMultiPartUploadRequest"
            params={'bucketName': 'bmap-catalogue-data', 'objectKey': key, 'nbParts': nbParts, 'uploadId': uploadId}
            response = requests.get(url, data=str(parts),  params = params, headers = {'Authorization': 'Bearer '+token})
            #delete the file of multipart info because upload was success
            os.remove(USER_LAST_UPLOAD_INFO_FILE_PATH) 
    
    else:
        print("[INFO] Please run upload. There are no upload to be resume")
        
    
    
    

###################
# Delete the data #
####################
def delete(destination):
    print("[INFO] Destination file is : ", destination)
    
    if destination:
        print("[INFO] Get an existing or fresh token")
        #Generate or get a token
        init()
        with open(USER_INFO_FILE_PATH) as json_file:
            userinfo = json.load(json_file)
            #Get the info
            token=userinfo['token']
            
        #call the api to delete the data
        #Get the presigned url to delete the data
        url = "http://gravitee-gateway."+MAAP_ENV_TYPE.lower()+".esa-maap.org/s3/"+destination
        print(url)
        response = requests.delete(url, headers = {'Authorization': 'Bearer '+token}, allow_redirects=False)    
        
        location = response.headers['Location']
        
        #We have the 
        if location:
            #We delete the data using the location
            print("[INFO] we are about to delete")
            response = requests.delete(location)
            print(response)
        
    else:
        display_help()




###################
# download the data #
####################
def download(path, name):
    print("[INFO] path file is : ", path)
    
    if path:
        print("[INFO] Get an existing or fresh token")
        #Generate or get a token
        init()
        with open(USER_INFO_FILE_PATH) as json_file:
            userinfo = json.load(json_file)
            #Get the info
            token=userinfo['token']
            
        #Get the presigned url to download the data
        url = "https://gravitee-gateway."+MAAP_ENV_TYPE.lower()+".esa-maap.org/s3/"+path

        response = requests.get(url, headers = {'Authorization': 'Bearer '+token}, allow_redirects=False)     
        location = response.headers['Location']
        
        #We have the 
        if location:
            #We download the data using the location
            print("[INFO] we are about to download the data")
            download_file(location, name)
            #response = requests.get(location)
            #open(name, 'wb').write(response.content)
            print("[INFO] Download finished")
        
    else:
        display_help()



##########################
# download file using url #
##########################       
def download_file(url, name):
    #local_filename = url.split('/')[-1]
    # NOTE the stream=True parameter below
    with requests.get(url, stream=True) as r:
        r.raise_for_status()
        with open(name, 'wb') as f:
            for chunk in r.iter_content(chunk_size=8192): 
                # If you have chunk encoded response uncomment if
                # and set chunk_size parameter to None.
                #if chunk: 
                f.write(chunk)
    return name


##########################
# list data in s3 folder #
##########################
def list(path):
    print("[INFO]: Start finding data in path : "+path)
    
    if path:
        print("[INFO] Get an existing or fresh token")
        #Generate or get a token
        init()
        with open(USER_INFO_FILE_PATH) as json_file:
            userinfo = json.load(json_file)
            #Get the info
            token=userinfo['token']
            
        #call the api to delete the data
        #Get the presigned url to delete the data

        url = "https://gravitee-gateway."+MAAP_ENV_TYPE.lower()+".esa-maap.org/s3/"+path+"?list=true"

        response = requests.get(url, headers = {'Authorization': 'Bearer '+token}, allow_redirects=False)     
        print("[INFO] Result list:")  
        if(response.text):            
            print(response.text)
        else:
            print("[INFO] No data found")
    else:
        display_help()

# Store argument variable omitting the script name
argv = sys.argv[1:]
# Initialize result variable
result=0
 
try:

    if len(argv) == 0:
        display_help()
    else:
        if argv[0] == 'resume':
            resume()
        elif argv[0] == 'refresh':
            refresh()
        elif argv[0] == 'upload':
            # Upload a data
            if len(argv) != 3:          
                display_help()
            else:
                upload(argv[1], argv[2])
        elif argv[0] == 'delete':
            # Delete a data
            if len(argv) != 2:
                display_help()
            else:
                delete(argv[1])
        elif argv[0] == 'token':
            # Delete a data
            if len(argv) != 3:
                display_help()
            else:
                get_token(argv[1], argv[2])
        elif argv[0] == 'login':
            # Delete a data
            if len(argv) != 3:
                display_help()
            else:
                login(argv[1], argv[2])    
        elif argv[0] == 'download':
            # Download a data
            if len(argv) != 3:
                display_help()
            else:
                download(argv[1], argv[2])  
        elif argv[0] == 'list':
            # list a folder
            if len(argv) != 2:
                display_help()
            else:
                list(argv[1])
        elif argv[0] == 'help':
            display_help()
        else:  
            display_help()



except getopt.GetoptError:

  # Print the error message if the wrong option is provided
  print('The wrong option is provided. Please run -h')
 
  # Terminate the script
  sys.exit(2)
