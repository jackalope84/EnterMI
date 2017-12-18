# Retrieve location info from Google Maps
# Tested in Python 2.7
# I used this script to get all information about GPS coordinates.
# return Country,Town,Street or None when Google Maps breaks
# Sometimes Google gives an error by multiple requests
#
# You can contact me by e-mail at floris@entermi.nl.
#
# Last updated 18 December, 2017.
#
# Floris van Enter
# http://entermi.nl

import urllib.request
import json

# define the function
def getplace(lat, lon):
    lat = str(lat)
    lon = str(lon)
    url = "http://maps.googleapis.com/maps/api/geocode/json?"
    url += "latlng=%s,%s&sensor=false" % (lat, lon)
    v = urllib.request.urlopen(url).read()
    j = json.loads(v)

    # Sometimes Google gives no data, check
    try:
        components = j['results'][0]['address_components']
    except:
        # Return message that Google failed
        print('Google Shizzle')
        return None
    else:
        # Return data
        country = town = street = None
        for c in components:
            if "route" in c['types']:
                street = c['long_name']
            if "country" in c['types']:
                country = c['long_name']
            if "locality" in c['types']:
                town = c['long_name']

        print(lat + ", " + lon + " = " + str(country) + ", " + str(town) + ", " + str(street))
        return (str(country) + "," + str(town) + "," + str(street))

## Test runs
# print(getplace(47.591737, 2.759478))
# print(getplace(51.2, 0.1))
# print(getplace(51.3, 0.1))