import json
import time
import os
from openrouteservice import client

infile = "../data/e8_pharmacy.geojson"
with open(infile) as f:
    pharmacies = json.load(f)

# Make sure to get your own openrouteservice api key.
api_key = "5b3ce3597851110001cf62484be61c9e4af844fcb284c0cdb702c4a3"
ors_client = client.Client(key=api_key)

# Define the time range in seconds.
time_range = [
    300,  # 5 min
    900,  # 15 min
    1800,  # 30 min
]

# For each pharmacy we will derive the isochrones.
for i, pharmacy in enumerate(pharmacies["features"]):
    # There is a rate limit defined by the ORS API
    # With our "free" api key, we can send max 20 request / minute.
    # Thus we "sleep" here for some time.
    if i > 0 and i % 20 == 0:
        print(f"#{i}: sleeping...")
        time.sleep(60)  
    
    # Get the coordinates from the geometry.
    point_coordinates = pharmacy["geometry"]["coordinates"]
    
    # Define the request parameters.
    iso_params = {
        "locations": [point_coordinates],
        "profile": "foot-walking",
        "range_type": "time",
        "range": time_range,  
    }
    
    # Do the request.
    request = ors_client.isochrones(**iso_params)
    
    # Save results into a geojson file.
    if not os.path.exists("./e8/exports/"):
        os.makedirs("./e8/exports/")
    outfile = f"./e8/exports/isochrones_{i}.geojson"
    with open(outfile, 'w') as f:
        json.dump(request, f)