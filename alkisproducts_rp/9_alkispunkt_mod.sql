--Tabelle für unnest PunktorteAU anlegen
CREATE TABLE pt_unnested_punktorte_au (
	istteilvon CHARACTER VARYING,
	genauigkeitsstufe INTEGER,
	herkunft CHARACTER VARYING,
	herkunft_datenerhebung INTEGER,
	kartendarstellung CHARACTER VARYING,
	wkb_geometry geometry(Point,25832)
);

--Tabelle für unnest PunktorteTA anlegen
CREATE TABLE pt_unnested_punktorte_ta (
	istteilvon CHARACTER VARYING,
	genauigkeitsstufe INTEGER,
	herkunft CHARACTER VARYING,
	herkunft_datenerhebung INTEGER,
	kartendarstellung CHARACTER VARYING,
	wkb_geometry geometry(Point,25832)
);

--Tabelle für unnest PunktorteAG anlegen
CREATE TABLE pt_unnested_punktorte_ag (
	istteilvon CHARACTER VARYING,
	genauigkeitsstufe INTEGER,
	herkunft CHARACTER VARYING,
	herkunft_datenerhebung INTEGER,
	kartendarstellung CHARACTER VARYING,
	wkb_geometry geometry(Point,25832)
);

-- Unnest PunktortAU für alle istteilvon-Verweise. Das DB-Schema sieht mehrere istteilvon-Verweise je Punktort vor.  
INSERT INTO  pt_unnested_punktorte_au
	(istteilvon, genauigkeitsstufe, herkunft, herkunft_datenerhebung, kartendarstellung, wkb_geometry)
SELECT
	UNNEST(istteilvon) AS istteilvon,
	genauigkeitsstufe,
	array_to_string(processstep_ax_li_processstep_punktort_description, ',') AS herkunft,
	array_to_string(processstep_ax_datenerhebung_punktort, ',')::int AS herkunft_datenerhebung,
	kartendarstellung,
	ST_Force2D(wkb_geometry) AS wkb_geometry
FROM ax_punktortau
WHERE length(round(st_x(wkb_geometry))::varchar) <= 6;

-- Unnest PunktortTA für alle istteilvon-Verweise. Das DB-Schema sieht mehrere istteilvon-Verweise je Punktort vor.  
INSERT INTO  pt_unnested_punktorte_ta
	(istteilvon, genauigkeitsstufe, herkunft, herkunft_datenerhebung, kartendarstellung, wkb_geometry)
SELECT
	UNNEST(istteilvon) AS istteilvon,
	genauigkeitsstufe,
	array_to_string(processstep_ax_li_processstep_punktort_description, ',') AS herkunft,
	array_to_string(processstep_ax_datenerhebung_punktort, ',')::int AS herkunft_datenerhebung,
	kartendarstellung,
	ST_Force2D(wkb_geometry) AS wkb_geometry
FROM ax_punktortta;

-- Unnest PunktortAG für alle istteilvon-Verweise. Das DB-Schema sieht mehrere istteilvon-Verweise je Punktort vor.  
INSERT INTO  pt_unnested_punktorte_ag
	(istteilvon, genauigkeitsstufe, herkunft, herkunft_datenerhebung, kartendarstellung, wkb_geometry)
SELECT
	UNNEST(istteilvon) AS istteilvon,
	genauigkeitsstufe,
	array_to_string(processstep_ax_li_processstep_punktort_description, ',') AS herkunft,
	array_to_string(processstep_ax_datenerhebung_punktort, ',')::int AS herkunft_datenerhebung,
	kartendarstellung,
	ST_Force2D(wkb_geometry) AS wkb_geometry
FROM ax_punktortag;

-- Erzeugen der finalen Grenzpunkt-Tabelle
CREATE TABLE pt_grenzpunkt (gid serial PRIMARY KEY,
	gml_id CHARACTER VARYING,
	abmarkung_marke integer NOT NULL,
	abmarkung_marke_text CHARACTER VARYING,
	besonderepunktnummer CHARACTER VARYING,
	punktkennung CHARACTER VARYING,
	relativehoehe double PRECISION,
	genauigkeitsstufe integer,
	genauigkeitsstufe_text CHARACTER VARYING,
	herkunft CHARACTER VARYING,
	datenerhebung integer,
	datenerhebung_text CHARACTER VARYING,
	zeitpunktderentstehung CHARACTER VARYING,
	wkb_geometry geometry(Point,25832));

