#!/usr/bin/env python

import numpy
from pyami import mrc,imagefun
from appionlib import apDDprocess,apDisplay

try:
	#The tifffile module only works with python 2.6 and above
	from pyami import tifffile
except:
	apDisplay.printError('Need tifffile to use apDEprocess module')

# testing options
save_jpg = False
debug = False
ddtype = 'thin'

class DEProcessing(apDDprocess.DirectDetectorProcessing):
	def __init__(self,wait_for_new=False):
		super(DEProcessing,self).__init__(wait_for_new)
		self.setDefaultDimension(4096,3072)
		self.correct_dark_gain = True
		
	def getNumberOfFrameSavedFromImageData(self,imagedata):
		return imagedata['camera']['nframes']

	def getFrameNameFromNumber(self,frame_number):
		return 'RawImage_%d.tif' % frame_number

	def readFrameImage(self,frameimage_path,offset,crop_end,bin):
		tif = tifffile.TIFFfile(frameimage_path)
		a = tif.asarray()
		a = self.modifyFrameImage(a,offset,crop_end,bin)
		return a[:,::-1]

if __name__ == '__main__':
	dd = DEProcessing()
	dd.setImageId(1640790)
	start_frame = 0
	nframe = 5
	corrected = dd.correctFrameImage(start_frame,nframe)
	mrc.write(corrected,'corrected_frame%d_%d.mrc' % (start_frame,nframe))