// Punkte 2 und 3 selber definieren auf https://geojson.io
// Koordinaten rauskopieren und hier eintragen (Reihenfolge beachten: Longitude, Latitude!)
var refPoint = turf.point([8.67679816795598, 49.41886456686146]); // Der PC-Raum in dem wir uns befinden
var point2 = turf.point([8.052217806536845, 51.890670074321974]);
var point3 = turf.point([17.738367536020434, 47.37418607281819]);

// Zusammenführen der Punkte in eine FeatureCollection
var points = turf.featureCollection([point2, point3]);

//
// Folgende Funktion soll bei den Kommentarzeilen entsprechend angepasst werden
//

function doit() { 

    // Berechnen des Nearest Neighbors (NN)
    var nearest = turf.nearestPoint(refPoint, points);

    // Transformieren von GeoJSON zu Turf.js-Feature (wird später benötigt)
    nearest = turf.point(turf.getCoord(nearest));

    // Berechnen der Distanz zum NN in Kilometern
    var distance = turf.distance(refPoint, nearest, {units: 'kilometers'});
    console.log("Distanz zum Nearest Neighbor: " + turf.round(distance, 2) + " km");

    // Buffern um refPoint mit Distanz * 2
    var buffer = turf.buffer(refPoint, distance * 2, {units: 'kilometers'});
    console.log("Area des Buffers: " + turf.round(turf.area(buffer) / 1000000, 2) + " km²"); // Achtung: area wird in m² ausgegeben!

    // Feststellen welcher Punkt nicht der NN ist
    if (turf.booleanEqual(nearest, point2) == true) {
        var farthest = point3;
    } else if (turf.booleanEqual(nearest, point3) == true) {
        var farthest = point2;
    } else {
        alert("Fehler: kann den am weitesten entfernten Punkt nicht feststellen.")
    }

    // Feststellen ob der Punkt innerhalb des Buffers (inside) liegt. Ergebnis (true/false) wird in der Konsole ausgegeben
    console.log(
        "[RP FP] <= 2 * [RP NN]? \nErgebnis: "
        + turf.inside(farthest, buffer)
        ); 

    var resultData = turf.featureCollection([buffer]); // weitere optionale Variablen eintragen
    
    // Darstellung in der Karte (Funktion steht in index.html)
    showresults(resultData);
}
