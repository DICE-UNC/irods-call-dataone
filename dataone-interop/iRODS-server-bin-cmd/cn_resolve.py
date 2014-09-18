#!/usr/bin/python

import sys, urllib, urllib2
import xml.dom.minidom

class NoRedirectHandler(urllib2.HTTPRedirectHandler):
    def http_error_302(self, req, fp, code, msg, headers):
        infourl = urllib.addinfourl(fp, headers, req.get_full_url())
        infourl.status = code
        infourl.code = code
        return infourl
    http_error_300 = http_error_302
    http_error_301 = http_error_302
    http_error_303 = http_error_302
    http_error_307 = http_error_302

opener = urllib2.build_opener(NoRedirectHandler())
urllib2.install_opener(opener)

# Make remote call and parse as xml
f = urllib2.urlopen(sys.argv[1])

xmldoc = xml.dom.minidom.parse(f)
f.close

for ID in xmldoc.getElementsByTagName('url'):
    print ID.firstChild.nodeValue

sys.exit(0)

