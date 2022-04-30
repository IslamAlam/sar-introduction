# -*- coding: utf-8 -*-
"""
Created on Wed Dec  5 23:55:39 2018

@author: plousser

"""
import os, os.path, optparse, sys
import gdal

def quickL(inputFilename, quickLookBaseFilename, GRD_resol, Type, quickLookExtension):
    'Create and save a quick look of the input image'
    import os
    from matplotlib.backends.backend_agg import FigureCanvasAgg as FigureCanvas
    from matplotlib.figure import Figure
    from matplotlib.colors import LinearSegmentedColormap
    import numpy as np
    
    # Open original image in slant range geometry:
    input_image_driver = gdal.Open(inputFilename, 0)
    
    ratio = max(1, input_image_driver.RasterXSize // 1000, input_image_driver.RasterYSize // 1000) # Ratio of the reduction of the read image (to avoid memory errors) 
    input_image = input_image_driver.ReadAsArray(0, 0, None, None, None, input_image_driver.RasterXSize//ratio, input_image_driver.RasterYSize//ratio)
    
    # Define figure:
    fig = Figure()
    canvas = FigureCanvas(fig)
    ax = fig.add_subplot(111)
    
    # Define custom color map:
    if Type == 'biomass':
        customCmap = LinearSegmentedColormap.from_list('biomass', ['#F5F5DC', 'g', '#004500'])
    if Type == 'height':
#        customCmap = LinearSegmentedColormap.from_list('height', ['#F5F5DC', '#966F33', '#452400'])
        customCmap = 'jet'
    if Type== 'sig':
        customCmap='gray'
        
    # Display image:
    if Type =='sig':
        cax = ax.imshow(input_image, cmap=customCmap, vmin=0,vmax=np.nanpercentile(input_image,90),extent=(0, input_image_driver.RasterXSize*GRD_resol, 0, input_image_driver.RasterYSize*GRD_resol))
    else : 
        cax = ax.imshow(input_image, cmap=customCmap, extent=(0, input_image_driver.RasterXSize*GRD_resol, 0, input_image_driver.RasterYSize*GRD_resol))
   
    # Set figure Layout:
    if len(gdal.Open(inputFilename).GetProjection())>0 :
        ax.set_xlabel('Longitude (m)')
        ax.set_ylabel('Latitude (m)')
    else :
        ax.set_xlabel('')
        ax.set_ylabel('')
    cbar = fig.colorbar(cax)
    if Type == 'biomass':
        cbar.set_label('Biomass (ton/ha)')
    if Type == 'height':
        cbar.set_label('Height (m)')
    if Type== 'sig':
        cbar.set_label('Backscattering')
    ax.set_title(os.path.basename(quickLookBaseFilename) + '.tiff\n')
    
    # Save figure:
    canvas.print_figure(quickLookBaseFilename + '_' + Type + '_QL.' + quickLookExtension, dpi=150, bbox_inches='tight')
    
    # Close image data set:
    input_image_driver = None
    
###########################################################################
class OptionParser (optparse.OptionParser):
 
    def check_required (self, opt):
        option = self.get_option(opt)
 
        # Assumes the option's 'default' is set to None!
        if getattr(self.values, option.dest) is None:
            self.error("%s option not supplied" % option)
 
               

##########################################################################                
            
if __name__ == '__main__':
    
      #==================
    #parse command line
    #==================
    if len(sys.argv) == 1:
        prog = os.path.basename(sys.argv[0])
        print ("      "+sys.argv[0]+' [options]')
        print ("     Aide : ", prog, " --help")
        print ("        ou : ", prog, " -h")
        print ("example 1 : python %s -i inputdir/ -o outputdir/"%sys.argv[0])
        
        sys.exit(-1)
    else :
        usage = "usage: %prog [options] "
    parser = OptionParser(usage=usage)
  

    parser.add_option("-i", "--inputfile", dest="inputfile", action="store", type="string", \
            help="Path to the input file",default='.')
    parser.add_option("-g", "--grdresol", dest="grdresol", action="store", type="float", \
            help="GRD resol",default=2)
    parser.add_option("-q", "--qlextension", dest="qlextension", action="store", type="choice", \
            help="Output extension format",choices=['png','jpg','eps'],default='png')
    parser.add_option("-t", '--type', dest="type", action="store", type="choice", \
            help="Quicklook type",choices=['biomass','height','sig'],default='png')
    
    (options, args) = parser.parse_args()

    quickL(options.inputfile, options.inputfile.replace('.tiff','quicklook'), options.grdresol, options.type, options.qlextension) 

