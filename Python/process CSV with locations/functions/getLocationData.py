import urllib.request
import json

def getplace(lat, lon):
    lat = str(lat)
    lon = str(lon)
    url = "http://maps.googleapis.com/maps/api/geocode/json?"
    url += "latlng=%s,%s&sensor=false" % (lat, lon)

    v = urllib.request.urlopen(url).read()
    j = json.loads(v)
    try:
        components = j['results'][0]['address_components']
    except:
        #print(lat + '  -  ' + lon)
        #print('## Google Shizzle ##')
        return None
    else:
        country = town = street = None
        for c in components:
            if "route" in c['types']:
                street = c['long_name']
            if "country" in c['types']:
                country = c['long_name']
            if "locality" in c['types']:
                town = c['long_name']

        return (str(country) + "," + str(town) + "," + str(street))


# print(getplace(47.591737, 2.759478))
# print(getplace(51.2, 0.1))
# print(getplace(51.3, 0.1))

#print(getplace("60°04'52.3N", "14°09'13.7E"))