SET client_encoding TO 'UTF8';
SET search_path = :"alkis_schema", :"parent_schema", :"postgis_schema", public;

--
-- Flurstücke (11001)
--

--                    ARZ
-- Schrägstrich: 4113 4122
-- Bruchstrich:  4115 4123

-- Flurstücksnummern
-- Zuordnungspfeile
SELECT 'Erzeuge Zuordnungspfeile...';
INSERT INTO po_lines(gml_id,gml_ids,thema,layer,line,signaturnummer,modell)
SELECT
	o.gml_id,
	ARRAY[o.gml_id, l.gml_id] AS gml_ids,
	'Flurstücke' AS thema,
	'ax_flurstueck_zuordnung' AS layer,
	st_multi(l.wkb_geometry) AS line,
	CASE WHEN o.abweichenderrechtszustand='true' THEN 2005 ELSE 2004 END AS signaturnummer,
	coalesce(l.modelle,o.advstandardmodell||o.sonstigesmodell) AS modell
FROM po_lastrun, ax_flurstueck o
JOIN po_lpo l ON o.gml_id=l.dientzurdarstellungvon AND l.gml_id<>'TRIGGER'
  -- AND l.art='Pfeil' -- art in RP nicht immer gesetzt
WHERE o.endet IS NULL AND greatest(o.beginnt,l.beginnt)>lastrun;

-- Überhaken
SELECT 'Erzeuge Überhaken...';
INSERT INTO po_points(gml_id,gml_ids,thema,layer,point,drehwinkel,signaturnummer,modell)
SELECT
	o.gml_id,
	ARRAY[o.gml_id,p.gml_id] AS gml_ids,
	'Flurstücke' AS thema,
	'ax_flurstueck' AS layer,
	st_multi(p.wkb_geometry) AS point,
	coalesce(p.drehwinkel,0) AS drehwinkel,
	CASE WHEN o.abweichenderrechtszustand='true' THEN 3011 ELSE 3010 END AS signaturnummer,
	coalesce(p.modelle,o.advstandardmodell||o.sonstigesmodell) AS modell
FROM po_lastrun, ax_flurstueck o
JOIN po_ppo p ON o.gml_id=p.dientzurdarstellungvon AND p.art='Haken' AND p.gml_id<>'TRIGGER'
WHERE o.endet IS NULL AND greatest(o.beginnt,o.beginnt)>lastrun;
