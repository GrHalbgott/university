function readfile(fileList) {
    // lese ersten Eintrag der fileList (eingelesene CSV-Datei)
    csvFile = fileList[0];
  
    // rufe PapaParse auf und gebe Argumente weiter
    Papa.parse(csvFile, {
        skipEmptyLines: true,
        delimiter: ",",
        error: onerror,
        // rufe Funktion "processData" auf wenn Parsing beendet
        complete: createFeatures
        });
    }


function createFeatures(results) {
    console.log(results.data);
    // definiere neuen leeren Vektorlayer
    let vecSource = new ol.source.Vector({
        minZoom: 5,
        maxZoom: 12
    });
    
    // iteriere durch die Arrays und konvertiere die geparsten Daten (Koordinaten) in Floats
    for (let i = 0; i < results.data.length; i++){
        // verwerfe letzte Spalte (warum nicht)
        results.data[i].pop()
        // erstelle Punktgeometrien mit den Koordinaten 
        let geom = new ol.geom.Point(
            [parseFloat(results.data[i][1]), parseFloat(results.data[i][2])]
            );   
        // erstelle Features mit den Punktgeometrien
        let feature = new ol.Feature({
            geometry : geom
            });
        // füge Features dem leeren Vektorlayer hinzu
        vecSource.addFeature(feature); 
        }
    
    // erstelle Layer mit Features und Style und füge der Karte hinzu
    let dataLayer = new ol.layer.Vector({
        source: vecSource,
        style : pointStyle,
        });
    map.addLayer(dataLayer);
    }
