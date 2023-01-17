import json
from datetime import datetime
import requests

base_url = "https://api.ohsome.org/v1"
endpoint = "/elements/count/groupBy/boundary"
url = base_url + endpoint

# open geojson file
with open("./data/berlin_districts.geojson", "r") as file:
    bpolys = json.load(file)

parameters = {
    "bpolys": json.dumps(bpolys),  # pass GeoJSON as string.
    "filter": "amenity=school",
    "format": "json",
    "time": "2022-01-01",
}

response = requests.post(url, data=parameters)
response.raise_for_status()  # Raise an Exception if HTTP Status Code is not 200

print("Response:")
print(json.dumps(response.json(), indent=4))  # Pretty print response

result = response.json()["groupByResult"]