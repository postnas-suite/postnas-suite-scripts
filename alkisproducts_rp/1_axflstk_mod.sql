--Tabelle für tatsächliche Nutzung erstellen
SELECT fl.gml_id, array_to_string(array_agg(concat(faf_tng.art,';',faf_tng.flaeche) ORDER BY faf_tng.flaeche DESC),'|') as tng
INTO pt_tng_fs
FROM ax_flurstueck fl
LEFT JOIN faf_tng ON fl.gml_id=faf_tng.gml_id
GROUP BY fl.gml_id;

--Finale Tabelle erstellen
SELECT cast(concat(fl.gml_id,'FL') as character varying) AS oid,
	fl.beginnt::date AS aktualit,
	fl.wkb_geometry AS geometrie,
	fl.gml_id AS idflurst,
	fl.amtlicheflaeche AS flaeche,
	fl.flurstueckskennzeichen AS flstkennz,
	CASE
	WHEN fl.land = '07' THEN cast('Rheinland-Pfalz' as character varying)
	WHEN fl.land = '05' THEN cast('Nordrhein-Westfalen' as character varying)
	WHEN fl.land = '06' THEN cast('Hessen' as character varying)
	WHEN fl.land = '08' THEN cast('Baden-Württemberg' as character varying)
	WHEN fl.land = '10' THEN cast('Saarland' as character varying)
	ELSE ''
	END AS land,
	fl.land AS landschl, 
	ge.bezeichnung AS gemarkung,
	ge.schluesselgesamt AS gemaschl,
	cast(concat('Flur ',fl.flurnummer) as character varying) AS flur,
	cast(substring(fl.flurstueckskennzeichen FROM 1 FOR 9) as character varying) AS flurschl,
	fl.zaehler::character varying AS flstnrzae,
	fl.nenner::character varying AS flstnrnen,
	cast(NULL as character varying) AS regbezirk,
	cast(NULL as character varying) AS regbezschl,
	kr.bezeichnung AS kreis,
	kr.schluesselgesamt AS kreisschl,
	gm.bezeichnung AS gemeinde,
	gm.schluesselgesamt AS gmdschl,
	CASE
	WHEN abweichenderrechtszustand = 'true' THEN cast('Abweichender Rechtszustand' as character varying)
	WHEN abweichenderrechtszustand = 'false' THEN cast('Kein abweichender Rechtszustand' as character varying)
	ELSE NULL
	END AS abwrecht,
	CASE
	WHEN fl.nenner IS NULL THEN fl.zaehler::character varying
	ELSE cast(concat(fl.zaehler,'/',fl.nenner) as character varying)
	END AS flurstnr,
	cast(lg.lagebeztxt as character varying) AS lagebeztxt,
	CASE
	WHEN pt_tng_fs.tng = ';' THEN NULL
	ELSE pt_tng_fs.tng::character varying 
	END AS tntxt
INTO pt_flurstueck
FROM ax_flurstueck fl
INNER JOIN ax_gemarkung ge ON ge.gemarkungsnummer = fl.gemarkungsnummer
INNER JOIN ax_kreisregion kr ON (kr.regierungsbezirk = fl.gemeindezugehoerigkeit_regierungsbezirk)
	AND (kr.kreis = fl.gemeindezugehoerigkeit_kreis)
INNER JOIN ax_gemeinde gm ON (gm.regierungsbezirk = fl.gemeindezugehoerigkeit_regierungsbezirk)
	AND (gm.kreis = fl.gemeindezugehoerigkeit_kreis)
	AND (gm.gemeinde = fl.gemeindezugehoerigkeit_gemeinde)
LEFT JOIN pt_lagebez_gesamt lg ON fl.gml_id = lg.gml_id
LEFT JOIN pt_tng_fs ON fl.gml_id = pt_tng_fs.gml_id;

-- INDEX auf Tabelle--
CREATE INDEX pt_flurstueck_geom ON pt_flurstueck USING gist (geometrie) TABLESPACE pgdata;
CREATE INDEX pt_flurstueck_oid ON pt_flurstueck USING btree (oid COLLATE pg_catalog."default") TABLESPACE pgdata;
CREATE INDEX pt_flurstueck_flstkennz ON pt_flurstueck USING btree (flstkennz COLLATE pg_catalog."default") TABLESPACE pgdata;
CREATE INDEX pt_flurstueck_land ON pt_flurstueck USING btree (land COLLATE pg_catalog."default") TABLESPACE pgdata;
CREATE INDEX pt_flurstueck_gemarkung ON pt_flurstueck USING btree (gemarkung COLLATE pg_catalog."default") TABLESPACE pgdata;
CREATE INDEX pt_flurstueck_gemaschl ON pt_flurstueck USING btree (gemaschl COLLATE pg_catalog."default") TABLESPACE pgdata;
CREATE INDEX pt_flurstueck_flur ON pt_flurstueck USING btree (flur COLLATE pg_catalog."default") TABLESPACE pgdata;
CREATE INDEX pt_flurstueck_flurstnr ON pt_flurstueck USING btree (flurstnr COLLATE pg_catalog."default") TABLESPACE pgdata;
CREATE INDEX pt_flurstueck_gmdschl ON pt_flurstueck USING btree (gmdschl COLLATE pg_catalog."default") TABLESPACE pgdata;
CREATE INDEX pt_flurstueck_kreis ON pt_flurstueck USING btree (kreis COLLATE pg_catalog."default") TABLESPACE pgdata;
CREATE INDEX pt_flurstueck_gemeinde ON pt_flurstueck USING btree (gemeinde COLLATE pg_catalog."default") TABLESPACE pgdata;
CREATE INDEX pt_flurstueck_landschl ON pt_flurstueck USING btree (landschl COLLATE pg_catalog."default") TABLESPACE pgdata;
CREATE INDEX pt_flurstueck_flurschl ON pt_flurstueck USING btree (flurschl COLLATE pg_catalog."default") TABLESPACE pgdata;
CREATE INDEX pt_flurstueck_flstnrzae ON pt_flurstueck USING btree (flstnrzae COLLATE pg_catalog."default") TABLESPACE pgdata;
CREATE INDEX pt_flurstueck_flstnrnen ON pt_flurstueck USING btree (flstnrnen COLLATE pg_catalog."default") TABLESPACE pgdata;
CREATE INDEX pt_flurstueck_kreisschl ON pt_flurstueck USING btree (kreisschl COLLATE pg_catalog."default") TABLESPACE pgdata;

--gid-Spalte erstellen fuer primary key--
ALTER TABLE pt_flurstueck ADD COLUMN gid serial NOT NULL;

-- Constrains--
ALTER TABLE pt_flurstueck ADD CONSTRAINT pt_flurstueck_pk PRIMARY KEY (gid);
ALTER TABLE pt_flurstueck ADD CONSTRAINT enforce_dims_the_geom CHECK (st_ndims(geometrie) = 2);
ALTER TABLE pt_flurstueck ADD CONSTRAINT enforce_srid_the_geom CHECK (st_srid(geometrie) = 25832);

-- INSERT into postgis_21.geometry_column--s
INSERT INTO postgis.geometry_columns(f_table_catalog,f_table_schema, f_table_name, f_geometry_column,coord_dimension, srid, type)
    VALUES ('','public', 'pt_flurstueck', 'geometrie', 2, 25832, 'MULTIPOLYGON');
