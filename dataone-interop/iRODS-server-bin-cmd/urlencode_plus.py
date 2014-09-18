#!/usr/bin/python

import sys, urllib

print urllib.quote_plus(sys.argv[1]),

sys.exit(0)
