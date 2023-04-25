#!/usr/bin/python3
""" Download a copy from a sftp for the previous day or a date specified in parameter.
    Execute: fetch_files.py -p -d
    Requirements: pysftp, config
    Configuration: ./settings/sftp.toml
"""
__author__    = "Celine"
__copyright__ = "none"
__license__   = "None"
__version__   = "1.0.1"
__maintainer__= "Celine"
__email__     = ""
__status__    = "Production"

from datetime import datetime, timedelta
from pathlib import Path
import os
import sys, getopt
import sftp_config
import pysftp
import zipfile

### Main - Get parameters, if date is not provided default to yesterdady
### Build configuration details and execute sftp connection
def main(argv):
   connection = ''
   date_str = yesterday()

   try:
      opts, args = getopt.getopt(argv,"hp:d:",["connection=","date="])
   except getopt.GetoptError:
      print ('fetch_sftp_files.py -p <connections> -d <date>')
      sys.exit(2)

   for opt, arg in opts:
      if opt == '-h':
         print ('fetch_sftp_files.py -p <connection> -d <date>')
         sys.exit()
      elif opt in ("-p", "--connection"):
         connection = arg
      elif opt in ("-d", "--date"):
         date_str = arg

   if connection == "": 
        sys.exit(2)

   # Load configuration for specified connection
   conf_detail = sftp_config.load_config(connection)

   # formatting date per conf
   working_date = datetime.strptime(date_str, "%Y%m%d").strftime(conf_detail["dtformat"]) 

   print ('Engaging with connection ' + connection + ' for ' + working_date)
   establish_connection(conf_detail, working_date, connection)

def establish_connection(conf_detail, date, connection):
  basedir = os.path.abspath(os.path.dirname(__file__))
  cnopts = pysftp.CnOpts()
  hostkeys = None
  localpath = "/home/me/"
  my_list = [""]
  if cnopts.hostkeys.lookup(conf_detail["ip"]) == None:
    print("New host - will accept any host key")
    # Backup loaded .ssh/known_hosts file
    hostkeys = cnopts.hostkeys
    # And do not verify host key of the new host
    cnopts.hostkeys = None

  cnopts.hostkeys.load('/home/celine/.ssh/known_hosts')

  try:
      if conf_detail["password"] == "":
        conn = pysftp.Connection(host=conf_detail["ip"], port=conf_detail["port"], username=conf_detail["user"], private_key=basedir + '/keys/' + conf_detail["key"], cnopts=cnopts)
      elif conf_detail["key"] == "":
        conn = pysftp.Connection(host=conf_detail["ip"], port=conf_detail["port"], username=conf_detail["user"], password=conf_detail["password"], cnopts=cnopts)
      
      conn.log = True

      if hostkeys != None:
        print("SFTP: Connected to new host, caching its hostkey")
        hostkeys.add(conf_detail["ip"], conn.remote_server_key.get_name(), conn.remote_server_key)
        hostkeys.save(pysftp.helpers.known_hosts())

  except:
    print('EXCEPTION: failed to establish connection to targeted server ' + conf_detail["user"] + '@' + conf_detail["ip"] + " with password;" + conf_detail["password"] + " or id:" + basedir + '/keys/' + conf_detail["key"])

  print("SFTP: connection established successfully")
  current_dir = conn.pwd
  conn._transport.set_keepalive(10)

  for iin in conf_detail["path"]:
    try:
      conn.chdir(iin)
      ld = conn.listdir_attr()
      for whichfile in ld:
        if date in whichfile.filename:
            print("Downloading candidate: " + whichfile.filename)
            localfile_name = connection.upper() + "_" + whichfile.filename
            conn.get(whichfile.filename, os.path.join(localpath, localfile_name), preserve_mtime=True)
            my_list.append(localfile_name)
      conn.chdir("..")
    except IOError:
      print("Cannot find file")
  conn.close()
  
  # Zip files
  for f in my_list: 
    with zipfile.ZipFile(localpath + "/" +f + '.zip', 'w') as myzip:
      myzip.write(localpath + "/" + f)
      print(f)

def yesterday(frmt='%Y%m%d', string=True):
    yesterday = datetime.now() - timedelta(1)
    if string:
        return yesterday.strftime(frmt)
    return yesterday

if __name__ == "__main__":
   main(sys.argv[1:])
