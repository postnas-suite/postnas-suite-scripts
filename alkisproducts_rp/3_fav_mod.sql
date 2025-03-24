--Attribute für Isolierung anlegen
ALTER TABLE faf_osf ADD COLUMN vkz character varying;
ALTER TABLE faf_osf ADD COLUMN stelle character varying;
ALTER TABLE faf_osf ADD COLUMN bez character varying;

--VKZ isolieren
UPDATE faf_osf
    SET vkz = split_part(split_part(split_part(art, ';', 2), ',', 2), ' ', 3)
    WHERE art LIKE '%FlurbG%'
    OR art LIKE '%Flurbereinigungsgesetz%';

--Stelle isolieren
UPDATE faf_osf
    SET stelle = split_part(split_part(art, '; ', 2), ',', 1);

--Bezeichnung isolieren
UPDATE faf_osf
    SET bez = split_part(art, 'Bezeichnung ', 2);

--Tabelle für tatsächliche Nutzung erstellen
SELECT faf_fs.gml_id, 
        array_agg(concat(faf_tng.flaeche,' m² ',faf_tng.art) ORDER BY faf_tng.flaeche DESC) as tng
    INTO pt_tng
    FROM faf_fs
    INNER JOIN faf_tng ON faf_fs.gml_id=faf_tng.gml_id
    GROUP BY faf_fs.gml_id;

--Tabelle für öffentlich-rechtliche und sonstige Festsetzungen erstellen
--SELECT faf_fs.gml_id, array_agg(DISTINCT faf_osf.art ORDER BY faf_osf.art ASC) as osf
SELECT faf_fs.gml_id, 
        array_agg(concat(faf_osf.flaeche,' m² ',faf_osf.art) ORDER BY faf_osf.art ASC) as osf, 
        array_agg(NULLIF(faf_osf.vkz, '')) as osf_vkz, 
        array_agg(faf_osf.stelle) as osf_stelle, 
        array_agg(faf_osf.bez) as osf_bez
    INTO pt_osf
    FROM faf_fs
    INNER JOIN faf_osf ON faf_fs.gml_id=faf_osf.gml_id
    GROUP BY faf_fs.gml_id;

--Tabelle für Bewertung erstellen
SELECT faf_fs.gml_id, 
        array_agg(concat(faf_bub.flaeche,' m² ', replace(faf_bub.art, 'Bewertung - ', '')) ORDER BY faf_bub.flaeche DESC) as bew
    INTO pt_bew
    FROM faf_fs
    INNER JOIN faf_bub ON faf_fs.gml_id=faf_bub.gml_id
    WHERE faf_bub.art LIKE '%Bewertung%'
    GROUP BY faf_fs.gml_id;

--Tabelle für Bodenschätzung erstellen
SELECT res.gml_id, array_agg(res.bod) as bod 
    INTO pt_bod
    FROM  
    ((SELECT faf_fs.gml_id as gml_id, 
            concat(faf_bub.flaeche,' m² ', replace(replace(faf_bub.art, 'Kulturart ',''), ';', ','),', Bodenzahl ', faf_bub.bodenzahlodergruenlandgrundzahl, ', Ackerzahl ', faf_bub.ackerzahlodergruenlandzahl, ', Ertragsmesszahl ', faf_bub.emz) as bod
        FROM faf_fs
        INNER JOIN faf_bub ON faf_fs.gml_id=faf_bub.gml_id
        WHERE faf_bub.art NOT LIKE '%Bewertung%'
        AND art LIKE '%Ackerland%' OR art LIKE '%Acker-Grünland%')
    UNION
    (SELECT faf_fs.gml_id as gml_id, 
            concat(faf_bub.flaeche,' m² ', replace(replace(faf_bub.art, 'Kulturart ',''), ';', ','),', Grünlandgrundzahl ', faf_bub.bodenzahlodergruenlandgrundzahl, ', Grünlandzahl ', faf_bub.ackerzahlodergruenlandzahl, ', Ertragsmesszahl ', faf_bub.emz) as bod
        FROM faf_fs
        INNER JOIN faf_bub ON faf_fs.gml_id=faf_bub.gml_id
        WHERE faf_bub.art NOT LIKE '%Bewertung%'
        AND art LIKE '%Grünland%' OR art LIKE '%Grünland-Acker%')) AS res
    GROUP BY res.gml_id;

--Finale Teblle erstellen
SELECT
	faf_fs.flurstueckskennzeichen AS flstkennz,
	faf_fs.amtlicheflaeche AS flaeche,
	array_to_string(pt_tng.tng, '|') AS tng,
	array_to_string(pt_bod.bod, '|') AS bod,
	faf_fs.gmz,
	array_to_string(pt_bew.bew, '|') AS bew,
	array_to_string(pt_osf.osf, '|') AS osf,
	array_to_string(pt_osf.osf_vkz, '|') AS osf_vkz,
	array_to_string(pt_osf.osf_stelle, '|') AS osf_stelle,
	array_to_string(pt_osf.osf_bez, '|') AS osf_bez,
	faf_fs.schwerpunkt AS wkb_geometry
INTO pt_fav
FROM faf_fs
FULL JOIN pt_bew ON
	faf_fs.gml_id = pt_bew.gml_id
FULL JOIN pt_bod ON
	faf_fs.gml_id = pt_bod.gml_id
FULL JOIN pt_osf ON
	faf_fs.gml_id = pt_osf.gml_id
FULL JOIN pt_tng ON
	faf_fs.gml_id = pt_tng.gml_id;


-- INDEX auf Tabelle--
CREATE INDEX pt_fav_geom ON pt_fav USING gist (wkb_geometry) TABLESPACE pgdata;
CREATE INDEX pt_fav_flstkennz ON pt_fav USING btree (flstkennz COLLATE pg_catalog."default") TABLESPACE pgdata;
--CREATE INDEX fav_flaeche ON fav USING btree (flaeche COLLATE pg_catalog."default") TABLESPACE pgdata;
--CREATE INDEX fav_tng ON fav USING btree (tng COLLATE pg_catalog."default") TABLESPACE pgdata;
--CREATE INDEX fav_bod ON fav USING btree (bod COLLATE pg_catalog."default") TABLESPACE pgdata;
--CREATE INDEX fav_gmz ON fav USING btree (gmz COLLATE pg_catalog."default") TABLESPACE pgdata;
---CREATE INDEX fav_bew ON fav USING btree (bew COLLATE pg_catalog."default") TABLESPACE pgdata;
--CREATE INDEX fav_osf ON fav USING btree (osf COLLATE pg_catalog."default") TABLESPACE pgdata;

--gid-Spalte erstellen fuer primary key--
ALTER TABLE pt_fav ADD COLUMN gid serial NOT NULL;

-- Constrains--
ALTER TABLE pt_fav ADD CONSTRAINT pt_fav_pk PRIMARY KEY (gid);
ALTER TABLE pt_fav ADD CONSTRAINT enforce_dims_wkb_geometry CHECK (st_ndims(wkb_geometry) = 2);
ALTER TABLE pt_fav ADD CONSTRAINT enforce_srid_wkb_geometry CHECK (st_srid(wkb_geometry) = 25832);

-- INSERT into postgis_21.geometry_column--s
INSERT INTO postgis.geometry_columns(f_table_catalog,f_table_schema, f_table_name, f_geometry_column,coord_dimension, srid, type)
    VALUES ('','public', 'pt_fav', 'schwerpunkt', 2, 25832, 'MULTIPOLYGON');