INSERT INTO
	pt_grenzpunkt (gml_id,
	abmarkung_marke,
	abmarkung_marke_text,
	besonderepunktnummer,
	punktkennung,
	relativehoehe,
	genauigkeitsstufe,
	genauigkeitsstufe_text,
	herkunft,
	datenerhebung,
	datenerhebung_text,
	zeitpunktderentstehung,
	wkb_geometry)
SELECT
	gp.gml_id,
	gp.abmarkung_marke,
	ma.beschreibung AS abmarkung_marke_text,
	gp.besonderepunktnummer,
	gp.punktkennung,
	gp.relativehoehe,
	pta.genauigkeitsstufe,
	gstp.beschreibung AS genauigkeitsstufe_text,
	pta.herkunft,
	pta.herkunft_datenerhebung AS datenerhebung,
	dp.beschreibung AS datenerhebung_text,
	gp.zeitpunktderentstehung,
	pta.wkb_geometry
FROM
	pt_unnested_punktorte_ta pta
INNER JOIN ax_grenzpunkt gp ON
	pta.istteilvon = gp.gml_id
INNER JOIN ax_marke ma ON
	gp.abmarkung_marke = ma.wert
INNER JOIN ax_genauigkeitsstufe_punktort gstp ON 
	pta.genauigkeitsstufe = gstp.wert 
INNER JOIN ax_datenerhebung_punktort dp ON 
	pta.herkunft_datenerhebung = dp.wert
WHERE pta.kartendarstellung = 'true';

-- Erzeugen der finalen Aufnahmepunkt-Tabelle
CREATE TABLE pt_aufnahmepunkt (gid serial PRIMARY KEY,
	gml_id CHARACTER VARYING,
	vermarkung_marke integer NOT NULL,
	vermarkung_marke_text CHARACTER VARYING,
	punktkennung CHARACTER VARYING,
	relativehoehe double PRECISION,
	genauigkeitsstufe integer,
	genauigkeitsstufe_text CHARACTER VARYING,
	herkunft CHARACTER VARYING,
	datenerhebung integer,
	datenerhebung_text CHARACTER VARYING,
	wkb_geometry geometry(Point, 25832));

INSERT INTO
	pt_aufnahmepunkt (gml_id,
	vermarkung_marke,
	vermarkung_marke_text,
	punktkennung,
	relativehoehe,
	genauigkeitsstufe,
	genauigkeitsstufe_text,
	herkunft,
	datenerhebung,
	datenerhebung_text,
	wkb_geometry) 
SELECT
	ap.gml_id,
	ap.vermarkung_marke,
	ma.beschreibung AS abmarkung_marke_text,
	ap.punktkennung,
	ap.relativehoehe,
	pau.genauigkeitsstufe,
	gstp.beschreibung AS genauigkeitsstufe_text,
	pau.herkunft,
	pau.herkunft_datenerhebung AS datenerhebung,
	dp.beschreibung AS datenerhebung_text,
	pau.wkb_geometry
FROM
	pt_unnested_punktorte_au pau
INNER JOIN ax_aufnahmepunkt ap ON
	pau.istteilvon = ap.gml_id
INNER JOIN ax_marke ma ON
	ap.vermarkung_marke = ma.wert
INNER JOIN ax_genauigkeitsstufe_punktort gstp ON 
	pau.genauigkeitsstufe = gstp.wert 
INNER JOIN ax_datenerhebung_punktort dp ON 
	pau.herkunft_datenerhebung = dp.wert;

-- Erzeugen der finalen Sicherungspunkt-Tabelle
CREATE TABLE pt_sicherungspunkt (gid serial PRIMARY KEY,
	gml_id CHARACTER VARYING,
	vermarkung_marke integer NOT NULL,
	vermarkung_marke_text CHARACTER VARYING,
	punktkennung CHARACTER VARYING,
	relativehoehe double PRECISION,
	genauigkeitsstufe integer,
	genauigkeitsstufe_text CHARACTER VARYING,
	herkunft CHARACTER VARYING,
	datenerhebung integer,
	datenerhebung_text CHARACTER VARYING,
	wkb_geometry geometry(Point, 25832));

INSERT INTO
	pt_sicherungspunkt (gml_id,
	vermarkung_marke,
	vermarkung_marke_text,
	punktkennung,
	relativehoehe,
	genauigkeitsstufe,
	genauigkeitsstufe_text,
	herkunft,
	datenerhebung,
	datenerhebung_text,
	wkb_geometry) 
