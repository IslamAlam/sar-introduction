'''
Created on 13 nov. 2018

@author: QFAURE
'''
import os
import logging
import requests #sudo pip install requests
import json
from pathlib import Path
from properties.p import Property
from typing import Iterable


logging.basicConfig(filename='RestClient.log', level=logging.DEBUG, format='%(asctime)s %(levelname)-8s %(message)s', datefmt='%Y-%m-%d %H:%M:%S')
url = os.environ['BMAP_BACKEND_URL'] + 'catalogue/granule/'

# gets a granule by name and returns the json containing the granule's metadata.
def get_granule_by_name(granule_name: str,formatmetadata=False) -> Iterable:
    try:
        response = requests.get(url + 'granulename/' + granule_name)
        json_str = response.text
      
        # if the response body contains something
        if len(json_str) > 0:
            json_obj = json.loads(json_str)
            
            if formatmetadata==True :
                            
                return format_metadata([json_obj])
            else : 
                return json_obj
        else:
            print('INFO: There is no data with ID: ' + granule_name)
            logging.info('There is no data with ID: ' + granule_name)
            return {}
    except requests.exceptions.RequestException as e:
        print('ERROR: ' + str(e))
        logging.error(str(e))


# gets granules by criteria and returns json containing granules' metadata:
def get_granules_by_criteria(input_file: str='datacriteria.properties',formatmetadata=False) -> Iterable:
    
    
    if Path(input_file).is_file():
        # load properties file
        data_criteria = Property().load_property_files(input_file)
        # add the criteria from the properties file to the dictionary
        criteria_list = {}
        try :
            start_date = data_criteria['start_date']
            if len(start_date) > 0:
                criteria_list['"startDate"'] = '"' + start_date + '"'
        except:
            pass
        try : 
            end_date = data_criteria['end_date']
            if len(end_date) > 0:
                criteria_list['"endDate"'] = '"' + end_date + '"'
        except:
            pass
        try :    
            product_types = data_criteria['product_types']
            if len(product_types) > 0:
                criteria_list['"productTypes"'] = to_table_string(product_types)
        except:
            pass
        try :    
            instrument_names = data_criteria['instrument_names']
            if len(instrument_names) > 0:
                criteria_list['"instrumentNames"'] = to_table_string(instrument_names)
        except:
            pass
        
        # location = data_criteria['location']
        try :
            polarizations = data_criteria['polarizations']
            if len(polarizations) > 0:
                criteria_list['"polarizations"'] = to_table_string(polarizations)
        except:
            pass
        try : 
            geometry_types = data_criteria['geometry_types']
            if len(geometry_types) > 0:
                criteria_list['"geometryTypes"'] = to_table_string(geometry_types)
        except:
            pass
        try : 
            processing_levels = data_criteria['processing_levels']
            if len(processing_levels) > 0:
                criteria_list['"processingLevels"'] = to_table_string(processing_levels)
        except:
            pass
        try : 
            sub_region_names = data_criteria['sub_region_names']
            if len(sub_region_names) > 0:
                criteria_list['"subRegionNames"'] = to_table_string(sub_region_names) 
        except:
            pass
        try : 
            collectionNames = data_criteria['collection_Names']
            if len(collectionNames) > 0:
                criteria_list['"collectionNames"'] = to_table_string(collectionNames)
        except:
            pass
        # if there is at least one criterion besides scene
        if len(criteria_list) >= 1:
            # concatenate the criteria from the dictionary together in a string (i.e. "key1": "value1", "key2: "value2")
            criteria_str = ""
            for i in criteria_list:
                key = i
                value = criteria_list[i]
                if len(value) > 0:
                    if len(criteria_str) > 0:
                        criteria_str += ', '
                    criteria_str += key + ': ' + value
            # add the concatenated criteria string it inside a string representing a data criteria json
            request_body = '{"GranuleCriteria": {' + criteria_str + '}}'
            try:
                response = requests.post(url, headers={'content-type': 'application/json'}, data=request_body)
                json_str = response.text
                # if the response body contains something
                if len(json_str) > 0:
                    json_obj = json.loads(json_str)
                    #return filter_by_scene(json_obj, data_criteria['scene_name'].split(','))
                    if data_criteria['scene_name']:
                        print(data_criteria['scene_name'].split(','))
                        json_obj=filter_by_scene(json_obj, data_criteria['scene_name'].split(','))
                        
                        if formatmetadata == True:
                            return format_metadata(json_obj)
                        else:
                            return json_obj
                    else:
                        if formatmetadata==True:
                            return format_metadata(json_obj)
                        else : 
                            return json_obj
                else:
                    print('INFO: There is no data matching the given criteria.')
                    logging.info('There is no data matching the given criteria.')
                    return {}
            except requests.exceptions.RequestException as e:
                print('ERROR: ' + str(e))
                logging.error(str(e))
        else:
            print('ERROR: You need to specify at least one search criteria besides scene name.')
            logging.error('You need to specify at least one search criteria besides scene name.')
    else:
        print('ERROR: The file "' + input_file + '" does not exist.')
        logging.error('The file "' + input_file + '" does not exist.')


