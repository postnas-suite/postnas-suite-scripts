SET client_encoding TO 'UTF8';
SET search_path = :"alkis_schema", :"parent_schema", :"postgis_schema", public;

--
-- Flurstücke (11001)
--

--                    ARZ
-- Schrägstrich: 4113 4122
-- Bruchstrich:  4115 4123

-- Flurstücksnummern
-- Zähler
-- Bruchdarstellung
SELECT 'Erzeuge Flurstückszähler...';
INSERT INTO po_labels(gml_id,gml_ids,thema,layer,point,text,signaturnummer,drehwinkel,horizontaleausrichtung,vertikaleausrichtung,skalierung,fontsperrung,modell)
SELECT
	gml_id,
	gml_ids,
	'Flurstücke' AS thema,
	'ax_flurstueck_nummer' AS layer,
	CASE
	WHEN horizontaleausrichtung='rechtsbündig' THEN st_translate(point, -len, 0.0)
	WHEN horizontaleausrichtung='linksbündig' THEN st_translate(point, len, 0.0)
	ELSE point
	END AS point,
	text,signaturnummer,drehwinkel,'zentrisch' AS horizontaleausrichtung,vertikaleausrichtung,skalierung,fontsperrung,modell
FROM (
	SELECT
		gml_id,
		gml_ids,
		point,
		greatest(lenz, lenn) AS len,
		text,
		signaturnummer,
		drehwinkel,
		horizontaleausrichtung,
		vertikaleausrichtung,
		skalierung,
		fontsperrung,
		modell
	FROM (
		SELECT
			o.gml_id,
			ARRAY[o.gml_id,t.gml_id,d.gml_id] AS gml_ids,
			st_translate(coalesce(t.wkb_geometry,st_centroid(o.wkb_geometry)), 0, 0.40) AS point,
			length(coalesce(split_part(replace(t.schriftinhalt,'-','/'),'/',1),o.zaehler::text)) AS lenz,
			length(coalesce(split_part(replace(t.schriftinhalt,'-','/'),'/',2),o.nenner::text)) AS lenn,
			coalesce(split_part(replace(t.schriftinhalt,'-','/'),'/',1),o.zaehler::text) AS text,
			coalesce(d.signaturnummer,t.signaturnummer,CASE WHEN o.abweichenderrechtszustand='true' THEN '4123' ELSE '4115' END) AS signaturnummer,
			t.drehwinkel, t.horizontaleausrichtung, 'Basis'::text AS vertikaleausrichtung, t.skalierung, t.fontsperrung,
			coalesce(t.modelle,o.advstandardmodell||o.sonstigesmodell) AS modell
		FROM po_lastrun, ax_flurstueck o
		LEFT OUTER JOIN po_pto t ON o.gml_id=t.dientzurdarstellungvon
		LEFT OUTER JOIN po_darstellung d ON o.gml_id=d.dientzurdarstellungvon
		WHERE o.endet IS NULL AND greatest(o.beginnt,t.beginnt,d.beginnt)>lastrun AND
			CASE
			WHEN :alkis_fnbruch
			THEN coalesce(t.signaturnummer,'4115') NOT IN ('4113','4122')
			ELSE coalesce(t.signaturnummer,'4113') IN ('4115', '4123')
			END
			AND coalesce(o.nenner,'0')<>'0'
	) AS foo
) AS foo;