SELECT
	sp.gml_id,
	sp.vermarkung_marke,
	ma.beschreibung AS abmarkung_marke_text,
	sp.punktkennung,
	sp.relativehoehe,
	pau.genauigkeitsstufe,
	gstp.beschreibung AS genauigkeitsstufe_text,
	pau.herkunft,
	pau.herkunft_datenerhebung AS datenerhebung,
	dp.beschreibung AS datenerhebung_text,
	pau.wkb_geometry
FROM
	pt_unnested_punktorte_au pau
INNER JOIN ax_sicherungspunkt sp ON
	pau.istteilvon = sp.gml_id
INNER JOIN ax_marke ma ON
	sp.vermarkung_marke = ma.wert
INNER JOIN ax_genauigkeitsstufe_punktort gstp ON 
	pau.genauigkeitsstufe = gstp.wert 
INNER JOIN ax_datenerhebung_punktort dp ON 
	pau.herkunft_datenerhebung = dp.wert;

-- Erzeugen der finalen sonstigen Vermessungspunkt-Tabelle
CREATE TABLE pt_sonstigervermessungspunkt (gid serial PRIMARY KEY,
	gml_id CHARACTER VARYING,
	vermarkung_marke integer NOT NULL,
	vermarkung_marke_text CHARACTER VARYING,
	punktkennung CHARACTER VARYING,
	relativehoehe double PRECISION,
	genauigkeitsstufe integer,
	genauigkeitsstufe_text CHARACTER VARYING,
	herkunft CHARACTER VARYING,
	datenerhebung integer,
	datenerhebung_text CHARACTER VARYING,
	wkb_geometry geometry(Point, 25832));

INSERT INTO
	pt_sonstigervermessungspunkt (gml_id,
	vermarkung_marke,
	vermarkung_marke_text,
	punktkennung,
	relativehoehe,
	genauigkeitsstufe,
	genauigkeitsstufe_text,
	herkunft,
	datenerhebung,
	datenerhebung_text,
	wkb_geometry) 
SELECT
	vp.gml_id,
	vp.vermarkung_marke,
	ma.beschreibung AS abmarkung_marke_text,
	vp.punktkennung,
	vp.relativehoehe,
	pau.genauigkeitsstufe,
	gstp.beschreibung AS genauigkeitsstufe_text,
	pau.herkunft,
	pau.herkunft_datenerhebung AS datenerhebung,
	dp.beschreibung AS datenerhebung_text,
	pau.wkb_geometry
FROM
	pt_unnested_punktorte_au pau
INNER JOIN ax_sonstigervermessungspunkt vp ON
	pau.istteilvon = vp.gml_id
INNER JOIN ax_marke ma ON
	vp.vermarkung_marke = ma.wert
INNER JOIN ax_genauigkeitsstufe_punktort gstp ON 
	pau.genauigkeitsstufe = gstp.wert 
INNER JOIN ax_datenerhebung_punktort dp ON 
	pau.herkunft_datenerhebung = dp.wert;

-- Erzeugen der finalen sonstigen besonderer Bauwerkspunkt-Tabelle
CREATE TABLE pt_besondererbauwerkspunkt (gid serial PRIMARY KEY,
	gml_id CHARACTER VARYING,
	punktkennung CHARACTER VARYING,
	genauigkeitsstufe integer,
	genauigkeitsstufe_text CHARACTER VARYING,
	herkunft CHARACTER VARYING,
	datenerhebung integer,
	datenerhebung_text CHARACTER VARYING,
	wkb_geometry geometry(Point, 25832));

INSERT INTO
	pt_besondererbauwerkspunkt (gml_id,
	punktkennung,
	genauigkeitsstufe,
	genauigkeitsstufe_text,
	herkunft,
	datenerhebung,
	datenerhebung_text,
	wkb_geometry) 
SELECT
	bbp.gml_id,
	bbp.punktkennung,
	pag.genauigkeitsstufe,
	gstp.beschreibung AS genauigkeitsstufe_text,
	pag.herkunft,
	pag.herkunft_datenerhebung AS datenerhebung,
	dp.beschreibung AS datenerhebung_text,
	pag.wkb_geometry
FROM
	pt_unnested_punktorte_ag pag
INNER JOIN ax_besondererbauwerkspunkt bbp ON
	pag.istteilvon = bbp.gml_id
INNER JOIN ax_genauigkeitsstufe_punktort gstp ON 
	pag.genauigkeitsstufe = gstp.wert 
INNER JOIN ax_datenerhebung_punktort dp ON 
	pag.herkunft_datenerhebung = dp.wert
WHERE pag.kartendarstellung = 'true';

