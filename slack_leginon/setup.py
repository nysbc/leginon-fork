from distutils.core import setup

setup(
	name='slack_leginon',
	version='0.2.0',
	description='slack client hook for leginon',
	packages=['slack_leginon'],
	package_dir={'slack_leginon': ''},
	scripts = ['slack_test.py',],
)
