# Copy Music library via SSH
# Tested in Python 2.7
# I used this script to copy music files from my external thunderbolt disk
# via SSH to a plex server running on a Raspberry Pi with usb disk
#
# You can contact me by e-mail at floris@entermi.nl.
#
# Last updated 17 December, 2017.
#
# Floris van Enter
# http://entermi.nl

#!/bin/bash

SRC="/Volumes/thunderbolt/iTunes/Music/"
DEST="/media/zilveren/music/"

rsync -avz -e ssh pi@raspberry:$DEST $SRC