-- Erzeugen der finalen sonstigen besonderer Gebäudepunkt-Tabelle
CREATE TABLE pt_besonderergebaeudepunkt (gid serial PRIMARY KEY,
	gml_id CHARACTER VARYING,
	punktkennung CHARACTER VARYING,
	genauigkeitsstufe integer,
	genauigkeitsstufe_text CHARACTER VARYING,
	herkunft CHARACTER VARYING,
	datenerhebung integer,
	datenerhebung_text CHARACTER VARYING,
	wkb_geometry geometry(Point, 25832));

INSERT INTO
	pt_besonderergebaeudepunkt (gml_id,
	punktkennung,
	genauigkeitsstufe,
	genauigkeitsstufe_text,
	herkunft,
	datenerhebung,
	datenerhebung_text,
	wkb_geometry) 
SELECT
	bgp.gml_id,
	bgp.punktkennung,
	pag.genauigkeitsstufe,
	gstp.beschreibung AS genauigkeitsstufe_text,
	pag.herkunft,
	pag.herkunft_datenerhebung AS datenerhebung,
	dp.beschreibung AS datenerhebung_text,
	pag.wkb_geometry
FROM
	pt_unnested_punktorte_ag pag
INNER JOIN ax_besonderergebaeudepunkt bgp ON
	pag.istteilvon = bgp.gml_id
INNER JOIN ax_genauigkeitsstufe_punktort gstp ON 
	pag.genauigkeitsstufe = gstp.wert 
INNER JOIN ax_datenerhebung_punktort dp ON 
	pag.herkunft_datenerhebung = dp.wert
WHERE pag.kartendarstellung = 'true';

--Alle neuen Tabellen VACUUMieren
VACUUM ANALYZE pt_grenzpunkt;
VACUUM ANALYZE pt_aufnahmepunkt;
VACUUM ANALYZE pt_sicherungspunkt;
VACUUM ANALYZE pt_sonstigervermessungspunkt;
VACUUM ANALYZE pt_besondererbauwerkspunkt;
VACUUM ANALYZE pt_besonderergebaeudepunkt;


-- INDEX auf Tabellen--
CREATE INDEX pt_grenzpunkt_geom ON pt_grenzpunkt USING gist (wkb_geometry) TABLESPACE pgdata;
CREATE INDEX pt_grenzpunkt_gml_id ON pt_grenzpunkt USING btree (gml_id COLLATE pg_catalog."default") TABLESPACE pgdata;
CREATE INDEX pt_grenzpunkt_punktkennung ON pt_grenzpunkt USING btree (punktkennung COLLATE pg_catalog."default") TABLESPACE pgdata;

CREATE INDEX pt_aufnahmepunkt_geom ON pt_aufnahmepunkt USING gist (wkb_geometry) TABLESPACE pgdata;
CREATE INDEX pt_aufnahmepunkt_gml_id ON pt_aufnahmepunkt USING btree (gml_id COLLATE pg_catalog."default") TABLESPACE pgdata;
CREATE INDEX pt_aufnahmepunktt_punktkennung ON pt_aufnahmepunkt USING btree (punktkennung COLLATE pg_catalog."default") TABLESPACE pgdata;

CREATE INDEX pt_sicherungspunkt_geom ON pt_sicherungspunkt USING gist (wkb_geometry) TABLESPACE pgdata;
CREATE INDEX pt_sicherungspunkt_gml_id ON pt_sicherungspunkt USING btree (gml_id COLLATE pg_catalog."default") TABLESPACE pgdata;
CREATE INDEX pt_sicherungspunkt_punktkennung ON pt_sicherungspunkt USING btree (punktkennung COLLATE pg_catalog."default") TABLESPACE pgdata;

CREATE INDEX pt_sonstigervermessungspunkt_geom ON pt_sonstigervermessungspunkt USING gist (wkb_geometry) TABLESPACE pgdata;
CREATE INDEX pt_sonstigervermessungspunkt_gml_id ON pt_sonstigervermessungspunkt USING btree (gml_id COLLATE pg_catalog."default") TABLESPACE pgdata;
CREATE INDEX pt_sonstigervermessungspunkt_punktkennung ON pt_sonstigervermessungspunkt USING btree (punktkennung COLLATE pg_catalog."default") TABLESPACE pgdata;

CREATE INDEX pt_pt_besondererbauwerkspunkt_geom ON pt_besondererbauwerkspunkt USING gist (wkb_geometry) TABLESPACE pgdata;
CREATE INDEX pt_pt_besondererbauwerkspunkt_gml_id ON pt_besondererbauwerkspunkt USING btree (gml_id COLLATE pg_catalog."default") TABLESPACE pgdata;
CREATE INDEX pt_pt_besondererbauwerkspunkt_punktkennung ON pt_besondererbauwerkspunkt USING btree (punktkennung COLLATE pg_catalog."default") TABLESPACE pgdata;

