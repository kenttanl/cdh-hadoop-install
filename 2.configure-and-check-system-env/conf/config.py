#!/usr/bin/python
#Port is not used
import sys
config={
    # if Manager_IP is '',we will take the local server as Manager.
    # for example -> 'Manager_IP':'10.1.41.231'
	'Manager_IP':''
	# if username is '', we will take the current login as user
	,'username':'kent'
	 # if password is '', we will require you input password during the execution of the script
	,'password':'xxxxxx'
}

def usage():
    print "config [externalIPPattern||||||||]"
if ( len(sys.argv) == 1 ):
    usage()
elif( len(sys.argv) <> 2 ):
    usage()
elif( len(sys.argv) == 2 ):
    print config[sys.argv[1]]
else:
    exit(1)
