# Get an export with GPS data, get more info and save result
# Tested in Python 2.7
# I used this script to get more Google Maps data from an export with coordinates
# from BaseCamp. This way I can periodically export data from BaseCamp and import in a
# database so I can use it in Web Apps.
# After script 1, script 2 must be run
#
# You can contact me by e-mail at floris@entermi.nl.
#
# Last updated 02 June, 2018.
#
# Floris van Enter
# http://entermi.nl

#!/bin/bash

import random
import shutil
import time
from functions.VanlifelocationJunk import *
from functions.getLocationData import getplace
from functions.convertGPS import parse_dms

todo = open('./locations.csv','r')
done = open('./done.log','a')
check = open('./done.log','r').read()
archived = open('./archive.log','r').read()

cntError = 0
cntDone = 0
cntArchive = 0
cntSuccess = 0
cntShizzle = 0

tagsCheck = []

def rand_string(length, char_set='ABCDEFGHIJKLMNOPQRSTUVWXYZ01234567889'):
    return ''.join( random.choice(char_set) for _ in range(length) )

todoLine = todo.readline()

while todoLine:
    contents = todoLine.split(',')
    lat = contents[1][:12]
    lon = contents[2][:12]

    if (lat != 'lat'):
        if (lat + ';' + lon) in check:
            cntDone += 1
        elif  (lat + ';' + lon) in archived:
            cntArchive += 1
        else:
            places = getplace(lat,lon)
            if places != 'Google Shizzle' and places != None:
                places = places.split(',')
                date = contents[4].split('T')[0]
                name = contents[7].replace('"','')

                done.write(lat + ';' + lon + ';' + date + ';' + name + ';' + places[0] + ';' + places[1] + ';' + places[2] + '\n')
                cntSuccess += 1
            elif places == None:
                cntShizzle += 1

    todoLine = todo.readline()

print("----------------------")
print("        result        ")
print("----------------------")
print("Google shizzle: " + str(cntShizzle))
print("success:        " + str(cntSuccess))
print("error:          " + str(cntError))
print("done:           " + str(cntDone))
print("archived:       " + str(cntArchive))
print("")