g.region vector=motorways
v.buffer input=motorways type=line distance=1000 output=motorways_buffer
v.clip input=motorways_buffer clip=districts -d output=motorways_clip
v.overlay ainput=districts binput=motorways_clip operator=and output=intersection
v.rast.stats map=intersection raster=population method=sum column_prefix=per_motorway
db.out.ogr input=intersection output=table format=CSV