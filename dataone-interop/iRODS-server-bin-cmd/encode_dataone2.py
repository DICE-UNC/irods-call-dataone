#!/usr/bin/python

import sys, urllib

print urllib.quote(sys.argv[1], ":"),

sys.exit(0)
