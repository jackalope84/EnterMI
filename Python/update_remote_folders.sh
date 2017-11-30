# Make sure you can connect to your remote folder with certificate.
# This way you don't need to enter your credentials and you
# can schedule this script to run when you like

scp -r /home/pi/scripts/wordpressUpdate/source/* user@server.remote.nl:/var/www/site1/
scp -r /home/pi/scripts/wordpressUpdate/source/* user@server.remote.nl:/var/www/site2/
scp -r /home/pi/scripts/wordpressUpdate/source/* user@server.remote.nl:/var/www/site3/
scp -r /home/pi/scripts/wordpressUpdate/source/* user@server.remote.nl:/var/www/site4/
scp -r /home/pi/scripts/wordpressUpdate/source/* user@server.remote.nl:/var/www/site5/