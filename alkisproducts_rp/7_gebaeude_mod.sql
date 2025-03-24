--Lagebezeichnung mit Hausnummer unnesten
SELECT gml_id, unnest(zeigtauf) AS zeigtauf_id
INTO pt_zag
FROM ax_gebaeude;

SELECT gml_id, unnest(zeigtauf) AS zeigtauf_id
INTO pt_zat
FROM ax_turm;

--Lagebezeichnungen in einer Tabelle sammeln 
(SELECT zat.gml_id AS gml_id, zat.zeigtauf_id, sh.bezeichnung AS bezeichnung, sh.hausnummer AS hausnummer, substr(sh.schluesselgesamt,1,8) AS ags
INTO pt_lagebez_einzel_g
FROM pt_zat zat
LEFT JOIN pt_strassemithausnummer sh ON zat.zeigtauf_id = sh.gml_id)
UNION
(SELECT zag.gml_id AS gml_id, zag.zeigtauf_id, sh.bezeichnung AS bezeichnung, sh.hausnummer AS hausnummer, substr(sh.schluesselgesamt,1,8) AS ags
FROM pt_zag zag
LEFT JOIN pt_strassemithausnummer sh ON zag.zeigtauf_id = sh.gml_id);

VACUUM ANALYZE pt_lagebez_einzel_g; 

--Lagebezeichnungen zu Array aggregieren und als Zeichenkette umformen
SELECT gml_id, array_to_string(array_agg(lagebez ORDER BY lagebez),'; ') AS lagebeztxt, array_to_string(array_agg(DISTINCT ags),', ') AS ags 
INTO pt_lagebez_gesamt_g
FROM
    (SELECT gml_id, 
     CASE
     WHEN string_agg(hausnummer, '') IS NOT NULL THEN concat(bezeichnung, ' ', array_to_string(array_agg(hausnummer ORDER BY hausnummer),', ')) 
     ELSE array_to_string(array_agg(bezeichnung ORDER BY bezeichnung),', ')
     END AS lagebez, 
     array_to_string(array_agg(DISTINCT ags),', ') AS ags
     FROM pt_lagebez_einzel_g
     GROUP BY gml_id, bezeichnung) agg
GROUP BY gml_id;

--Centroid zu AX_Gebaeude hinzufügen
ALTER TABLE ax_gebaeude ADD COLUMN wkb_centroid geometry(Geometry,25832);
UPDATE ax_gebaeude SET wkb_centroid = ST_Centroid(wkb_geometry);
CREATE INDEX ax_gebaeude_wkb_centroid_idx ON ax_gebaeude USING gist (wkb_centroid);

--Temporaere Gebäude-Tabelle erstellen
SELECT cast(concat(geb.gml_id,'BL') as character varying) AS oid,
        geb.beginnt::date AS aktualit,
        ST_Buffer(geb.wkb_geometry, 0) AS geometrie,
        cast('Gebäude' as character varying) AS gebnutzbez,
	gfu.beschreibung AS funktion,
	CASE
	WHEN geb.gebaeudefunktion = '2465' THEN cast(NULL as character varying)
	ELSE cast(concat('31001_',geb.gebaeudefunktion) as character varying) 
	END AS gfkzshh,
	lge.beschreibung AS rellage,
	array_to_string(geb.name, ';') AS name,
	cast(geb.anzahlderoberirdischengeschosse as integer) AS anzahlgs,
	CASE 
	WHEN lg.ags IS NULL THEN concat('07', gem.gmdesch) 
	-- PN 13.09.2021: Workaround um mehrere AGS auszuschließen
	WHEN char_length(lg.ags) > 8 THEN concat('07', gem.gmdesch)
	ELSE lg.ags 
	END AS gmdschl,
	lg.lagebeztxt
  INTO pt_gebaeude
  FROM ax_gebaeude geb
  LEFT JOIN ax_gebaeudefunktion gfu ON geb.gebaeudefunktion = gfu.wert
  LEFT JOIN ax_lagezurerdoberflaeche_gebaeude lge ON geb.lagezurerdoberflaeche = lge.wert
  LEFT JOIN pt_lagebez_gesamt_g lg ON geb.gml_id = lg.gml_id
  INNER JOIN gemeinde_rlp gem ON ST_Within(geb.wkb_centroid,gem.the_geom)
  WHERE ST_GeometryType(geb.wkb_geometry) = 'ST_Polygon' OR ST_GeometryType(geb.wkb_geometry) = 'ST_MultiPolygon';

