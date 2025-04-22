SET client_encoding TO 'UTF8';
SET search_path = :"alkis_schema", :"parent_schema", :"postgis_schema", public;

SET client_encoding = 'UTF-8';

SELECT 'Suchen Mapbender';

--Drop view qry_mapbender_ax_flurstueck_suche;
CREATE OR REPLACE VIEW qry_mapbender_ax_flurstueck_suche AS
 SELECT f.gml_id, f.gemarkungsnummer::text AS gemarkungsnummer, f.beginnt, f.endet,
    g.bezeichnung as gemarkungsname, g.land,  f.flurnummer::text AS flurnummer,
    f.zaehler::text AS zaehler, f.nenner::text AS nenner, replace(f.flurstueckskennzeichen::text, '_'::text, ''::text) AS flurstueckskennzeichen,
    f.wkb_geometry AS the_geom_etrs
   FROM ax_flurstueck f
     LEFT JOIN ax_gemarkung g ON f.gemarkungsnummer::text = g.gemarkungsnummer::text
       WHERE f.endet IS NULL AND NOT (f.flurstueckskennzeichen IN ( SELECT ax_historischesflurstueck.flurstueckskennzeichen
           FROM ax_historischesflurstueck));

SELECT 'Suchen Mapbender: qry_mapbender_adresse_suche';
--Drop view qry_mapbender_adresse_suche;
CREATE OR REPLACE VIEW qry_mapbender_adresse_suche AS

  SELECT h.ogc_fid,replace(h.hausnummer::text, ' '::text, ''::text) AS hausnummer,h.gemeinde::text AS gemeinde,c.bezeichnung as gemeindename,
    h.kreis::text AS kreis,  g.wkb_geometry AS the_geom_etrs ,h.gml_id,  h.lage,   k.bezeichnung as strasse, c.regierungsbezirk
    FROM ax_lagebezeichnungmithausnummer h
      JOIN ax_gebaeude g ON ARRAY[h.gml_id] <@ g.zeigtauf AND g.endet IS NULL
      JOIN ax_lagebezeichnungkatalogeintrag k ON h.lage::text =k.lage::text AND h.gemeinde = k.gemeinde  and h.regierungsbezirk =k.regierungsbezirk AND h.kreis = k.kreis
     JOIN ax_gemeinde c ON h.regierungsbezirk = c.regierungsbezirk and h.gemeinde = c.gemeinde AND h.kreis = c.kreis;

SELECT 'Suchen Mapbender: qry_mapbender_eigentuemer_suche_union';
--Drop view qry_mapbender_eigentuemer_suche_union;
CREATE OR REPLACE VIEW qry_mapbender_eigentuemer_suche_union AS
 SELECT foo.flurstueckskennzeichen, foo.flur, foo.fs_zaehler, foo.fs_nenner, foo.flaeche,
    foo.bezirkname, foo.gb_blatt,foo.blattart, foo.bvnr, foo.buchgsartwert, foo.buchgsart,
    foo.name_num, foo.nachname, foo.vorname ,  foo.geom
   FROM (  SELECT      f.flurstueckskennzeichen, f.flurnummer AS flur, f.zaehler AS fs_zaehler,  f.nenner AS fs_nenner, f.amtlicheflaeche AS flaeche,
            b.bezeichnung AS bezirkname,      g.buchungsblattnummermitbuchstabenerweiterung AS gb_blatt, g.blattart,
            s.laufendenummer AS bvnr,        art.wert AS buchgsartwert,  art.bezeichner AS buchgsart,
            n.laufendenummernachdin1421 AS name_num,      p.nachnameoderfirma AS nachname, p.vorname, f.wkb_geometry AS geom
           FROM ax_person p
             JOIN ax_namensnummer n ON p.gml_id = n.benennt AND n.endet IS NULL
	      JOIN ax_buchungsblatt g ON n.istbestandteilvon = g.gml_id  AND g.endet IS NULL
             	JOIN ax_buchungsblattbezirk b ON g.land::text = b.land::text AND g.bezirk::text = b.bezirk::text  AND b.endet IS NULL
             JOIN ax_buchungsstelle s ON s.istbestandteilvon = g.gml_id
		JOIN v_bs_buchungsart art ON s.buchungsart = art.wert AND s.endet IS NULL
	        JOIN ax_flurstueck f ON f.istgebucht = s.gml_id AND f.endet IS NULL
        UNION
         SELECT     f.flurstueckskennzeichen, f.flurnummer AS flur, f.zaehler AS fs_zaehler,  f.nenner AS fs_nenner, f.amtlicheflaeche AS flaeche,
            b.bezeichnung AS bezirkname,      g.buchungsblattnummermitbuchstabenerweiterung AS gb_blatt, g.blattart,
            s.laufendenummer AS bvnr,        art.wert AS buchgsartwert,  art.bezeichner AS buchgsart,
            n.laufendenummernachdin1421 AS name_num,      p.nachnameoderfirma AS nachname, p.vorname, f.wkb_geometry AS geom
           FROM ax_person p
             JOIN ax_namensnummer n ON p.gml_id = n.benennt AND n.endet IS NULL
	      JOIN ax_buchungsblatt g ON n.istbestandteilvon = g.gml_id  AND g.endet IS NULL
             	JOIN ax_buchungsblattbezirk b ON g.land::text = b.land::text AND g.bezirk::text = b.bezirk::text  AND b.endet IS NULL
             JOIN ax_buchungsstelle s ON s.istbestandteilvon = g.gml_id
		JOIN v_bs_buchungsart art ON s.buchungsart = art.wert AND s.endet IS NULL
             JOIN ax_buchungsstelle bs ON (bs.gml_id=ANY(s.an) OR bs.gml_id=ANY(s.zu))
	     JOIN ax_flurstueck f ON f.istgebucht = bs.gml_id AND f.endet IS NULL ) foo;
