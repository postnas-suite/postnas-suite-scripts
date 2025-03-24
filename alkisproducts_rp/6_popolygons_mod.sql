--po_polygons um weitere Felder fuer GetFeatureInfo erweitern
ALTER TABLE po_polygons
	ADD COLUMN gemeinde character varying,
	ADD COLUMN gemarkung character varying,
	ADD COLUMN gemaschl character varying,
	ADD COLUMN flur character varying,
	ADD COLUMN flurstnr character varying,
	ADD COLUMN flaeche float8,
	ADD COLUMN lagebeztxt character varying,
	ADD COLUMN tntxt character varying,
	ADD COLUMN flstkennz character varying,
	ADD COLUMN nutzart character varying,
	ADD COLUMN bez character varying;

--Daten aus pt_flurstueck in po_polygons einfügen
UPDATE po_polygons po
	SET gemeinde=fl.gemeinde, gemarkung=fl.gemarkung, gemaschl=fl.gemaschl, flur=fl.flur, flurstnr=fl.flurstnr, flaeche=fl.flaeche, lagebeztxt=fl.lagebeztxt, tntxt=fl.tntxt, flstkennz=fl.flstkennz
       	FROM pt_flurstueck fl
	WHERE po.gml_id = fl.idflurst
	AND po.thema='Flurstücke' 
	AND po.modell && ARRAY['DLKM','DKKM1000']::varchar[] 
	AND (NOT po.layer IN ('ax_flurstueck_nummer','ax_flurstueck_zuordnung','ax_flurstueck_zuordnung_pfeil')) 
	AND NOT po.polygon IS NULL;

--Daten aus pt_nutzung in po_polygons einfügen
UPDATE po_polygons po
	SET nutzart=tn.nutzart, bez=tn.bez
       	FROM pt_nutzung tn
	WHERE po.gml_id = substring(tn.oid for 16)
	AND po.modell && ARRAY['DLKM','DKKM1000']::varchar[] 
	AND NOT po.polygon IS NULL;