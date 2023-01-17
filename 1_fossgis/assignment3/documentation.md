# Assignment 3: GRASS GIS



## 1. Global Human Settlement Layers

1. **What information does the data set contain?**

   The Global Human Settlement Layer consists of the following four packages:

   - two GHS built-up area grids, where one is derived from Sentinel 1 with a temporal coverage from 2016 and the other is multi-temporal (1975-1990-2000-2014) from Landsat. Both grids contain build up classifications.
   - GHS population grid from GPW4.1 with a temporal coverage (1975-1990-2000-2015). This grid shows the distribution and density of population expressed in number of people per cell.
   - and GHS Settlement Model grid derived from GHS population and the multi-temporal GHS area grid with the temporal coverage (1975-1990-2000-2015). This layer is classifying the typologies of settlements according to population size, population and built-up area densities.

2. **What is the spatial resolution of the data set and the coordinate system?**

   Reference: Florczyk et al. 2019, pp. 8, 9, 15, 23.

   | Name of the Layer                 | spatial resolution               | coordinate system                                            |
   | --------------------------------- | -------------------------------- | ------------------------------------------------------------ |
   | GHS built-up area grid Sentinel-1 | 20 m                             | Spherical Mercator (EPSG:3857)                               |
   | GHS built-up area grid Landsat    | 30 m, 250 m, 1 km                | Spherical Mercator (EPSG:3857), World Mollweide (EPSG:54009) |
   | GHS population grid               | 250 m, 1 km, 9 arcsec, 30 arcsec | World Mollweide (EPSG: 54009) and WGS 1984 (EPSG: 4326)      |
   | GHS Settlement Model grid         | 1 km                             | World Mollweide (EPSG: 54009)                                |

3. **Cite one publication which describes the methodology used to produce the GHS-POP data set.**

   Freire S., MacManus K., Pesaresi M., Doxsey-Whitfield E., Mills J. (2016): Development of new open and free multi-temporal global population grids at 250 m resolution. Geospatial Data in a Changing World, Association of Geographic Information Laboratories in Europe (AGILE).

4. **From which data sources was the information in the GHS-POP layer derived?**

   The residential population estimation for the specific years are provided by CIESIN Gridded Population of the World (GPWv.4.10) at polygon level and disaggregated from administrative units to grid cells (cf. Florczyk et al. 2019, p. 13).

5. **How do you cite the GHS-POP data set?**

   The GHS-POP data set can be cited as following (cf. Florczyk et al. 2019, p. 16): Schiavina M., Freire S., MacManus K. (2019): GHS population grid multitemporal (1975-1990- 2000-2015), R2019A. European Commission, Joint Research Centre (JRC) [Dataset] doi:10.2905/0C6B9751-A71F-4062-830B-43C9F432370F, PID: http://data.europa.eu/89h/0c6b9751-a71f-4062-830b-43c9f432370f.

Reference: Florczyk A.J., Corbane C., Ehrlich D., Freire S., Kemper T., Maffenini L., Melchiorri M., Pesaresi M., Politis P., Schiavina M., Sabo F., Zanchetta L. (2019): GHSL Data Package 2019. Public Release GHS P2019. EUR 29788 EN, Publications Office of the European Union, Luxembourg. ISBN 978-92-76-08725-0, doi:10.2760/062975, JRC 117104.

---

## 2. Getting started with GRASS GIS

A suitable CRS which covers Baden-Württemberg is the ETRS89 / UTM zone 32N (EPSG:25832).

----

## 4. Calculate the total population of each district

Comparing to offical census data (https://de.statista.com/statistik/daten/studie/1071004/umfrage/einwohnerzahl-der-kreise-in-baden-wuerttemberg/) one can observe higher calculated numbers than those in reality. Nonetheless the order and difference of regions are similar, therefore we can use the calculated numbers for further analysis.

---

## 5. Noise Exposure of population nearby motorways

| Name                          | Population total | Population near motorways |
| ----------------------------- | ---------------- | ------------------------- |
| Heidelberg (urban district)   | 158,934          | 39,183                    |
| Mannheim (urban district)     | 302,796          | 81,190                    |
| Rhein-Neckar-Kreis (district) | 552,534          | 128,651                   |