--Centroid zu AX_Turm hinzufügen
ALTER TABLE ax_turm ADD COLUMN wkb_centroid geometry(Geometry,25832);
UPDATE ax_turm SET wkb_centroid = ST_Centroid(wkb_geometry);
CREATE INDEX ax_turm_wkb_centroid_idx ON ax_turm USING gist (wkb_centroid);

--Bauwerksfunktion unnesten
SELECT gml_id, unnest(bauwerksfunktion) as bauwerksfunktion
INTO pt_bft
FROM ax_turm;

ALTER TABLE ax_turm ADD COLUMN ubauwerksfunktion integer;
UPDATE ax_turm ax SET ubauwerksfunktion = bft.bauwerksfunktion
FROM pt_bft bft 
WHERE ax.gml_id = bft.gml_id;

--Temporaere Turm-Tabelle erstellen
SELECT cast(concat(t.gml_id,'BL') as character varying) AS oid,
        t.beginnt::date AS aktualit,
        ST_Buffer(t.wkb_geometry, 0) AS geometrie,
        cast('Turm' as character varying) AS gebnutzbez,
        bft.beschreibung AS funktion,
        cast(concat('51001_',t.ubauwerksfunktion) as character varying) AS gfkzshh,
        cast(NULL as character varying) AS rellage,
        t.name,
        cast(NULL as integer) AS anzahlgs,
        CASE 
        WHEN lg.ags IS NULL THEN concat('07', gem.gmdesch) 
        ELSE lg.ags 
        END AS gmdschl,
        lg.lagebeztxt
  INTO pt_turm
  FROM ax_turm t
  LEFT JOIN ax_bauwerksfunktion_turm bft ON t.ubauwerksfunktion = bft.wert
  LEFT JOIN pt_lagebez_gesamt_g lg ON t.gml_id = lg.gml_id
  INNER JOIN gemeinde_rlp gem ON ST_Within(t.wkb_centroid,gem.the_geom)
  WHERE ST_GeometryType(t.wkb_geometry) = 'ST_Polygon' OR ST_GeometryType(t.wkb_geometry) = 'ST_MultiPolygon';

--Centroid zu AX_BauwerkOderAnlageFuerIndustrieUndGewerbe hinzufügen
ALTER TABLE ax_bauwerkoderanlagefuerindustrieundgewerbe ADD COLUMN wkb_centroid geometry(Geometry,25832);
UPDATE ax_bauwerkoderanlagefuerindustrieundgewerbe SET wkb_centroid = ST_Centroid(wkb_geometry);
CREATE INDEX ax_bauwerkoderanlagefuerindustrieundgewerbe_wkb_centroid_idx ON ax_bauwerkoderanlagefuerindustrieundgewerbe USING gist (wkb_centroid);

--Temporaere BauwerkOderAnlageFuerIndustrieUndGewerbe-Tabelle erstellen
SELECT cast(concat(ig.gml_id,'BL') as character varying) AS oid,
        ig.beginnt::date AS aktualit,
        ST_Buffer(ig.wkb_geometry, 0) AS geometrie,
        cast('Bauwerk oder Anlage für Industrie und Gewerbe' as character varying) AS gebnutzbez,
        bfi.beschreibung AS funktion,
	CASE
	WHEN ig.bauwerksfunktion = '1210' OR ig.bauwerksfunktion = '1270' THEN cast(NULL as character varying)
	ELSE cast(concat('51002_',ig.bauwerksfunktion) as character varying) 
	END AS gfkzshh,
        cast(NULL as character varying) AS rellage,
        ig.name,
        cast(NULL as integer) AS anzahlgs,
        concat('07', gem.gmdesch) AS gmdschl,
        cast(NULL as character varying) AS lagebeztxt
  INTO pt_bauwerkoderanlagefuerindustrieundgewerbe
  FROM ax_bauwerkoderanlagefuerindustrieundgewerbe ig
  LEFT JOIN ax_bauwerksfunktion_bauwerkoderanlagefuerindustrieundgewer bfi ON ig.bauwerksfunktion = bfi.wert
  INNER JOIN gemeinde_rlp gem ON ST_Within(ig.wkb_centroid,gem.the_geom)
  WHERE ST_GeometryType(ig.wkb_geometry) = 'ST_Polygon' OR ST_GeometryType(ig.wkb_geometry) = 'ST_MultiPolygon';

