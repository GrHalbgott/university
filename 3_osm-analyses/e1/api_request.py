# Count number of elements
import requests
URL = 'https://api.ohsome.org/v1/elements/count'
data = {
    "bboxes": "8.625,49.3711,8.7334,49.4397",
    "format": "json",
    "time": "2014-01-01",
    "filter": "building=* and type:way"
}
response = requests.post(URL, data=data)
print(response.json())

# Sum area of elements
import requests
URL = 'https://api.ohsome.org/v1/elements/area'
data = {
    "bboxes": "8.625,49.3711,8.7334,49.4397",
    "format": "json",
    "time": "2016-01-01/2022-01-01/P1Y",
    "filter": "landuse=farmland and type:way"
}
response = requests.post(URL, data=data)
print(response.json())

# Metadata (check upload date)
import requests
URL = 'https://api.ohsome.org/v1/metadata'
response = requests.get(URL)
print(response)