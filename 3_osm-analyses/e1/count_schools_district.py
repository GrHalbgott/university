import json
import matplotlib.pyplot as plt
import pandas as pd
from ohsome import OhsomeClient
client = OhsomeClient()

infile = "./data/berlin_districts.geojson"
with open(infile) as f:
    boundaries = json.load(f)
    
filter_schools = "amenity=school"
response = client.elements.count.groupByBoundary.post(
    bpolys=json.dumps(boundaries), 
    filter=filter_schools
)

schools_df = response.as_dataframe()
schools_df.to_csv('data.csv')
# display(schools_df)