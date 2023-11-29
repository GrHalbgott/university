# Network Analysis using betweenness centrality calculation

This is the repository for the code required by the final assignment of the Advanced Geoscripting course (summer semester 2023), a betweenness centrality calculation with different methods, including the geographically informed betweenness calculation (GIBC).

For more information, look into the [Assignment readme](./assignment.md).

![Example image with graph on the left and GIBC on the right](img/example.png)

## Prerequisites

- [Mamba](https://mamba.readthedocs.io/en/latest/index.html) (recommended) or [Conda](https://docs.conda.io/en/latest/)

## Installation

### 1. Download this repository

```console
$ git clone https://courses.gistools.geog.uni-heidelberg.de/pd281/advgeo23.git
$ cd advgeo23
```

### 2. Setup new virtual environment with all necessary dependencies

```console
$ [mamba or conda] env create -f environment.yml
$ [mamba or conda] activate advgeo
$ poetry install
```
Poetry will detect and respect an existing virtual environment that has been externally activated and will install the dependencies into that environment.

To update the packages to their latest suitable versions (and the poetry.lock file), run:
```console
$ poetry update
```

## Data (optional)

### AOI file

If you have an area of interest in the format GeoJSON, GeoPackage or ESRI Shapefile, you can put it into the `./data` folder.
It will be read automatically as long as you don't specify the `-skip` flag (see below).

### Population file

To acquire the population file needed to calculate random routes based on the population distribution, follow these steps:

1. Navigate to the [Global Human Settlement Layer](https://ghsl.jrc.ec.europa.eu/download.php?ds=pop) (note the product name GHS-POP)
2. On the left side, select the desired parameters (epoch, resolution and CRS), e.g. 2020, 100 m, Mollweide
3. Select your tile of interest, e.g. R4_C19 for Germany
4. Unzip the downloaded TIF file and put it in the folder `./data/`

[Example file](https://jeodpp.jrc.ec.europa.eu/ftp/jrc-opendata/GHSL/GHS_POP_GLOBE_R2023A/GHS_POP_E2030_GLOBE_R2023A_54009_100/V1-0/tiles/GHS_POP_E2030_GLOBE_R2023A_54009_100_V1_0_R4_C19.zip) for Southwest Germany

To use this in the program, you have to specifiy the `-pop` flag (see below).

## Run program

**Example**:

```console
$ python src/main.py -aoi Heilbronn -m gibc -n 250 -pop
```
This will calculate the **geographically informed betweenness centrality** for **250** random routes **based on the population distribution** in **Heilbronn, Germany** (skipping aoi file because none is found), using **fastest** (default with gibc) route types. The resulting files will be stored under **`./output/`** (default). The results can be seen [above](./README.md#network-analysis-using-betweenness-centrality-calculation).

**Usage**:

```console
$ python src/main.py -h

usage: main.py [-h] -aoi Area of interest [-skip] [-pop] [-n Number of routes] [-m Method] [-rt Route type] [-out Output directory]

Calculate betweenness centrality. You can use the following options to adapt the calculation to your needs. Have fun!

required arguments:
-aoi Area of interest  String | Name of the aoi (geocode or name of file)

optional arguments:
-skip                  Flag    | Use this to skip the aoi file in the data folder and query the -aoi instead.
-pop                   Flag    | Use this to use the population file (TIF file) to create random points depending on population density (during GIBC).
-n Number of routes    Integer | Number of routes to be calculated. Default value: 100
-m Method              String  | Method to calculate centrality {networkx/nx or geographical/gibc}. Default value: nx
-rt Route type         String  | Route type used for the calculation {shortest, fastest}. Default value: shortest
-out Output directory  String  | Name of output directory. Default value: output
```

## Testing

In order to run the tests in `./src/tests/`, you will need to install pytest into the environment:
```console
$ [mamba or conda] install -n advgeo pytest
```

## Contribution

If you want to contribute code, please install the pre-commit package first to ensure that the code you provide suits the custom formatting rules before committing or creating a pull request.
Any advice, proposal for improvement or question is welcome!
```console
$ [mamba or conda] install -n advgeo pre-commit
$ pre-commit install
```

## Author

Niko Kolaxidis, [pd281@uni-heidelberg.de](mailto:pd281@uni-heidelberg.de)

## License

This project is licensed under the GPL-3.0-or-later License - see the [LICENSE](./LICENSE) file for details.

## Footnotes

If you have any questions or encounter a specific problem, feel free to use the Issues section of this repository to get in touch with me. I am looking forward to your ideas and input!
