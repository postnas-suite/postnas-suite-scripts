SET client_encoding TO 'UTF8';
SET search_path = :"alkis_schema", :"parent_schema", :"postgis_schema", public;

--
-- Flurstücke (11001)
--

--                    ARZ
-- Schrägstrich: 4113 4122
-- Bruchstrich:  4115 4123

-- Flurstücksnummern
-- Bruchstrich
SELECT 'Erzeuge Flurstücksbruchstriche...';
INSERT INTO po_lines(gml_id,gml_ids,thema,layer,line,signaturnummer,modell)
SELECT
	gml_id,
	gml_ids,
	'Flurstücke' AS thema,
	'ax_flurstueck_nummer' AS layer,
	CASE
	WHEN horizontaleausrichtung='rechtsbündig' THEN st_multi(st_rotate(st_makeline(st_translate(point, -(2*len), 0.0), st_translate(point, 0.0, 0.0)),drehwinkel,st_x(point),st_y(point)))
	WHEN horizontaleausrichtung='linksbündig' THEN st_multi(st_rotate(st_makeline(st_translate(point, 0.0, 0.0), st_translate(point, 2*len, 0.0)),drehwinkel,st_x(point),st_y(point)))
	ELSE st_multi(st_rotate(st_makeline(st_translate(point, -len, 0.0), st_translate(point, len, 0.0)),drehwinkel,st_x(point),st_y(point)))
	END AS line,
	signaturnummer,
	modell
FROM (
	SELECT
		gml_id,
		gml_ids,
		point,
		greatest(lenz, lenn) AS len,
		signaturnummer,
		modell,
		drehwinkel,
		horizontaleausrichtung
	FROM (
		SELECT
			o.gml_id,
			ARRAY[o.gml_id, t.gml_id, d.gml_id] AS gml_ids,
			coalesce(t.wkb_geometry,st_centroid(o.wkb_geometry)) AS point,
			length(coalesce(split_part(replace(t.schriftinhalt,'-','/'),'/',1),o.zaehler::text)) AS lenz,
			length(coalesce(split_part(replace(t.schriftinhalt,'-','/'),'/',2),o.nenner::text)) AS lenn,
			coalesce(d.signaturnummer,'2001') AS signaturnummer,
			coalesce(t.modelle,o.advstandardmodell||o.sonstigesmodell) AS modell,
			coalesce(t.drehwinkel,0) AS drehwinkel,
			t.horizontaleausrichtung
		FROM po_lastrun, ax_flurstueck o
		LEFT OUTER JOIN po_pto t ON o.gml_id=t.dientzurdarstellungvon
		LEFT OUTER JOIN po_darstellung d ON o.gml_id=d.dientzurdarstellungvon
		WHERE o.endet IS NULL AND greatest(o.beginnt,t.beginnt,d.beginnt)>lastrun AND
			CASE
			WHEN :alkis_fnbruch
			THEN coalesce(t.signaturnummer,'4115') NOT IN ('4113','4122')
			ELSE coalesce(t.signaturnummer,'4113') IN ('4115', '4123')
			END AND
			coalesce(o.nenner,'0')<>'0'
	) AS bruchstrich0 WHERE lenz>0 AND lenn>0
) AS bruchstrich1;