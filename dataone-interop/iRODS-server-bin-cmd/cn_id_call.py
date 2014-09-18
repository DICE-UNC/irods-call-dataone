#!/usr/bin/python

import sys, urllib
import xml.dom.minidom

# Make remote call and parse as xml
f = urllib.urlopen(sys.argv[1])
xmldoc = xml.dom.minidom.parse(f)
f.close

# Print content of <identifier> nodes
for ID in xmldoc.getElementsByTagName('identifier'):
    print ID.firstChild.nodeValue

sys.exit(0)

