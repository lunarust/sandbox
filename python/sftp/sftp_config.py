#!/usr/bin/python3
""" Parse configuraiton file
    Execute: called by fetch_sftp_files.py
    Requirements: pathlib, toml
    Configuration: ./settings/sftp.toml
"""
__author__    = "Celine"
__copyright__ = "None"
__license__   = "None"
__version__   = "1.0.1"
__maintainer__= "Celine"
__email__     = ""
__status__    = "Production"


from pathlib import Path
import os
import toml

def load_config(connection_name):

	basedir = os.path.abspath(os.path.dirname(__file__))
	# print(basedir)
	# Read local `config.toml` file.
	config = toml.load(basedir + '/settings/sftp.toml')

	# Retrieving a dictionary of values
	myconnection = config['connections'][connection_name]

	# print(myconnection)
	return myconnection