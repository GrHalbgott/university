# Geospatial Web Development 2022 | Übung 1 <br/> Nikolaos Kolaxidis

Der Aufbau der Webseite erfolgt in drei Teilen:
- Startseite mit grundlegenden Infos zur Aufgabe
- Contentseite mit den entsprechenden Infos zur US-Wahl 2020
- Impressum mit Infos zum Autor und Rechtlichem

Die Seiten selbst sind ebenfalls untergliedert in jeweils drei Bereiche, die jeweils eigene CSS-Scripts erhalten:
- Header: Banner mit Überschrift, Navigationsleiste (Nav) und Trennlinie
- Content: Inhalt inklusive Überschriften, Paragraphen, Abbildungen etc.
- Footer: fixe Leiste mit Infos zum Autor, Datum und Uni sowie einem "Nach-Oben-Button"
- Zwischen Content und Footer befinden sich zusätzlich interaktive Navigationsbuttons (Navbuttons), die in einem vierten CSS-Script "global" zusätzlich zu Schriftart etc. programmiert werden

Ganz oben befindet sich jeweils ein Banner, welches mit der US-Flagge hinterlegt ist. Um eine zu starke Verzerrung zu vermeiden, wurde mit `max-width: 850px` eine absolute maximale Größe gewählt. Dies wurde auch auf andere Elemente der Webseite angewandt, die nicht (unendlich) mit der Anzeigebreite skaliert werden sollen. Da der weiße Text ansonsten kaum lesbar wäre, wurde mit `text-shadow: 2px 2px 0.5rem black` ein Schatten erzeugt, der wie eine Kontur wirkt.

Alle Seiten nutzen die gleiche Nav zur Navigation, die mit den Farben der US-Flagge nach [diesem Link](https://www.flagcolorcodes.com/usa) hinterlegt sind. Sie nutzen lineare Gradienten, um einen Verlauf zwischen den entsprechenden Farben zu ermöglichen:
`background: linear-gradient(180deg, #0A3161 10%, #FFFFFF 50%, #B31942 90%);` 

Der Footer spiegelt den selben Gradienten mithilfe einer 180° Drehung (sprich `0deg`). Die Farben tauchen weiterhin in anderen Elementen wie der Trennlinie im Header und dem Nach-Oben-Button im Footer (rot), den Navbuttons (blau) sowie Markierungen des Mauszeigers innerhalb der Nav auf. Da XML und SVG ebenfalls Markup Languages sind, sind Grundkenntnisse in HTML und CSS auch in diesen Sprachen hilfreich, sodass die Farben in der Karte des Wahlergebnisses manuell überschrieben wurden, um den restlichen Farben nachzukommen und ein stimmiges Gesamtbild zu ermöglichen.

Die Links innerhalb der Nav, die auf die anderen Seiten verlinken, wurden mit `padding` und `margin` so eingestellt, dass sie die Leiste mit ihrer Markierung voll ausfüllen. Ebenfalls wird so eine nahtlose Aneinanderreihung der so entstandenen Linkboxen ermöglicht. 

`Margin: auto` bzw. `margin: 0 auto` zentriert dabei Objekte, da für `margin-left` und `margin-right` automatisch die gleichen Werte genommen werden. Wichtig ist hierbei den Befehl an richtiger Stelle zu setzen, und zwar im Container um die Nav (um beim Beispiel zu bleiben) und nicht den Elementen innerhalb der Nav.

Der Transitionseffekt, der an JavaScript erinnert, wird durch `transition-duration: 0.5s` erzeugt. Dies schafft eine spielerische Interaktion mit Elementen der Webseite, ohne JavaScript zu integrieren. Der gleiche Effekt wird auch bei den Navbuttons angewendet, dort wird mit größerem `padding` auch ein Scalingeffekt integriert.

Die Seite zu den US-Wahlen ist am komplexesten, da hier zusätzlich Text, eine Tabelle und Abbildungen unterschiedlich positioniert werden. Dabei wird `float: left/right` benutzt, welches ein Element im Container nach links oder rechts schiebt und die folgenden Elemente innerhalb des Containers auf die andere Seite. Hier wird ein Problem klar: die Abbildung mit dem Wahlergebnis und die Tabelle mit den Details sind auf einer Linie nebeneinander, wenn das Fenster ein recht breites Format besitzt. Ist es ganz schmal, stehen die beiden Abbildungen zentriert übereinander, was gewollt ist. In den Zwischenformaten ist die Tabelle allerdings zentriert und die Abbildung dadrüber nicht, dies bedarf weitere Positionsierungstests, um die korrekte Anzeige auch zB bei Tablets zu gewährleisten (*responsive design*).

Durch mehr Implementierung von responsive Design Maßnahmen kann auch die Darstellung auf Smartphones erhöht werden, in dem zB ab bestimmten Fenstergrößen Elemente untereinander statt nebeneinander positioniert werden (Navbuttons, Footer). Außerdem sollte das Ausfüllen des Bodybereichs ebenfalls responsiv gestaltet werden, allerdings sprengt das dann doch den Rahmen dieser Aufgabe. Dies sollte aber zukünftig bei Webseiten, die online gestellt werden sollen, beachtet werden.

Diesbezüglich kann auch auf die verschiedenen Größenangaben hingewiesen werden (`px, %, rem`), die auf den Webseiten benutzt wurden. Mit `px` werden absolute Angaben gemacht, `%` ist Abhängig von der Fensterbreite und `rem` abhängig von der ursprünglichen Schriftartgröße (default: `16px`). Dadurch können relative und absolute Angaben je nach Anwendungsfall gemischt werden und so ein ansehnliches Layout geschaffen werden.

Ein kurzer Hinweis: die Navbuttons am Ende des Contents werden per `clear: both` auf eine neue Zeile gezwungen, in der vorige Floats nicht mehr gültig sind. Dieser Befehl ist extrem hilfreich um klare strukturelle Trennungen von Inhalten zu erzwingen, da zusätzlich zu Trennlinien und Überschriften auch das CSS an sich abgeschlossen wird.

Das Impressum weist bis auf eine Liste mit Bullet Points und mehr Text (mit entsprechend mehr Überschriften etc.) ansonsten keine nennenswerten Besonderheiten auf.