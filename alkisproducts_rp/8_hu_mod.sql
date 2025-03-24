-- Daten fuer AdV Hausumringe aus GebaeudeBauwerk aufbereiten
SELECT gid, gmdschl as ags, left(oid, 16) as oi, gfkzshh as gfk, geometrie
INTO pt_hu
FROM pt_gebaeudebauwerke
WHERE gfkzshh <> ''
AND ST_GeometryType(geometrie) = 'ST_Polygon';

-- INDEX auf Tabelle--
CREATE INDEX pt_hu_geom ON pt_hu USING gist (geometrie) TABLESPACE pgdata;
CREATE INDEX pt_hu_oi ON pt_hu USING btree (oi COLLATE pg_catalog."default") TABLESPACE pgdata;
CREATE INDEX pt_hu_gfk ON pt_hu USING btree (gfk COLLATE pg_catalog."default") TABLESPACE pgdata;
CREATE INDEX pt_hu_ags ON pt_hu USING btree (ags COLLATE pg_catalog."default") TABLESPACE pgdata;

-- Constrains--
ALTER TABLE pt_hu ADD CONSTRAINT pt_hu_pk PRIMARY KEY (gid);
ALTER TABLE pt_hu ADD CONSTRAINT enforce_dims_the_geom CHECK (st_ndims(geometrie) = 2);
ALTER TABLE pt_hu ADD CONSTRAINT enforce_srid_the_geom CHECK (st_srid(geometrie) = 25832);

-- INSERT into postgis_21.geometry_column--s
INSERT INTO postgis.geometry_columns(f_table_catalog,f_table_schema, f_table_name, f_geometry_column,coord_dimension, srid, type)
    VALUES ('','public', 'pt_hu', 'geometrie', 2, 25832, 'MULTIPOLYGON');