import geopandas as gpd
from ohsome import OhsomeClient
client = OhsomeClient()

# load the geojson file with geopandas
bpolys = gpd.read_file("../data/e4_lengths.geojson")
# bpolys.set_index("region", inplace=True)

# Define which OSM features should be considered.
filter_roads = "highway in (motorway, motorway_link, trunk, trunk_link, primary, primary_link, secondary, secondary_link) and type:way"

# Here we do not set the timestamps parameters.
# This defaults to the most recent timestamp available.
response = client.elements.length.groupByBoundary.post(
    bpolys=bpolys, 
    filter=filter_roads
)

# display results as dataframe
results_df = response.as_dataframe()

# join input dataframe and results dataframe
results_df.reset_index(inplace=True)
results_df.set_index("boundary", inplace=True)
join_df = bpolys.join(results_df)

# calculate difference between OS road length and OSM road length
join_df["difference"] = join_df["value"] - join_df["road_length_sum"]

# calculate ratio between OS road length and OSM road length
# here we calculate to what extend OSM covers the OS roads
# <1 => less OSM roads than OS
# 1 => OSM roads and OS roads are almost the same
# >1 => more OSM roads than OS 
join_df["ratio"] = join_df["value"] / join_df["road_length_sum"]

join_df.to_file("../data/lengths2.geojson", driver='GeoJSON')