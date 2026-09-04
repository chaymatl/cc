import urllib.request, sys
try:
    urllib.request.urlopen('http://127.0.0.1:8000/docs', timeout=3)
    sys.exit(0)
except:
    sys.exit(1)