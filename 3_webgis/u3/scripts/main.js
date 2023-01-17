const mapView = new ol.View({
    projection : "EPSG:3857",
    // zentriere auf Deutschland
    center: ol.proj.fromLonLat([10.5, 51.35]),
    zoom: 6,
    minZoom: 6,
    maxZoom: 8,
    });

const map = new ol.Map({
    target: 'map',
    view: mapView
    });

const osmLayer = new ol.layer.Tile({
    source: new ol.source.OSM()
    });
map.addLayer(osmLayer);

const wmsLayer = new ol.layer.Tile({
    opacity: 0.7,
    source: new ol.source.TileWMS({
        url: "http://osmatrix.geog.uni-heidelberg.de:8080/geoserver/nkolaxidis/wms",
        params: {
            "FORMAT": 'image/png', 
            "VERSION": "1.3.0",
            tiled: true,
            "LAYERS": 'Schweineschlacht',
            "STYLES": 'Schweineschlacht Style',
            "exceptions": 'application/openlayers',
            tilesOrigin: 5.866250351000076 + "," + 47.27012360400005
            }
        })
    });
map.addLayer(wmsLayer);

const insertLegend = function (resolution) {
    const graphicUrl = wmsLayer.getSource().getLegendUrl(resolution);
    const img = document.getElementById('legend');
    img.src = graphicUrl;
  };
const resolution = map.getView().getResolution();
insertLegend(resolution);

map.on('singleclick', function(evt) {
    document.getElementById('feature_info').innerHTML = "Wird geladen, bitte warten...";
    const feature = wmsLayer.getSource().getFeatureInfoUrl(
        evt['coordinate'], 
        map.getView().getResolution(), 
        map.getView().getProjection(),
        {'INFO_FORMAT': 'text/html'});
    if (feature) {
        fetch(feature)
            .then((response) => response.text())
            .then((html) => {
            document.getElementById('feature_info').innerHTML = html;
            });
        }
    });
