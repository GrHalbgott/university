proj4.defs("EPSG:32632","+proj=utm +zone=32 +datum=WGS84 +units=m +no_defs +type=crs"); // von epsg.io
ol.proj.proj4.register(proj4);

const projection = new ol.proj.Projection({
    code: "EPSG:32632",
    extent: [166021.44, 0.0, 833978.56, 9329005.18], // von epsg.io
  });

var extent = [471990.362358, 5466903.591556, 480781.344677, 5478116.778652]; // eigener hardcode

const select = new ol.interaction.Select();

const translate = new ol.interaction.Translate({
    features: select.getFeatures(), // greift auf Features der Map zu (nur WFS)
  });

const map = new ol.Map({
    target: 'map',
    view: new ol.View({
        projection: projection,
        center: [475147.958298, 5474371.502673], // eigener hardcode
        extent: extent,
        zoom: 15.2, // eigener hardcode
        maxZoom: 19.8 // eigener hardcode
        }),
    controls: ol.interaction.defaults.defaults().extend([new ol.control.ScaleLine()]),
    interactions: ol.interaction.defaults.defaults().extend([select, translate])
    });

const osmLayer = new ol.layer.Tile({
    source: new ol.source.OSM(),
    extent: extent
    });
map.addLayer(osmLayer);

const wmsLayer = new ol.layer.Tile({
    opacity: 0.66,
    extent: extent,
    source: new ol.source.TileWMS({
        url: "http://osmatrix.geog.uni-heidelberg.de:8080/geoserver/mauer/wms",
        params: {
            "FORMAT": 'image/png', 
            tiled: true,
            "LAYERS": 'mauer:ub4_baugebiet',
            "exceptions": 'application/openlayers',
            }
        })
    });
map.addLayer(wmsLayer);

const featureLayer = new ol.layer.Vector({
    source: new ol.source.Vector({
        url: "http://osmatrix.geog.uni-heidelberg.de:8080/geoserver/mauer/ows?service=WFS&request=GetFeature&typeName=mauer%3Aub4_bebauung&maxFeatures=50&outputFormat=application%2Fjson",
        params: {
            "VERSION": '1.0.0',
            "exceptions": 'application/openlayers',
        },
        format: new ol.format.GeoJSON(),
      }),
    });
map.addLayer(featureLayer);