# returns the string passed as parameter as a string representing a table (e.g. ["a", "b", "c"])
def to_table_string(string: str) -> str:
    string_to_return = string.replace(', ', ',').replace(',', '", "')
    return '["' + string_to_return + '"]'


def filter_by_scene(json_result, scene_list):

    for granule in json_result[:] : 
        scene = granule['Granule']['granuleScene']
        if scene:
            scene=granule['Granule']['granuleScene']['Granule']['name']
            print(scene)
            if not scene in scene_list : 
                json_result.remove(granule)
             
    return json_result

# download granule data(s) in a specified dir:
# granule_id: granuleID.
# target_Dir: directory the file(s) will be saved at".
def download_granule(granule_id: str, target_Dir: str) -> Iterable:
    try:
        response = requests.get(url + 'granulename/' + granule_id)
        json_str = response.text
        # if the response body contains something
        if len(json_str) > 0:
            json_obj = json.loads(response.text)
            for data in json_obj['Granule']['dataList'][:] :
                #print(target_Dir+'/'+data['Data']['fileName'])
                my_file = Path(target_Dir+'/'+data['Data']['fileName'])
                urlToData=''
                if my_file.is_file():
                    print(data['Data']['fileName']+' already exists in targetDir: '+ target_Dir)
                    logging.info(data['Data']['fileName']+' already exists in targetDir: '+ target_Dir)
                else:
                    urlToData = data['Data']['urlToData']
                    completeName = os.path.join(target_Dir, data['Data']['fileName'])
                    r = requests.get(urlToData, allow_redirects=True)
                    open(completeName, 'wb').write(r.content)
                    print(data['Data']['fileName']+' has been successfully downloaded in targetDir: '+ target_Dir)
                    logging.info(data['Data']['fileName']+' has been successfully downloaded in targetDir: '+ target_Dir)
                    
            return urlToData
        else:
            print('INFO: There is no data with ID: ' + granule_id)
            logging.info('There is no data with ID: ' + granule_id)
            return {}
    except requests.exceptions.RequestException as e:
        print('ERROR: ' + str(e))
        logging.error(str(e))





#########################################################################

# -*- coding: utf-8 -*-
class dataset:
    def __init__(self):
        """
        This class contains the dataset and all the auxiliary information"""
        self.campaign = ""
        self.scenes = []
        self.SLClist = {}
        self.SLCFilenames = {}
        self.heading={}
        self.z_flight={}
        self.z_terrain={}
        self.GRD_resol={}
        self.pixel_spacing = {}
        self.surface_resol = {}
        self.SLR_start = {}
        self.master = {}
        self.demname = {}
        self.demFilenames= {}
        self.incFilenames = {}
        self.kzFilenames = {}
        self.azimuthFiles = {}
        self.rangeFiles = {}
        
def get_url(collection,granulename):
    granule=get_granule_by_name(collection+':@'+granulename)
    datalist=granule['Granule']['dataList']
    
    url=datalist[0]['Data']['filePath']
    return(url)

