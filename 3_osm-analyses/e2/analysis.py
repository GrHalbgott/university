import geopandas as gpd
import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
import utils

outfile = "./export/e2/results.txt"
gpkg_path = "./data/e2/changesets.gpkg"

try:
    df = gpd.read_file(gpkg_path, layer='changesets_centroids')
    output = open(outfile, "w")
    output.write(str(df))
    output.close()
except:
    print("Make sure that you download the geopackage file.")

# count number of changesets
changesets_count = len(df)

# count number of changes
changes_sum = df["num_changes"].sum()

# count unique users
unique_users_count = df["user_id"].nunique()

df_users = df.groupby("user_id").agg({
    "user_id": 'count',  # the number of changesets per user
    "num_changes": 'sum'  # the overall number of changes per user
})

# ensure your arr is sorted from lowest to highest values first
df_users.sort_values(
    "num_changes",  # sort by the overall number of changes
    inplace=True,  # change existing dataframe
    ascending=True  # show users with lowest activity at the top
)

# write results tp file
output = open(outfile, "a")
output.write(f"\n\n----------\n\n")
output.write(str(df_users))
output.write(f"\nNumber of changesets: {changesets_count}\n")
output.write(f"Number of changes: {changes_sum}\n")
output.write(f"Number of unique users: {unique_users_count}")
output.close()


# -------------------------
# -------------------------


gini_coefficient = utils.gini(
    df_users["num_changes"].values  # we need an array
)
print(f"Gini coefficient: {gini_coefficient}")

# calculate lorenz curve
lorenz_curve = utils.lorenz(
    df_users["num_changes"].values  # we need an array
)

# we need the X values to be between 0.0 to 1.0
plt.plot(np.linspace(0.0, 1.0, lorenz_curve.size), lorenz_curve)
plt.plot([0,1], [0,1])  # plot the straight line perfect equality curve

plt.title("contribution inequality based on changesets")
plt.xlabel("share users")
plt.ylabel("share changes")
plt.grid()
plt.show()

# define keyword that we'll use to filter
keyword = "hotosm"

# filter by user_names defined in csv file
df_filtered_hotosm = df[
    df["comment"].str.contains(
        keyword,
        case=False,  # case insensitive
        na=False  # ignore changesets without comments
    )
]

plt.scatter(
    df_filtered_hotosm["geometry"].x,  # get x coordinate from geometry
    df_filtered_hotosm["geometry"].y,  # get y coordinate from geometry
    alpha=0.01  # make sure to use a very low value here to avoid too much overplotting
)
plt.title("hotosm")
plt.show()

# write filtered dataframe to geopackage
df_filtered_hotosm.to_file(
    gpkg_path,
    layer="changesets_hotosm_centroids",
    driver="GPKG"
)
output = open(outfile, "a")
output.write(f"hot users: {df_filtered_hotosm['user_id'].nunique()}")
output.close()


# -------------------------
# -------------------------


files = [
    "./data/e2/facebook_users.csv",
    "./data/e2/apple_users.csv"
]

for file in files:
    corporate_mappers_df = pd.read_csv(file)

    # filter by user_names defined in csv file
    df_filtered = df[
        df["user_name"].isin(corporate_mappers_df["user_name"])
    ]
    
    plt.scatter(
        df_filtered["geometry"].x,  # get x coordinate from geometry
        df_filtered["geometry"].y,  # get y coordinate from geometry
        alpha=0.01  # make sure to use a very low value here to avoid too much overplotting
    )
    plt.title(file)
    plt.show()

    #write filtered dataframe to geopackage
    df_filtered.to_file(
        gpkg_path,
        layer="changesets_facebook_centroids",
        driver="GPKG"
    )

    print(f"{file}: {df_filtered['user_id'].nunique()}")
