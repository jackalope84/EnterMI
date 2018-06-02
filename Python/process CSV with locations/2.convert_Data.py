# Rework the result of 1.Get_Data.py to Laravel migration
# Tested in Python 2.7
# I used this script to create text files which content I past in a Laravel
# project, database migrations file. After reworking the data gets moved to an archive
# file to prevent duplicating data.
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

todo = open('./done.log','r')
archive = open('./archive.log','a')

writeFile = open('./write/export_' + time.strftime("%Y%m%d-%H%M%S") + '.txt', 'w')
tagsCheck = []

todoLine = todo.readline()

query = 'DB::statement("INSERT IGNORE INTO `sources` SET '
query += "`name` = 'source name', `nickname` = 'source', `link` = 'http://example.com', `user_id`=1"
query += '");'

writeFile.write(query + "\n\n")

while todoLine:
    contents = todoLine.replace('\n','').strip().split(';')
    tags = []

    lat = contents[0]
    lon = contents[1]
    date = contents[2]
    name = contents[3]
    if 'wild' in name:
        wild = str(1)
    else:
        wild = str(0)
    country = contents[4]
    note = "Found at " + contents[5] + ", " + contents[6] + " export from Garmin Basecamp"

    query = 'DB::statement("INSERT INTO `locations` (`user_id`, `source_id`, `wild`, `name`, `country`, `lon`, `lat`, `note`, `visits`, `created_at`, `updated_at`) VALUES ('
    query += "1, (SELECT `id` FROM `sources` WHERE `link`= 'http://example.com'), " + wild + ", '" + name + "', (SELECT `code` FROM `countries` WHERE `name` = '" + country + "'), '" + lon + "', '" + lat + "', '" + note + "', 0, NOW(), NOW())"
    query += '");'

    writeFile.write(query + "\n")

    todoLine = todo.readline()

writeFile.close()
todo.close()
todo = open('./done.log','r')
todoLine = todo.readline()
while todoLine:
    archive.write(todoLine)
    todoLine = todo.readline()

todo.close()
archive.close()

newFile = open('./done.log','w')
newFile.close()