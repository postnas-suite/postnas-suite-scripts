--Vacuum
VACUUM ANALYZE;

--Tabellen der Modifikation löschen
DROP TABLE IF EXISTS pt_aufnahmepunkt;
DROP TABLE IF EXISTS pt_bahnverkehr;
DROP TABLE IF EXISTS pt_bergbaubetrieb;
DROP TABLE IF EXISTS pt_besondererbauwerkspunkt;
DROP TABLE IF EXISTS pt_besonderergebaeudepunkt;
DROP TABLE IF EXISTS pt_fav;
DROP TABLE IF EXISTS pt_flaechebesondererfunktionalerpraegung;
DROP TABLE IF EXISTS pt_flaechegemischternutzung;
DROP TABLE IF EXISTS pt_fliessgewaesser;
DROP TABLE IF EXISTS pt_flugverkehr;
DROP TABLE IF EXISTS pt_flurstueck;
DROP TABLE IF EXISTS pt_friedhof;
DROP TABLE IF EXISTS pt_gebaeudebauwerke;
DROP TABLE IF EXISTS pt_grenzpunkt;
DROP TABLE IF EXISTS pt_hu;
DROP TABLE IF EXISTS pt_industrieundgewerbeflaeche;
DROP TABLE IF EXISTS pt_landwirtschaft;
DROP TABLE IF EXISTS pt_nutzung;
DROP TABLE IF EXISTS pt_platz;
DROP TABLE IF EXISTS pt_schiffsverkehr;
DROP TABLE IF EXISTS pt_schutzzone_schutzgebietnachwasserrecht;
DROP TABLE IF EXISTS pt_sicherungspunkt;
DROP TABLE IF EXISTS pt_sonstigervermessungspunkt;
DROP TABLE IF EXISTS pt_sportfreizeitunderholungsflaeche;
DROP TABLE IF EXISTS pt_stehendesgewaesser;
DROP TABLE IF EXISTS pt_strassenverkehr;
DROP TABLE IF EXISTS pt_tagebaugrubesteinbruch;
DROP TABLE IF EXISTS pt_unlandvegetationsloseflaeche;
DROP TABLE IF EXISTS pt_wald;
DROP TABLE IF EXISTS pt_weg;
DROP TABLE IF EXISTS pt_wohnbauflaeche;
DROP TABLE IF EXISTS po_labels_bb;
DROP TABLE IF EXISTS po_labels_be;
DROP TABLE IF EXISTS po_labels_bfn;
DROP TABLE IF EXISTS po_labels_bgd;
DROP TABLE IF EXISTS po_labels_bgf;
DROP TABLE IF EXISTS po_labels_bgg;
DROP TABLE IF EXISTS po_labels_bgh;
DROP TABLE IF EXISTS po_labels_bgn;
DROP TABLE IF EXISTS po_labels_bgz;
DROP TABLE IF EXISTS po_labels_bh;
DROP TABLE IF EXISTS po_labels_bi;
DROP TABLE IF EXISTS po_labels_bl;
DROP TABLE IF EXISTS po_labels_bll;
DROP TABLE IF EXISTS po_labels_bn;
DROP TABLE IF EXISTS po_labels_br;
DROP TABLE IF EXISTS po_labels_bs;
DROP TABLE IF EXISTS po_labels_bt;
DROP TABLE IF EXISTS po_labels_bv;
DROP TABLE IF EXISTS po_labels_bw;
DROP TABLE IF EXISTS po_labels_bwl;

--Änderungen in den Tabellen rückgängigmachen, bis andere Lösung implementiert wurde
ALTER TABLE po_polygons
	DROP COLUMN gemeinde,
	DROP COLUMN gemarkung,
	DROP COLUMN gemaschl,
	DROP COLUMN flur,
	DROP COLUMN flurstnr,
	DROP COLUMN flaeche,
	DROP COLUMN lagebeztxt,
	DROP COLUMN tntxt,
	DROP COLUMN flstkennz,
	DROP COLUMN nutzart,
	DROP COLUMN bez;

ALTER TABLE ax_gebaeude DROP COLUMN wkb_centroid;
ALTER TABLE ax_turm DROP COLUMN wkb_centroid;
ALTER TABLE ax_turm DROP COLUMN ubauwerksfunktion;
ALTER TABLE ax_bauwerkoderanlagefuerindustrieundgewerbe DROP COLUMN wkb_centroid;
ALTER TABLE ax_vorratsbehaelterspeicherbauwerk DROP COLUMN wkb_centroid;
ALTER TABLE ax_bauwerkoderanlagefuersportfreizeitunderholung DROP COLUMN wkb_centroid;
ALTER TABLE ax_sonstigesbauwerkodersonstigeeinrichtung DROP COLUMN wkb_centroid;
ALTER TABLE ax_bauteil DROP COLUMN wkb_centroid;


