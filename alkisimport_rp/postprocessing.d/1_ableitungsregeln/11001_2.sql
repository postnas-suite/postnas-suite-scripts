SET client_encoding TO 'UTF8';
SET search_path = :"alkis_schema", :"parent_schema", :"postgis_schema", public;

--
-- Flurstücke (11001)
--

--                    ARZ
-- Schrägstrich: 4113 4122
-- Bruchstrich:  4115 4123

-- Flurstücksnummern
-- Schrägstrichdarstellung
SELECT 'Erzeuge Flurstücksnummern in Schrägstrichdarstellung...';
INSERT INTO po_labels(gml_id,gml_ids,thema,layer,point,text,signaturnummer,drehwinkel,horizontaleausrichtung,vertikaleausrichtung,skalierung,fontsperrung,modell)
SELECT
	o.gml_id,
	ARRAY[o.gml_id, t.gml_id, d.gml_id] AS gml_ids,
	'Flurstücke' AS thema,
	'ax_flurstueck_nummer' AS layer,
	coalesce(t.wkb_geometry,st_centroid(o.wkb_geometry)) AS point,
	coalesce(replace(t.schriftinhalt,'-','/'),o.zaehler||'/'||o.nenner,o.zaehler::text) AS text,
	coalesce(d.signaturnummer,t.signaturnummer,CASE WHEN o.abweichenderrechtszustand='true' THEN '4122' ELSE '4113' END) AS signaturnummer,
	t.drehwinkel, t.horizontaleausrichtung, t.vertikaleausrichtung, t.skalierung, t.fontsperrung,
	coalesce(t.modelle,o.advstandardmodell||o.sonstigesmodell) AS modell
FROM po_lastrun, ax_flurstueck o
LEFT OUTER JOIN po_pto t ON o.gml_id=t.dientzurdarstellungvon AND t.art='ZAE_NEN'
LEFT OUTER JOIN po_darstellung d ON o.gml_id=d.dientzurdarstellungvon AND d.art='ZAE_NEN'
WHERE o.endet IS NULL AND greatest(o.beginnt,t.beginnt,d.beginnt)>lastrun AND (
	CASE
	WHEN :alkis_fnbruch
	THEN coalesce(t.signaturnummer,'4115') IN ('4113','4122')
	ELSE coalesce(t.signaturnummer,'4113') NOT IN ('4115', '4123')
	END
	OR coalesce(o.nenner,'0')='0'
);