--Centroid zu AX_VorratsbehaelterSpeicherbauwerk hinzufügen
ALTER TABLE ax_vorratsbehaelterspeicherbauwerk ADD COLUMN wkb_centroid geometry(Geometry,25832);
UPDATE ax_vorratsbehaelterspeicherbauwerk SET wkb_centroid = ST_Centroid(wkb_geometry);
CREATE INDEX ax_vorratsbehaelterspeicherbauwerk_wkb_centroid_idx ON ax_vorratsbehaelterspeicherbauwerk USING gist (wkb_centroid);

--Temporaere VorratsbehaelterSpeicherbauwerk-Tabelle erstellen
SELECT cast(concat(vs.gml_id,'BL') as character varying) AS oid,
        vs.beginnt::date AS aktualit,
        ST_Buffer(vs.wkb_geometry, 0) AS geometrie,
        cast('Vorratsbehälter, Speicherbauwerk' as character varying) AS gebnutzbez,
        bfv.beschreibung AS funktion,
        cast(concat('51003_',vs.bauwerksfunktion) as character varying) AS gfkzshh,
        lvs.beschreibung AS rellage,
        vs.name,
        cast(NULL as integer) AS anzahlgs,
        concat('07', gem.gmdesch) AS gmdschl,
        cast(NULL as character varying) AS lagebeztxt
  INTO pt_vorratsbehaelterspeicherbauwerk
  FROM ax_vorratsbehaelterspeicherbauwerk vs
  LEFT JOIN ax_bauwerksfunktion_vorratsbehaelterspeicherbauwerk bfv ON vs.bauwerksfunktion = bfv.wert
  LEFT JOIN ax_lagezurerdoberflaeche_vorratsbehaelterspeicherbauwerk lvs ON vs.lagezurerdoberflaeche = lvs.wert
  INNER JOIN gemeinde_rlp gem ON ST_Within(vs.wkb_centroid,gem.the_geom)
  WHERE ST_GeometryType(vs.wkb_geometry) = 'ST_Polygon' OR ST_GeometryType(vs.wkb_geometry) = 'ST_MultiPolygon';

--Centroid zu AX_BauwerkOderAnlageFuerSportFreizeitUndErholung hinzufügen
ALTER TABLE ax_bauwerkoderanlagefuersportfreizeitunderholung ADD COLUMN wkb_centroid geometry(Geometry,25832);
UPDATE ax_bauwerkoderanlagefuersportfreizeitunderholung SET wkb_centroid = ST_Centroid(wkb_geometry);
CREATE INDEX ax_bauwerkoderanlagefuersportfreizeitunderholung_wkb_centroid_idx ON ax_bauwerkoderanlagefuersportfreizeitunderholung USING gist (wkb_centroid);

--Temporaere BauwerkOderAnlageFuerSportFreizeitUndErholung-Tabelle erstellen
SELECT cast(concat(sfe.gml_id,'BL') as character varying) AS oid,
        sfe.beginnt::date AS aktualit,
        ST_Buffer(sfe.wkb_geometry, 0) AS geometrie,
        cast('Bauwerk oder Anlage für Sport, Freizeit und Erholung' as character varying) AS gebnutzbez,
        bfs.beschreibung AS funktion,
        CASE
        WHEN sfe.bauwerksfunktion = '1410' THEN cast(NULL as character varying)
        ELSE cast(concat('51006_',sfe.bauwerksfunktion) as character varying)
        END AS gfkzshh,
        cast(NULL as character varying) AS rellage,
        sfe.name,
        cast(NULL as integer) AS anzahlgs,
        concat('07', gem.gmdesch) AS gmdschl,
        cast(NULL as character varying) AS lagebeztxt
  INTO pt_bauwerkoderanlagefuersportfreizeitunderholung
  FROM ax_bauwerkoderanlagefuersportfreizeitunderholung sfe
  LEFT JOIN ax_bauwerksfunktion_bauwerkoderanlagefuersportfreizeitunde bfs ON sfe.bauwerksfunktion = bfs.wert
  INNER JOIN gemeinde_rlp gem ON ST_Within(sfe.wkb_centroid,gem.the_geom)
  WHERE ST_GeometryType(sfe.wkb_geometry) = 'ST_Polygon' OR ST_GeometryType(sfe.wkb_geometry) = 'ST_MultiPolygon';