CREATE INDEX pt_besonderergebaeudepunkt_geom ON pt_besonderergebaeudepunkt USING gist (wkb_geometry) TABLESPACE pgdata;
CREATE INDEX pt_besonderergebaeudepunkt_gml_id ON pt_besonderergebaeudepunkt USING btree (gml_id COLLATE pg_catalog."default") TABLESPACE pgdata;
CREATE INDEX pt_besonderergebaeudepunkt_punktkennung ON pt_besonderergebaeudepunkt USING btree (punktkennung COLLATE pg_catalog."default") TABLESPACE pgdata;

-- Constrains--
ALTER TABLE pt_grenzpunkt ADD CONSTRAINT enforce_dims_the_geom CHECK (st_ndims(wkb_geometry) = 2);
ALTER TABLE pt_grenzpunkt ADD CONSTRAINT enforce_srid_the_geom CHECK (st_srid(wkb_geometry) = 25832);

ALTER TABLE pt_aufnahmepunkt ADD CONSTRAINT enforce_dims_the_geom CHECK (st_ndims(wkb_geometry) = 2);
ALTER TABLE pt_aufnahmepunkt ADD CONSTRAINT enforce_srid_the_geom CHECK (st_srid(wkb_geometry) = 25832);

ALTER TABLE pt_sicherungspunkt ADD CONSTRAINT enforce_dims_the_geom CHECK (st_ndims(wkb_geometry) = 2);
ALTER TABLE pt_sicherungspunkt ADD CONSTRAINT enforce_srid_the_geom CHECK (st_srid(wkb_geometry) = 25832);

ALTER TABLE pt_sonstigervermessungspunkt ADD CONSTRAINT enforce_dims_the_geom CHECK (st_ndims(wkb_geometry) = 2);
ALTER TABLE pt_sonstigervermessungspunkt ADD CONSTRAINT enforce_srid_the_geom CHECK (st_srid(wkb_geometry) = 25832);

ALTER TABLE pt_besondererbauwerkspunkt ADD CONSTRAINT enforce_dims_the_geom CHECK (st_ndims(wkb_geometry) = 2);
ALTER TABLE pt_besondererbauwerkspunkt ADD CONSTRAINT enforce_srid_the_geom CHECK (st_srid(wkb_geometry) = 25832);

ALTER TABLE pt_besonderergebaeudepunkt ADD CONSTRAINT enforce_dims_the_geom CHECK (st_ndims(wkb_geometry) = 2);
ALTER TABLE pt_besonderergebaeudepunkt ADD CONSTRAINT enforce_srid_the_geom CHECK (st_srid(wkb_geometry) = 25832);

-- INSERT into postgis_21.geometry_column--s
INSERT INTO postgis.geometry_columns(f_table_catalog,f_table_schema, f_table_name, f_geometry_column,coord_dimension, srid, type)
    VALUES ('','public', 'pt_grenzpunkt', 'wkb_geometry', 2, 25832, 'POINT');

INSERT INTO postgis.geometry_columns(f_table_catalog,f_table_schema, f_table_name, f_geometry_column,coord_dimension, srid, type)
    VALUES ('','public', 'pt_aufnahmepunkt', 'wkb_geometry', 2, 25832, 'POINT');

INSERT INTO postgis.geometry_columns(f_table_catalog,f_table_schema, f_table_name, f_geometry_column,coord_dimension, srid, type)
    VALUES ('','public', 'pt_sicherungspunkt', 'wkb_geometry', 2, 25832, 'POINT');

INSERT INTO postgis.geometry_columns(f_table_catalog,f_table_schema, f_table_name, f_geometry_column,coord_dimension, srid, type)
    VALUES ('','public', 'pt_sonstigervermessungspunkt', 'wkb_geometry', 2, 25832, 'POINT');

INSERT INTO postgis.geometry_columns(f_table_catalog,f_table_schema, f_table_name, f_geometry_column,coord_dimension, srid, type)
    VALUES ('','public', 'pt_besondererbauwerkspunkt', 'wkb_geometry', 2, 25832, 'POINT');

INSERT INTO postgis.geometry_columns(f_table_catalog,f_table_schema, f_table_name, f_geometry_column,coord_dimension, srid, type)
    VALUES ('','public', 'pt_besonderergebaeudepunkt', 'wkb_geometry', 2, 25832, 'POINT');
