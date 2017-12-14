# Copy files to remote location.
# Tested in Python 2.7
# Make sure you can connect to your remote folder with certificate.
# This way you don't need to enter your credentials and you
# can schedule this script to run when you like
#
# You can contact me by e-mail at floris@entermi.nl.
#
# Last updated 1 December, 2017.
#
# Floris van Enter
# http://entermi.nl

scp -r /home/pi/scripts/wordpressUpdate/source/* user@server.remote.nl:/var/www/site1/
scp -r /home/pi/scripts/wordpressUpdate/source/* user@server.remote.nl:/var/www/site2/
scp -r /home/pi/scripts/wordpressUpdate/source/* user@server.remote.nl:/var/www/site3/
scp -r /home/pi/scripts/wordpressUpdate/source/* user@server.remote.nl:/var/www/site4/
scp -r /home/pi/scripts/wordpressUpdate/source/* user@server.remote.nl:/var/www/site5/