--Centroid zu AX_SonstigesBauwerkOderSonstigeEinrichtung hinzufügen
ALTER TABLE ax_sonstigesbauwerkodersonstigeeinrichtung ADD COLUMN wkb_centroid geometry(Geometry,25832);
UPDATE ax_sonstigesbauwerkodersonstigeeinrichtung SET wkb_centroid = ST_Centroid(wkb_geometry);
CREATE INDEX ax_sonstigesbauwerkodersonstigeeinrichtung_wkb_centroid_idx ON ax_sonstigesbauwerkodersonstigeeinrichtung USING gist (wkb_centroid);

--Temporaere SonstigesBauwerkOderSonstigeEinrichtung-Tabelle erstellen
SELECT cast(concat(son.gml_id,'BL') as character varying) AS oid,
        son.beginnt::date AS aktualit,
	ST_MakeValid(son.wkb_geometry) AS geometrie,
--        ST_Buffer(son.wkb_geometry, 0) AS geometrie,
        cast('Sonstiges Bauwerk oder sonstige Einrichtung' as character varying) AS gebnutzbez,
        bfe.beschreibung AS funktion,
        CASE
        WHEN son.bauwerksfunktion = '1781' THEN cast(NULL as character varying)
        ELSE cast(concat('51009_',son.bauwerksfunktion) as character varying)
        END AS gfkzshh,
        cast(NULL as character varying) AS rellage,
        son.name,
        cast(NULL as integer) AS anzahlgs,
        concat('07', gem.gmdesch) AS gmdschl,
        cast(NULL as character varying) AS lagebeztxt
  INTO pt_sonstigesbauwerkodersonstigeeinrichtung
  FROM ax_sonstigesbauwerkodersonstigeeinrichtung son
  LEFT JOIN ax_bauwerksfunktion_sonstigesbauwerkodersonstigeeinrichtun bfe ON son.bauwerksfunktion = bfe.wert
  INNER JOIN gemeinde_rlp gem ON ST_Within(son.wkb_centroid,gem.the_geom)
  WHERE ST_GeometryType(son.wkb_geometry) = 'ST_Polygon' OR ST_GeometryType(son.wkb_geometry) = 'ST_MultiPolygon';

--Centroid zu AX_Bauteil hinzufügen
ALTER TABLE ax_bauteil ADD COLUMN wkb_centroid geometry(Geometry,25832);
UPDATE ax_bauteil SET wkb_centroid = ST_Centroid(wkb_geometry);
CREATE INDEX ax_bauteil_wkb_centroid_idx ON ax_bauteil USING gist (wkb_centroid);

--Temporaere Bauteil-Tabelle erstellen
SELECT cast(concat(bat.gml_id,'BL') as character varying) AS oid,
        bat.beginnt::date AS aktualit,
        ST_Buffer(bat.wkb_geometry, 0) AS geometrie,
        cast('Bauteil' as character varying) AS gebnutzbez,
        art.beschreibung AS funktion,
        cast(NULL as character varying) AS gfkzshh,
        lbt.beschreibung AS rellage,
        cast(NULL as character varying) AS name,
        cast(bat.anzahlderoberirdischengeschosse as integer) AS anzahlgs,
        concat('07', gem.gmdesch) AS gmdschl,
        cast(NULL as character varying) AS lagebeztxt
  INTO pt_bauteil
  FROM ax_bauteil bat
  LEFT JOIN ax_bauart_bauteil art ON bat.bauart = art.wert
  LEFT JOIN ax_lagezurerdoberflaeche_gebaeude lbt ON bat.lagezurerdoberflaeche = lbt.wert
  INNER JOIN gemeinde_rlp gem ON ST_Within(bat.wkb_centroid,gem.the_geom)
  WHERE ST_GeometryType(bat.wkb_geometry) = 'ST_Polygon' OR ST_GeometryType(bat.wkb_geometry) = 'ST_MultiPolygon';