def format_metadata(json_result):
    """Parse configuration xml and init dataset class"""
    import re
    
    
    # Init
    data_stack = dataset()
    print(len(json_result))
    if json_result and len(json_result) == 5:
        data_stack.campaign = json_result[0]['Granule']['collection']['Collection']['shortName']
        #if the research asked some specific scenes
        
        
            
        # All the data of the collections are returned and the scene list must be extract from the granules
        for granule in json_result :
            if granule['Granule']['productType']=='SLC':
                scene=granule['Granule']['granuleScene']['Granule']['name']   
                #add scene in the list avoiding duplicates
                
                
                ## inputfilenames
                polarisation=granule['Granule']['polarization']
                key=(scene,polarisation)
                value=granule['Granule']['name']
                url=get_url(data_stack.campaign,value)
                
                data_stack.SLClist.update(dict([(key,value)]))
                data_stack.SLCFilenames.update(dict([(key,url)]))
                if not scene in data_stack.scenes:
                    #append scenes and all metadata of the scene
                    data_stack.scenes.append(scene)            
                    
                    
                        
                    #### heading
                    keyval=dict([(scene,granule['Granule']['granuleScene']['Granule']['heading'])])
                    data_stack.heading.update(keyval)
                    #z_flight
                    keyval=dict([(scene,granule['Granule']['granuleScene']['Granule']['zFlight'])])
                    data_stack.z_flight.update(keyval)
                    ##z_terrain
                    keyval=dict([(scene,granule['Granule']['granuleScene']['Granule']['zTerrain'])])
                    data_stack.z_terrain.update(keyval)
                    ##GRD_resol
                    keyval=dict([(scene,granule['Granule']['granuleScene']['Granule']['grdResol'])])
                    data_stack.GRD_resol.update(keyval)
                    ##pixel_spacing
                    keyval=dict([(scene,granule['Granule']['granuleScene']['Granule']['pixelSpacing'])])
                    data_stack.pixel_spacing.update(keyval)
                    ##surface_resol
                    keyval=dict([(scene,granule['Granule']['granuleScene']['Granule']['surfaceResol'])])
                    data_stack.surface_resol.update(keyval)
                    
                    ##SLR_start
                    keyval=dict([(scene,granule['Granule']['granuleScene']['Granule']['slrStart'])])
                    data_stack.SLR_start.update(keyval)
                    
                    ##master
                    #search for the presence of az files in the file list of the granule
                    #bool_list=bool(re.search("az.tiff",data)) for data in granule['Granule']['granuleScene']['Granule']['granuleList']]                    
                    #if True in bool_list : 
                    keyval=dict([(scene,granule['Granule']['granuleScene']['Granule']['master'])])
                    data_stack.master.update(keyval)
                    ##demname
                    keyval=dict([(scene,granule['Granule']['granuleScene']['Granule']['dem'])])
                    data_stack.demname.update(keyval)
                    
                    ##demFilenames
                    demname=granule['Granule']['granuleScene']['Granule']['dem']
                    #if a dem is referenced, try to get its filename
                    if len(demname)>0:
                        try :
                            demfilename=get_url(data_stack.campaign,data_stack.campaign+'_'+demname+'_dem.tiff')
                            
                        except:
                            demfilename=''
                    else : 
                            demfilename=''
                    keyval=dict([(scene,demfilename)])
                    data_stack.demFilenames.update(keyval)
                    
                    ##azfilenames
                    #search for the presence of az files in the file list of the granule
                    bool_list=[bool(re.search("az.tiff",data)) for data in granule['Granule']['granuleScene']['Granule']['granuleList']]     
                    if True in bool_list :
                        azfile=granule['Granule']['granuleScene']['Granule']['granuleList'][bool_list.index(True)]
                        azfile=get_url(data_stack.campaign,azfile)
                    elif  granule['Granule']['granuleScene']['Granule']['master']!='n/a':
                        #get master name and get its azimtuh
                        master=granule['Granule']['granuleScene']['Granule']['master']
                        
                        if len(master)>0:
                            try : 
                                master_granules=get_granule_by_name(data_stack.campaign+':@'+master)['Granule']['granuleList']
                                
                                azfile=[file for file in master_granules if "az" in file][0]      
                                azfile=get_url(data_stack.campaign,azfile)
                            except: 
                                azfile=''
                        else:
                            azfile=''
                    else:
                        azfile=''
                    keyval=dict([(scene,azfile)])
                    data_stack.azimuthFiles.update(keyval)
                    
                    ##rgfilenames
                    bool_list=[bool(re.search("rg.tiff",data)) for data in granule['Granule']['granuleScene']['Granule']['granuleList']]     
                    if True in bool_list :
                        rgfile=granule['Granule']['granuleScene']['Granule']['granuleList'][bool_list.index(True)]
                        rgfile=get_url(data_stack.campaign,rgfile)
                    elif  granule['Granule']['granuleScene']['Granule']['master']!='n/a':
                        #get master name and get its azimtuh
                        master=granule['Granule']['granuleScene']['Granule']['master']
                        if len(master)>0:
                            try : 
                                master_granules=get_granule_by_name(data_stack.campaign+':@'+master)['Granule']['granuleList']
                                rgfile=[file for file in master_granules if "rg" in file][0]    
                                rgfile=get_url(data_stack.campaign,rgfile)
                            except: 
                                rgfile=''
                        else:
                            rgfile=''
                    else:
                        rgfile=''
                    keyval=dict([(scene,rgfile)])
                    data_stack.rangeFiles.update(keyval)
                    
                    ##incfilenames
                    bool_list=[bool(re.search("inc.tiff",data)) for data in granule['Granule']['granuleScene']['Granule']['granuleList']]     
                    if True in bool_list :
                        incfile=granule['Granule']['granuleScene']['Granule']['granuleList'][bool_list.index(True)]
                        incfile=get_url(data_stack.campaign,incfile)
                    elif  granule['Granule']['granuleScene']['Granule']['master']!='n/a':
                        #get master name and get its azimtuh
                        master=granule['Granule']['granuleScene']['Granule']['master']
                        if len(master)>0:
                            try : 
                                master_granules=get_granule_by_name(data_stack.campaign+':@'+master)['Granule']['granuleList']
                                incfile=[file for file in master_granules if "inc" in file][0] 
                                incfile=get_url(data_stack.campaign,incfile)
                            except: 
                                incfile=''
                        else:
                            incfile=''
                    else:
                        incfile=''
                    keyval=dict([(scene,incfile)])
                    data_stack.incFilenames.update(keyval)
                                   
                    ##kzfilenames
                    bool_list=[bool(re.search("kz.tiff",data)) for data in granule['Granule']['granuleScene']['Granule']['granuleList']]     
                    if True in bool_list :
                        kzfile=granule['Granule']['granuleScene']['Granule']['granuleList'][bool_list.index(True)]
                        kzfile=get_url(data_stack.campaign,kzfile)
                    else:
                        kzfile=''
                    keyval=dict([(scene,kzfile)])
                    data_stack.kzFilenames.update(keyval)
        return data_stack
