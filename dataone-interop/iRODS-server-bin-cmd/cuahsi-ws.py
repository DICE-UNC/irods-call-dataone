#!/usr/bin/python

import sys, urllib, os

## HOWTO INSTALL 
##
## Get SOAP client lib from https://fedorahosted.org/releases/s/u/suds/python-suds-0.4.tar.gz
## Unpack it to same directory as this script

absdirpath = os.path.abspath(os.path.dirname (sys.argv[0]))
sys.path.append (absdirpath + '/python-suds-0.4')
from suds.client import Client

url = 'http://river.sdsc.edu/wateroneflow/NWIS/DailyValues.asmx?WSDL'

#
# stdin:  location (site number),
#         "00060",
#         start date
#         end date
#         path to output file
# stdout: nothing
#
if (len (sys.argv) != 5 + 1):
  print "Arguments: <location> <variable> <start date> <end date> <path to output file> e.g., NWIS:10263500 NWIS:00060 2005-08-01 2006-08-01 /tmp/wsResult"
  sys.exit (1)

# print client ## will print out methods
client = Client(url)

# call WaterOneFlow GetValues web service
# http://river.sdsc.edu/wateroneflow/NWIS/DailyValues.asmx?op=GetValues
# GetValues(xs:string location, xs:string variable, xs:string startDate, xs:string endDate, xs:string authToken, )
#
# sample values at http://river.sdsc.edu/wiki/Default.aspx?Page=USGS%20NWIS%20webservices&NS=&AspxAutoDetectCookieSupport=1

result = client.service.GetValues (sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4])

file = open (sys.argv[5], 'w')
file.write (result)
file.closed