--PTO dientzurdarstellungvon unnesten, damit JOIN später einfach läuft
SELECT
	ogc_fid,
	gml_id,
	anlass,
	beginnt,
	endet,
	advstandardmodell,
	sonstigesmodell,
	quellobjektid,
	zeigtaufexternes_art,
	zeigtaufexternes_name,
	zeigtaufexternes_uri,
	art,
	darstellungsprioritaet,
	drehwinkel,
	fontsperrung,
	horizontaleausrichtung,
	schriftinhalt,
	signaturnummer,
	skalierung,
	vertikaleausrichtung,
	hatdirektunten,
	istabgeleitetaus,
	traegtbeizu,
	istteilvon,
	UNNEST(dientzurdarstellungvon) AS dientzurdarstellungvon,
	hat,
	wkb_geometry
INTO pt_pto
FROM ap_pto;

CREATE INDEX pt_pto_dientzurdarstellungvon ON pt_pto USING btree (dientzurdarstellungvon);
CREATE INDEX pt_pto_wkb_geometry_idx ON pt_pto USING gist (wkb_geometry);

--Strassen und Hausnummern zusammenfuehren in Hilfstabelle
SELECT lm.gml_id,
       lm.hausnummer,
       lk.bezeichnung,
       lk.schluesselgesamt
INTO pt_strassemithausnummer
FROM ax_lagebezeichnungmithausnummer lm
LEFT JOIN ax_lagebezeichnungkatalogeintrag lk 
ON concat(lm.land,lm.regierungsbezirk,lm.kreis,lm.gemeinde,lm.lage) = lk.schluesselgesamt;

--verschlüsselte Lagebezeichnungen auflösen in Hilfstabelle
SELECT lo.gml_id,
       lk.bezeichnung,
       lk.schluesselgesamt
INTO pt_lagebez_verschl
FROM ax_lagebezeichnungohnehausnummer lo
LEFT JOIN ax_lagebezeichnungkatalogeintrag lk 
ON concat(lo.land,lo.regierungsbezirk,lo.kreis,lo.gemeinde,lo.lage) = lk.schluesselgesamt
WHERE lo.unverschluesselt IS NULL;

--Lagebezeichnung mit Hausnummer unnesten
SELECT gml_id, unnest(weistauf) AS weistauf_id
INTO pt_weistauf
FROM ax_flurstueck;

--Lagebezeichnung ohne Hausnummer unnesten
SELECT gml_id, unnest(zeigtauf) AS zeigtauf_id
INTO pt_zeigtauf
FROM ax_flurstueck;

--Lagebezeichnungen in einer Tabelle sammeln (Kombination aus axflst_mod.sql und geocode_adrflstk_mod.sql!)
(SELECT wa.gml_id AS gml_id, 
	wa.weistauf_id,
	NULL AS zeigtauf_id,
	sh.bezeichnung AS bezeichnung,
	sh.hausnummer AS hausnummer,
	sh.schluesselgesamt
INTO pt_lagebez_einzel
FROM pt_weistauf wa
INNER JOIN pt_strassemithausnummer sh 
ON wa.weistauf_id = sh.gml_id)
UNION
(SELECT za.gml_id AS gml_id,
        NULL AS weistauf_id,
        za.zeigtauf_id,
        lo.unverschluesselt AS bezeichnung,
        NULL AS hausnummer,
        NULL AS schluesselgesamt
FROM pt_zeigtauf za
INNER JOIN ax_lagebezeichnungohnehausnummer lo
ON za.zeigtauf_id = lo.gml_id
WHERE lo.unverschluesselt IS NOT NULL)
UNION
(SELECT za.gml_id AS gml_id,
        NULL AS weistauf_id,
        za.zeigtauf_id,
        lv.bezeichnung AS bezeichnung,
        NULL AS hausnummer,
        lv.schluesselgesamt
FROM pt_zeigtauf za
INNER JOIN pt_lagebez_verschl lv 
ON za.zeigtauf_id = lv.gml_id);

VACUUM ANALYZE pt_lagebez_einzel; 

--Lagebezeichnungen zu Array aggregieren und als Zeichenkette umformen
SELECT gml_id, array_to_string(array_agg(lagebez ORDER BY lagebez),'; ') AS lagebeztxt
INTO pt_lagebez_gesamt
FROM
    (SELECT gml_id,
     CASE
     WHEN string_agg(hausnummer, '') IS NOT NULL THEN concat(bezeichnung, ' ', array_to_string(array_agg(hausnummer ORDER BY hausnummer),', '))
     ELSE array_to_string(array_agg(bezeichnung ORDER BY bezeichnung),', ')
     END AS lagebez
     FROM pt_lagebez_einzel
     GROUP BY gml_id, bezeichnung) agg
GROUP BY gml_id;
