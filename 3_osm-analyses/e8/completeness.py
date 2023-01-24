import geopandas as gpd
import matplotlib.pyplot as plt
from ohsome import OhsomeClient

ohsome_client = OhsomeClient()

bpolys = gpd.read_file("../data/e8_heidelberg.geojson")

# Define monthly time range and filter.
time = "2008-01-01/2023-01-01/P1M"
filter_str = "amenity=pharmacy"

# Guery ohsome API endpoint to get counts.
response = ohsome_client.elements.count.post(
    bpolys=bpolys,
    time=time,
    filter=filter_str
)

# Get response as dataframe.
results_df = response.as_dataframe()

# Create plot.
plt.figure()
plt.plot(
    results_df["value"]
)

plt.title(f"Temporal evolution of pharmacies in OSM in Heidelberg.")
plt.savefig(f"temporal_evolution.png")
plt.show()