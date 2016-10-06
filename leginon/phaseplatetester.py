#!/usr/bin/env python
from leginon import leginondata
from leginon import acquisition
import gui.wx.PhasePlateTester
import gui.wx.PhasePlateTestImager

def setImageFilename(imagedata, phase_plate_number, patch_position=None):
	acquisition.setImageFilename(imagedata)
	imagedata['filename'] += '_ph%d' % (phase_plate_number)
	if patch_position:
		imagedata['filename'] += '_p%d' % (patch_position)
	
class PhasePlateTestImager(acquisition.Acquisition):
	panelclass = gui.wx.PhasePlateTestImager.Panel
	settingsclass = leginondata.PhasePlateTestImagerSettingsData
	defaultsettings = acquisition.Acquisition.defaultsettings
	defaultsettings.update({
		'phase plate number': 1,
		})
	eventinputs = acquisition.Acquisition.eventinputs
	eventoutputs = acquisition.Acquisition.eventoutputs
	test_type = 'low mag image'
	patch_position = None

	def __init__(self, id, session, managerlocation, **kwargs):
		acquisition.Acquisition.__init__(self, id, session, managerlocation, **kwargs)
		self.patch_position = None

	def setImageFilename(self, imagedata):
		setImageFilename(imagedata,self.settings['phase plate number'],None)

	def getImageComment(self):
		comment_str = 'Phase Plate %d' % (self.settings['phase plate number'])
		return comment_str

	def publishStats(self, imagedata):
		'''
		Use publishStats to also insert PhasePlateTestLogData and ImageCommentData.
		'''
		if not imagedata:
			self.logger.error('No imagedata to log and publish stats')
			return
		# associate image with phase plate patch
		logdata = leginondata.PhasePlateTestLogData()
		logdata['tem'] = imagedata['scope']['tem']
		logdata['test type'] = self.test_type 
		logdata['phase plate number'] = self.settings['phase plate number']
		logdata['patch position'] = self.patch_position
		logdata['image'] = imagedata
		logdata.insert()
		# add comment to image
		commentdata = leginondata.ImageCommentData(session = self.session, image=imagedata)
		commentdata['comment'] = self.getImageComment()
		commentdata.insert()
		# publish Stats
		status = super(PhasePlateTestImager, self).publishStats(imagedata)

class PhasePlateTester(PhasePlateTestImager):
	panelclass = gui.wx.PhasePlateTester.Panel
	settingsclass = leginondata.PhasePlateTesterSettingsData
	defaultsettings = acquisition.Acquisition.defaultsettings
	defaultsettings.update({
		'phase plate number': 1,
		'total positions': 48,
		'start position': 1,
		})
	eventinputs = acquisition.Acquisition.eventinputs
	eventoutputs = acquisition.Acquisition.eventoutputs
	test_type = 'patch state'

	def __init__(self, id, session, managerlocation, **kwargs):
		acquisition.Acquisition.__init__(self, id, session, managerlocation, **kwargs)
		self.patch_position = self.settings['start position']

	def acquire(self, presetdata, emtarget=None, attempt=None, target=None, channel=None):
		for i in range(self.settings['total positions']):
			self.logger.info('Acquiring on patch %d of phase plate %d' % (self.patch_position, self.settings['phase plate number']))
			status = super(PhasePlateTester, self).acquire(presetdata, emtarget, attempt, target, channel)
			if status == 'error':
				self.logger.error('Acquire failed, aborting test')
				return status
			# working
			state = self.player.state()
			if state == 'pause':
				self.setStatus('user input')
				self.logger.info('Waiting for user before advance patch')
				state = self.player.wait()
			if state in ('stop', 'stopqueue'):
				self.setStatus('idle')
				status = 'aborted'
				break
			self.nextPhasePlate()
		return status

	def uiSetStartPosition(self):
		if self.settings['start position'] > self.settings['total positions']:
			self.logger.error('Bad patch start position specified')
			return False
		self.patch_position = self.settings['start position']
		return True

	def nextPhasePlate(self):
		self.setStatus('processing')
		self.logger.info('Waiting for scope to advance PP')
		self.instrument.tem.nextPhasePlate()
		self.setStatus('idle')
		# advance number
		self.patch_position += 1
		if self.patch_position > self.settings['total positions']:
			self.patch_position = 1
		self.logger.info('Done with advancing PP')

	def setImageFilename(self, imagedata):
		setImageFilename(imagedata,self.settings['phase plate number'],self.patch_position)

	def getImageComment(self):
		comment_str = 'Phase Plate %d' % (self.settings['phase plate number'])
		if self.patch_position:
			comment_str += 'Patch %d' % (self.patch_position)
		return comment_str
