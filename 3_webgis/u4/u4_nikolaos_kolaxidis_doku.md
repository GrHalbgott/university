# Geospatial Web Development 2022 | Übung 4 <br/> Nikolaos Kolaxidis | 18.01.2023

Das Einbinden der Karte stellt inzwischen keine Hürde mehr da, daher werden die Schritte bis zu den "neuen" Implementationen übersprungen.

Epsg.io stellt eine hilfreiche Plattform zur Beschaffung von Koordinaten und Projektionen dar. Dort wurde auch entsprechend der String für die proj4-Definition der `EPSG:32632` Projektion gefunden und genutzt. Anschließend musste sie für OpenLayers zur Verfügung gestellt ("registriert") werden mit `ol.proj.proj4.register`. Nun kann der Code benutzt werden, um eine neue OpenLayers-Projektion zu erstellen, die auf die verschiedenen Layer mit `new ol.proj.Projection()` angewandt werden kann.

Das Einbinden eines WFS funktioniert sehr ähnlich zu einem WMS, nur dass ein `ol.layer.Vector()` mit `ol.source.Vector()` eingebunden wird statt einem `ol.layer.Tile` mit `ol.source.TileWMS`. Die URL stammt vom Geoserver, dort wurde sie als WFS im GeoJSON-Format angegeben. Die angegebenen Parameter sind optional und sollen nur die URL verkürzen. 

Aus dem Interaction-Modul von OpenLayers wurden `select` und `translate` genutzt, um Features selektierbar und verschiebbar zu machen. Dabei kann in `ol.interaction.Translate()` definiert werden, mit welchen Layer interagiert werden können soll. Da in diesem Fall nur ein WFS zur Verfügung steht, ist es allerdings nicht nötig die Layer anzugeben. Die beiden Funktionen werden in der Map beim Parameter `interaction` integriert mit `ol.interaction.defaults.defaults().extend()`, wobei hier darauf zu achten ist, dass `defaults` doppelt im Prefix der Funktion vorkommt.

Um die Karte userfreundlicher zu gestalten, ist es möglich einen `extent` zu definieren, der die maximale Ausdehnung der Ansicht eines Layers begrenzt. Werden `zoom` und `maxZoom` entsprechend angepasst, kann die Karte nicht mehr unbegrenzt verschoben werden und ist so einfacher zu nutzen. Zusätzlich wurde per `new ol.control.ScaleLine()` ein Maßstab der Karte (dem `control`-Parameter) hinzugefügt, die sich entsprechend des Zoomlevels anpasst. Das soll Entferungs- und Größenschätzungen einfacher gestalten.

Am Ende ist aufgefallen, dass in der Konsole immer zwei Hinweise angegeben wurden:
1. "DevTools failed to load source map: Could not load content for http://127.0.0.1:5500/u4/libs/ol-v7.1.0/ol.js.map: HTTP error: status code 404, net::ERR_HTTP_RESPONSE_CODE_FAILURE"
2. "Canvas2D: Multiple readback operations using getImageData are faster with the willReadFrequently attribute set to true."

Beides konnte durch das Updaten der OpenLayers-Bibliothek von 7.1.0 auf 7.2.2 gefixt werden. Das Script musste dadurch nicht angepasst werden.