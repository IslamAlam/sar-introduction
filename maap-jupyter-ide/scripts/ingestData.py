'''
Created on 21 MAY. 2019

@author: TKOSSOKO
'''
import os
import logging
import requests #sudo pip install requests
import json
import sys
import shutil #used to move a file
from pathlib import Path
from properties.p import Property
from typing import Iterable

logging.basicConfig(filename='ShareData.log', level=logging.DEBUG, format='%(asctime)s %(levelname)-8s %(message)s', datefmt='%Y-%m-%d %H:%M:%S')
# We get the url of the service we want to call
url_root = os.environ['BMAP_BACKEND_URL']

# get the metadata of a data and call the api
def ingestPrivateData(propertiesPath):   
    input_file = propertiesPath
    print('1- We start the ingestion process')
    print('2- The content of the file '+ input_file + ' is read')   
    
    allVariableAreFilled = True;
    if Path(input_file).is_file():
        # load properties file
        data_criteria = Property().load_property_files(input_file)
        # add the criteria from the properties file to the dictionary
        criteria_list = {}
        try :
            user_id = data_criteria['user_id']
            if len(user_id) > 0:
                criteria_list['userId'] =  user_id
                print(' 2.1- The user id is '+ user_id)
            else:
                allVariableAreFilled =  False;
                print(' 2.1- The user is mandatory')
        except:
            pass
        try : 
            data_path = data_criteria['data_path']
            if len(data_path) > 0:
                criteria_list['dataPath'] =  data_path 
                print(' 2.2- The data path is '+ data_path)
            else:
                allVariableAreFilled =  False;
                print(' 2.2- The data path is mandatory')
        except:
            pass
        try : 
            product_type = data_criteria['product_type']
            if len(product_type) > 0:
                criteria_list['dataFormat'] =  product_type 
                print(' 2.3- The product type is '+ product_type)
            else:
                allVariableAreFilled =  False;
                print(' 2.3- The product type is mandatory')
        except:
            pass        
               
        # location = data_criteria['location']
        try :
            polarization = data_criteria['polarization']
            if len(polarization) > 0:
                criteria_list['polarization'] =  polarization 
                print(' 2.4- The polarization is '+ polarization)
            else:
                criteria_list['polarization'] =  None 
            '''
                allVariableAreFilled =  False;
                print(' 2.4- The polarization is mandatory')
            '''
            
        except:
            pass


        try : 
            sub_region_name = data_criteria['sub_region_name']
            if len(sub_region_name) > 0:
                criteria_list['subregionName'] =  sub_region_name 
                print(' 2.5- The sub region is '+ sub_region_name)
           
            else:
                '''
                allVariableAreFilled =  False;
                print(' 2.5- The sub region is mandatory')
                '''
                criteria_list['subregionName'] =  None 
                       
        except:
            pass
        '''
        try : 
            collection_name = data_criteria['collection_name']
            if len(collection_name) > 0:
                criteria_list['collectionName'] =  collection_name 
                print(' 2.4- The collection is '+ collection_name)
            else:
                allVariableAreFilled =  False;
                print(' 2.4- The collection is mandatory')     
        except:
            pass
        '''
            

    else:
        print('ERROR: The file "' + input_file + '" does not exist.')
        logging.error('The file "' + input_file + '" does not exist.')   
        
    if(allVariableAreFilled):
        print("All variables in sharedata.properties are filled. We start the process")
        ##We move the data in the /data/private using the user id
        print("3- Starting the copy of the file to a temp folder")
        folder_destination="/app/User_data/"
        
        folder_destination = createIfnotExistFolder(folder_destination, criteria_list['userId'])
        
        if(criteria_list['dataFormat'])== 'ROI' :
                print("3.1- File format detected is ROI. We need 4 files : dbf, shp, shx, prj") 
                listeOfRoi = isROIfileExistAll(data_path)   
                if(len(listeOfRoi)>0):
                    #We move the 4 ROI files                    
                    for i in range(len(listeOfRoi)):
                        filePath = listeOfRoi[i]        
                        shutil.copy(filePath, folder_destination)  
                    print("4- Files correctly copied")
                else:
                    print("4-we cannot ingest this ROI files. Some files are missing")
                    exit()
        else :
                shutil.copy(data_path, folder_destination)
                print("4- File correctly copied")
                
        ######We call the back end service to start the ingestion
        ingestTheData(criteria_list, folder_destination+"/"+os.path.basename(criteria_list['dataPath']))
    else:
        print("Not all mandatory fields are filled.")
        
        
#########Function to call the back end and check the id of the user      
def createIfnotExistFolder(directory, user_id):
    response = sendARequest(url_root+"bmapuser/"+user_id)
    if len(response) > 0:
        bmaap_user = json.loads(response)
        id = bmaap_user["BmaapUser"]["id"]
        pathToTempData = directory+str(id)
        if not os.path.exists(pathToTempData):
           os.makedirs(pathToTempData)
        return pathToTempData
    else:
        print("The user is unknown. We stop the process")




#########Function to send a request to the back end
def sendARequest(url) :
    try:
        response = requests.get(url)
        json_str = response.text
        # if the response body contains something
        if len(json_str) > 0:
            return json_str
        else:
            return ""
    except requests.exceptions.RequestException as e:
            print('ERROR: ' + str(e))
            logging.error(str(e))
#########################################################################
def ingestTheData(criteria_list, destination):
       
    print('5- Your metadata are : ' + str(criteria_list))
    url = url_root + "catalogue/granule/private/add?dataPath=" + destination  + "&dataFormat=" + criteria_list['dataFormat'] + "&userId=" + str(criteria_list['userId'])
    if criteria_list['subregionName']:
        url = url+ "&subregionName=" + criteria_list['subregionName']
    if criteria_list['polarization']:
        url = url+ "&polarization=" + criteria_list['polarization']

    response = requests.get(url)
    json_str = response.text
    code = response.status_code
    if (code == 200):
      print("File correctly ingested")
    else:
      print(json_str)
######################################

def isROIfileExistAll(datapath) :
    dataPathWithouExtension =(os.path.splitext(datapath)[0])
    roiShx = dataPathWithouExtension + ".shx"
    roiShp = dataPathWithouExtension + ".shp"
    roiDbf = dataPathWithouExtension + ".dbf"
    roiPrj = dataPathWithouExtension + ".prj"
    #We start the verification of the extension
    listeOfRoi = []
    listeOfRoi.extend((roiShx, roiShp, roiDbf, roiPrj))
    for i in range(len(listeOfRoi)):
        filePath = listeOfRoi[i]
        if Path(filePath).is_file():
            print("ROI file found at  "+filePath)
        else:   
            print("A mandatory ROI file is missing "+filePath)
            listeEmpty = []
            return listeEmpty
    
    return listeOfRoi
    
######################################

ingestPrivateData(sys.argv[1])
