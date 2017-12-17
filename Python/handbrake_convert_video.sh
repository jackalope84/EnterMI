# Batch convert files in Handbrake CLI
# Tested in Python 2.7
# I used this script to convert video to AAC files to be served with my plex server
# For the conversion I use the Command Line version of the popular Handbrake
# This can be downloaded here: https://handbrake.fr/downloads2.php
#
# You can contact me by e-mail at floris@entermi.nl.
#
# Last updated 17 December, 2017.
#
# Floris van Enter
# http://entermi.nl
#!/bin/bash

SRC="/Users/floris/Downloads/do/"
DEST="/Users/floris/Downloads/done/"
DEST_EXT=mp4
HANDBRAKE_CLI=/Applications/HandBrakeCLI

for FILE in "$SRC"/*
do
    filename=$(basename "$FILE")
    extension=${filename##*.}
    filename=${filename%.*}
    $HANDBRAKE_CLI --preset 'HQ 1080p30 Surround' --input "$FILE" --output "$DEST"/"$filename".$DEST_EXT
done