--Finale Tabelle erstellen
CREATE TABLE pt_gebaeudebauwerke (gid serial primary key, oid character varying, aktualit date, geometrie geometry(Geometry,25832), gebnutzbez character varying, funktion character varying, gfkzshh character varying, rellage character varying, name character varying, anzahlgs integer, gmdschl character varying(8), lagebeztxt character varying);
INSERT INTO pt_gebaeudebauwerke (oid, aktualit, geometrie, gebnutzbez, funktion, gfkzshh, rellage, name, anzahlgs, gmdschl, lagebeztxt) SELECT * FROM pt_bauteil;
INSERT INTO pt_gebaeudebauwerke (oid, aktualit, geometrie, gebnutzbez, funktion, gfkzshh, rellage, name, anzahlgs, gmdschl, lagebeztxt) SELECT * FROM pt_bauwerkoderanlagefuerindustrieundgewerbe;
INSERT INTO pt_gebaeudebauwerke (oid, aktualit, geometrie, gebnutzbez, funktion, gfkzshh, rellage, name, anzahlgs, gmdschl, lagebeztxt) SELECT * FROM pt_bauwerkoderanlagefuersportfreizeitunderholung;
INSERT INTO pt_gebaeudebauwerke (oid, aktualit, geometrie, gebnutzbez, funktion, gfkzshh, rellage, name, anzahlgs, gmdschl, lagebeztxt) SELECT * FROM pt_gebaeude;
INSERT INTO pt_gebaeudebauwerke (oid, aktualit, geometrie, gebnutzbez, funktion, gfkzshh, rellage, name, anzahlgs, gmdschl, lagebeztxt) SELECT * FROM pt_sonstigesbauwerkodersonstigeeinrichtung;
INSERT INTO pt_gebaeudebauwerke (oid, aktualit, geometrie, gebnutzbez, funktion, gfkzshh, rellage, name, anzahlgs, gmdschl, lagebeztxt) SELECT * FROM pt_turm;
INSERT INTO pt_gebaeudebauwerke (oid, aktualit, geometrie, gebnutzbez, funktion, gfkzshh, rellage, name, anzahlgs, gmdschl, lagebeztxt) SELECT * FROM pt_vorratsbehaelterspeicherbauwerk;

-- INDEX auf Tabelle--
CREATE INDEX pt_gebaeudebauwerke_geom ON pt_gebaeudebauwerke USING gist (geometrie) TABLESPACE pgdata;
CREATE INDEX pt_gebaeudebauwerke_oid ON pt_gebaeudebauwerke USING btree (oid COLLATE pg_catalog."default") TABLESPACE pgdata;
CREATE INDEX pt_gebaeudebauwerke_gebnutzbez ON pt_gebaeudebauwerke USING btree (gebnutzbez COLLATE pg_catalog."default") TABLESPACE pgdata;
CREATE INDEX pt_gebaeudebauwerke_gfkzshh ON pt_gebaeudebauwerke USING btree (gfkzshh COLLATE pg_catalog."default") TABLESPACE pgdata;
CREATE INDEX pt_gebaeudebauwerke_gmdschl ON pt_gebaeudebauwerke USING btree (gmdschl COLLATE pg_catalog."default") TABLESPACE pgdata;

-- Constrains--
ALTER TABLE pt_gebaeudebauwerke ADD CONSTRAINT enforce_dims_the_geom CHECK (st_ndims(geometrie) = 2);
ALTER TABLE pt_gebaeudebauwerke ADD CONSTRAINT enforce_srid_the_geom CHECK (st_srid(geometrie) = 25832);

-- INSERT into postgis_21.geometry_column--s
INSERT INTO postgis.geometry_columns(f_table_catalog,f_table_schema, f_table_name, f_geometry_column,coord_dimension, srid, type)
    VALUES ('','public', 'pt_gebaeudebauwerke', 'geometrie', 2, 25832, 'MULTIPOLYGON');

