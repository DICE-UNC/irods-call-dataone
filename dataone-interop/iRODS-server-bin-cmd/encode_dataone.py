#!/usr/bin/python

import sys, urllib

# escape ':' for isDocumentedBy: SOLR query
# ' ', ':', '/', '\' chars considered "safe" 
print urllib.quote(sys.argv[1].replace(":", "\\:"), " :/\\"),

sys.exit(0)
