from OSMPythonTools.overpass import Overpass
from OSMPythonTools.overpass import overpassQueryBuilder
from OSMPythonTools.nominatim import Nominatim

nominatim = Nominatim()
overpass = Overpass()

query = overpassQueryBuilder(
    area=nominatim.query('Berlin').areaId(),
    elementType=['node', 'way', 'relation'],
    selector=['"amenity"="school"']
)

result = overpass.query(query)

print(f"Nodes: {len(result.nodes())}")
print(f"Ways: {len(result.ways())}")
print(f"Relations: {len(result.relations())}")