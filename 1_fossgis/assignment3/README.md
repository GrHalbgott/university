# Assignment 3: GRASS GIS

In this assignment you will use **GRASS GIS** to analyse **how many people are affected by noise from motorways** in Baden Württemberg. 

This assignment should be **done and submitted in pairs of 2 students.** Not the same ones as for assignment 1 and 2. Please put your groups [here](https://github.com/fossgis2122/home/blob/main/docs/groups/assignment03_groups.csv).

**Submission deadline:** Friday, Dec 3 2021 on MS Teams  
**Documents to submit:** Zip compressed folder containing

- **documentation.md:** containing your answers to the questions
- **Scripts:**
	- data\_import.bat/.sh 
	- population\_per\_district.bat/.sh
	- noise\_exposure.bat/.sh

The **file name should include your last names** e.g. mueller_schmidt.zip. It is sufficient if **one student uploads the submission** on MS Teams.

If you have **questions or problems** create a **new issue on GitHub**: [https://github.com/fossgis2122/fossgis_assignment3/issues](https://github.com/fossgis2122/fossgis_assignment3/issues)

**Using git:** Create commits while you are working on the assignment every time you think you would like to save your current work status and push them to GitHub. **In the end, every student should have at least 5 commits in their repository!**

## 0. Preparation

1. **Fork** the [repository for this assignment](https://github.com/fossgis2122/fossgis_assignment3) and **clone** your forked repository to your computer.

	The folder **./data** contains the following data sets:
	- **gadm28\_adm2\_germany.shp:** Administrative districts of Germany
	- **motorways.geojson:** Motorways in Baden downloaded from OpenStreetMap 

2. Download the [Global Human Settlement Layer (GHSL): GHS-POP data set](https://cidportal.jrc.ec.europa.eu/ftp/jrc-opendata/GHSL/GHS_POP_MT_GLOBE_R2019A/GHS_POP_E2015_GLOBE_R2019A_54009_250/V1-0/tiles/GHS_POP_E2015_GLOBE_R2019A_54009_250_V1_0_18_3.zip) covering central Europe, extract it and store it in the **./data** folder in your repository. 

### 1. The Global Human Settlement Layer: GHS-POP data set

Answer the following questions about the Global Human Settlement Layer data set. Don't forget to provide **references** if appropriate. 

1. What information does the data set contain?
	
2. What is the spatial resolution of the data set and the coordinate system? 

3. Cite one publication which describes the methodology used to produce the GHS-POP data set. 

4. From which data sources was the information in the GHS-POP layer derived?
	
5. How do you cite the GHS-POP data set? 

### 2. Getting started with GRASS GIS

Watch this very brief [Introduction to GRASS GIS video](https://youtu.be/ZeS7GT_Zlqg). If you need further instructions on how to do certain things in GRASS GIS (e.g. create a location), search online for videos. Add the useful ones to your documentation.md or post them in this [issue](https://github.com/fossgis2122/fossgis_assignment3/issues/1) to share them with other students.

When you create a new location (i.e. a project) in GRASS GIS you need to define a coordinate reference system. You cannot switch as easily as in QGIS.

1. Find a suitable UTM coordinate references system (CRS) which covers Baden Württemberg. Provide the EPSG code of your selected CRS.

2. Start GRASS GIS and set up a new project. 

	- Create a **new location** called "baden-wuerttemberg" with the CRS you selected before and
	- Create a **new mapset** called **assignment3** and open it. 

If you don't know how to do this, Search for a video online (e.g. youtube) which explains how to do this. Provide a **link to the video** in your documentation or in this [issue](https://github.com/fossgis2122/fossgis_assignment3/issues/1") and indicate at which minute the relevant part starts if necessary.  

### 3. Importing data

In this section you will write a script called **./data_import.bat** which imports all data required for the analysis into the mapset **assignment3** in GRASS GIS. **Put all commands in this script along with comments** which are required to solve the exercises below. 

#### Set mapset and region

1. Switch into the mapset **assignment3** using the command `g.mapset`.

2. Using the command `g.region` to print the information about the bounds of the current region and the projection of the mapset.  

#### Importing vector data

There are two commands you can use to import vector data in GRASS GIS: 

- `v.import`: [GRASS GIS Documentation on v.import](https://grass.osgeo.org/grass78/manuals/v.import.html)
- `v.in.ogr`: [GRASS GIS Documentation on v.in.ogr](https://grass.osgeo.org/grass78/manuals/v.in.ogr.html)


1. Read the GRASS GIS documentation and explain what the difference is between the two commands. 

2. Import the file **motorways.geojson** into the mapset **assignment3** as a new layer called **motorways**. Paste the command into the script.

3. Form the file **gadm28\_adm2\_germany.shp** import **only the districts of Baden-Württemberg** into the mapset **assignment3** as a new layer called **districts**. Paste the command into the script.

	**Hint:** You can select the features to be imported using the `where` parameter, e.g. `where="NAME_1='Bayern'"`

4. Set the region of the mapset to the layer **districts** and print the region. Paste the command into the script.

#### Importing raster data 

There are two commands you can use to import raster data in GRASS GIS: 

- `r.import`: [GRASS GIS Documentation on r.import](https://grass.osgeo.org/grass78/manuals/r.import.html)
- `r.in.ogr`: [GRASS GIS Documentation on r.in.ogr](https://grass.osgeo.org/grass78/manuals/r.in.ogr.html)

1. Import the Global Human Settlement Layer data set **GHS\_POP\_E2015\_GLOBE\_R2019A\_54009\_250\_V1\_0\_18\_3** into the mapset **assignment3** as a new layer called **population** using one of these commands. **Explain your choice** and paste the command into the script.

	**Important:** The raster data should only be imported within the **extent of the current region**.

2. Set the region to the layer **population**. Paste the command into the script.


#### Verify that all data has been imported

1. Print the **names of all vector and raster layers** using the command `g.list`.  Paste the command into the script.

2. Print the **current region**. Paste the command into the script. Your output should look something like this: 

	```
	> g.region -p
	projection: 1 (UTM)
	zone:       32
	datum:      etrs89
	ellipsoid:  grs80
	north:      5515648.48892806
	south:      5261149.358888
	west:       388323.37187687
	east:       610081.98976798
	nsres:      239.19091169
	ewres:      239.22181002
	rows:       1064
	cols:       927
	cells:      986328
	```
	
3. Load the layers into the GRASS GIS map display. You don't need to provide the commands for this. 

### 4. Calculate the total population of each district

In this section you will write a script called **population\_per\_district.bat** which calculates the total population of each district (Fig. 1).

<p align=center>
<img src=./img/population.png width=500/> 
<br>
Figure 1: Total population of each district in Baden Württemberg.
</p>

1. Find a GRASS GIS command from the **vector group (v.)** to calculate **zonal statistics**. Name it along with a link to the documentation page. 

2. Use the **zonal statistics tool** to calculate the **total population of each district**.

3. **Compare the calculated total population to official census data**. How accurate is it? Do you think it is accurate enough to use it for our analysis on noise exposure?

### 5. Noise Exposure of population nearby motorways

In this section you will write a script called **noise_exposure.bat** which calculates the number of people exposed to noise from motorways in each district. We will assume that people living up to **1km from the motorway** are affected by the noise. 

1. Set the region to the extent of the **motorways** layer which is roughly the Rhein-Neckar region. 

2. Calculate the total population living **within 1 kilometer of motorways for each district**. 

3. Provide a table in your documentation.md which shows for each distrit, the total population and the number of people within 1 km of a motorway for each district. 

### Bonus 

Create a map (in GRASS GIS or QGIS) showing the total number of people living within 1 km distance of motorways for each district. 

#### Resources

- [GRASS GIS 7.8 Manual](https://grass.osgeo.org/grass78/manuals/index.html/)   
- [GRASS GIS Database](https://grass.osgeo.org/grass78/manuals/grass_database.html)
- [Video: Introduction to GRASS GIS: data model, commands and user interface](https://youtu.be/ZeS7GT_Zlqg)
- [Video Playlist: Getting Started with GRASS GIS](https://www.youtube.com/watch?v=56xkXMd9XBM&list=PLycBDiXWmuxnfLUjs1wkm6WvYsazeLZ0K)  
