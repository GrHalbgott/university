function propCircles(feature) {
    return new ol.style.Style({
        image: new ol.style.Circle({
            fill: new ol.style.Fill({
                color: '#CCEEBB'
                }),
            stroke: new ol.style.Stroke({
                color: '#222222',
                width: 2
                }),
            radius: 1.5 * Math.sqrt( feature.getProperties().value / 12 )
            }),
        zIndex: -feature.getProperties().value
        })
    }

function pointStyle() {
    return new ol.style.Style({
        image: new ol.style.Circle({
            fill: new ol.style.Fill({
                color: "rgba(255, 0, 0, 0.33)"
                }),
            stroke: new ol.style.Stroke({
                color: "#000000",
                width: 1.5
                }),
            radius: 6
            })
        
        });
}
