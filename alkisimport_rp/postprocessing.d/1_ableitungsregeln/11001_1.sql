SET client_encoding TO 'UTF8';
SET search_path = :"alkis_schema", :"parent_schema", :"postgis_schema", public;

--
-- Flurstücke (11001)
--

SELECT 'Flurstücke werden verarbeitet.';

-- Flurstücke
INSERT INTO po_polygons(gml_id,gml_ids,thema,layer,polygon,signaturnummer,modell)
SELECT
	gml_id,
	ARRAY[gml_id] AS gml_ids,
	'Flurstücke' AS thema,
	'ax_flurstueck' AS layer,
	st_multi(wkb_geometry) AS polygon,
	2028 AS signaturnummer,
	advstandardmodell||sonstigesmodell
FROM po_lastrun, ax_flurstueck
WHERE endet IS NULL AND beginnt>lastrun;

UPDATE ax_flurstueck SET abweichenderrechtszustand='false' WHERE abweichenderrechtszustand IS NULL;

SELECT count(*) || ' Flurstücke mit abweichendem Rechtszustand.' FROM ax_flurstueck WHERE abweichenderrechtszustand='true';

-- Flurstücksgrenzen mit abweichendem Rechtszustand
SELECT 'Bestimme Grenzen mit abweichendem Rechtszustand';
INSERT INTO po_lines(gml_id,gml_ids,thema,layer,line,signaturnummer,modell)
SELECT
	a.gml_id,
	ARRAY[a.gml_id,b.gml_id] AS gml_ids,
	'Flurstücke' AS thema,
	'ax_flurstueck' AS layer,
	st_multi( (SELECT st_collect(geom) FROM st_dump( st_intersection(a.wkb_geometry,b.wkb_geometry) ) WHERE geometrytype(geom)='LINESTRING') ) AS line,
	2029 AS signaturnummer,
	a.advstandardmodell||a.sonstigesmodell||b.advstandardmodell||b.sonstigesmodell AS modell
FROM po_lastrun, ax_flurstueck a, ax_flurstueck b
WHERE a.ogc_fid<b.ogc_fid
  AND a.abweichenderrechtszustand='true' AND b.abweichenderrechtszustand='true'
  AND a.wkb_geometry && b.wkb_geometry AND st_intersects(a.wkb_geometry,b.wkb_geometry)
  AND a.endet IS NULL AND b.endet IS NULL AND greatest(a.beginnt,b.beginnt)>lastrun;