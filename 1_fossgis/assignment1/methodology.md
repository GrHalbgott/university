# Methodology 


We are using the methodology proposed by  [Pourali et al (2016)](https://idp.springer.com/authorize/casa?redirect_uri=https://link.springer.com/content/pdf/10.1007/s12061-014-9130-2.pdf&casa_token=556pHuCiUZQAAAAA:WO37dPPHnd7NObyhuElNhxtywKsM0oq7Z9WX6odYtXlU_oGh7VyPl4_blLJZXa4u8ztt05CSVIkqj_O_ku0) to perform the flood risk analysis. Download and (partly) read the paper to answer these questions: 

1. What is the Topographic Wetness Index and how are the TWI values related to the flood probability? [2pt]
   
	The TWI determines which areas are prone to overland flash flooding due to a high wetness beforehand and a specific location in the local topology when a modelled rainfall occurs. It calculates the flow direction of soil water through slope gradients and gravitational forces and estimates how well soil water would be accumulated at any given point.
	
2. Do an online search and name three different FOSSGIS tools to calculate the TWI. At least one of them should **not** be included in the QGIS Processing Toolbox. [1pt]
   
	Most of the tools require steps before using them like hydrologically correcting the given DEMs and calculating sink areas.
	Nonetheless the following tools are the main tools to calculate the TWI:
	- Tool „Topographic Wetness Index (TWI)“ - SAGA GIS
	- Tool „r.topidx“ - GRASS GIS
	- Tool „Wetness Index“ - Whitebox GAT (not included in QGIS)


**Answer the following two questions after you have implemented your analysis in QGIS.**

3. Which parameters need to be defined for your model? [2pt]

	- Raster input, Vector input, CRS input (greenish inputs on the left side of the model)
	- CRS is optional and can be defined globally in the Transformation Tool
	
4. What are the limitations of the methodology? Which aspects are not considered in this analysis? [2pt]

	The TWI does not include hydrological soil properties and therefore cannot handle topologies with special soils and water flow directions.
	This includes any urban disturbances in the flow system, they must be implemented manually beforehand.
	Additionally the index requires a suitable DEM resolution, otherwise the output will be inaccurate and not usable.



