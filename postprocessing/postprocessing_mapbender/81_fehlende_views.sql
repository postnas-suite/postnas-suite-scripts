SET client_encoding TO 'UTF8';
SET search_path = :"alkis_schema", :"parent_schema", :"postgis_schema", public;


SELECT 'Fehlende Views';

DROP VIEW IF EXISTS ap_pto_stra;
DROP VIEW IF EXISTS ap_lto_stra;


CREATE OR REPLACE VIEW ap_pto_stra 
AS 
  SELECT p.ogc_fid,
         l.gml_id,                               -- wird im PP zum Nachladen aus Katalog gebraucht
      -- p.advstandardmodell       AS modell,    -- TEST
      -- l.unverschluesselt, l.lage AS schluessel, -- zur Lage  TEST
         p.schriftinhalt,                        -- WMS: LABELITEM
         p.art,                                  -- WMS: CLASSITEM
         p.horizontaleausrichtung  AS hor,       -- Verfeinern der Text-Position ..
         p.vertikaleausrichtung    AS ver,       --  .. durch Klassifizierung hor/ver
         p.drehwinkel * 57.296     AS winkel,    -- * 180 / Pi
         p.wkb_geometry
    FROM ap_pto p
    JOIN ax_lagebezeichnungohnehausnummer l
      ON l.gml_id = ANY (p.dientzurdarstellungvon)
   WHERE  p.endet IS NULL
     AND  p.art IN ('Strasse','Weg','Platz','BezKlassifizierungStrasse') -- CLASSES im LAYER
     AND (   'DKKM1000' = ANY (p.advstandardmodell) -- "Lika 1000" bevorzugen
       -- OR 'DLKM'     = ANY (p.advstandardmodell) -- oder auch Kataster allgemein 
           -- Ersatzweise auch "keine Angabe", aber nur wenn es keinen besseren Text zur Lage gibt
          OR (p.advstandardmodell IS NULL
               -- Alternativen zur Legebezeichnung suchen in P- und L-Version
               AND (SELECT s.ogc_fid FROM ap_lto s -- irgend ein Feld eines anderen Textes (suchen)
                      JOIN ax_lagebezeichnungohnehausnummer ls ON ls.gml_id = ANY(s.dientzurdarstellungvon)
                     WHERE ls.gml_id = l.gml_id AND NOT s.advstandardmodell IS NULL 
                     LIMIT 1  -- einer reicht als Beweis
                   ) IS NULL  -- "Subquery IS NULL" liefert true wenn kein weiterer Text gefunden wird
               AND (SELECT s.ogc_fid FROM ap_pto s
                      JOIN ax_lagebezeichnungohnehausnummer ls ON ls.gml_id = ANY(s.dientzurdarstellungvon)
                     WHERE ls.gml_id = l.gml_id AND NOT s.advstandardmodell IS NULL LIMIT 1 
                   ) IS NULL 
              ) 
         )
;

COMMENT ON VIEW ap_pto_stra 
  IS 'Sicht für Kartendarstellung: Beschriftung aus "ap_pto" für Lagebezeichnung mit Art "Straße", "Weg", "Platz" oder Klassifizierung.
 Vorzugsweise mit advstandardmodell="DKKM1000", ersatzweise ohne Angabe. Dient im Script pp_laden.sql zum ersten Füllen der Tabelle "pp_strassenname_p".';

-- Daten aus dem View "ap_pto_stra" werden im PostProcessing gespeichert in den Tabellen "pp_strassenname" und "pp_strassenklas".
-- Der View übernimmt die Auswahl des passenden advstandardmodell und rechnet den Winkel passend um,
-- In der Tabelle werden dann die leer gebliebenen Label aus dem Katalog noch ergänzt.

--------------------------------
CREATE OR REPLACE VIEW ap_lto_stra 
AS 
  SELECT p.ogc_fid,
         l.gml_id,                               -- wird im PP zum Nachladen aus Katalog gebraucht
         p.schriftinhalt,                        -- WMS: LABELITEM
         p.art,                                  -- WMS: CLASSITEM
         p.horizontaleausrichtung  AS hor,       -- Verfeinern der Text-Position ..
         p.vertikaleausrichtung    AS ver,       --  .. durch Klassifizierung hor/ver
         p.wkb_geometry
    FROM ap_lto p
    JOIN ax_lagebezeichnungohnehausnummer l
      ON l.gml_id = ANY (p.dientzurdarstellungvon)
   WHERE  p.endet IS NULL
     AND  p.art   IN ('Strasse','Weg','Platz','BezKlassifizierungStrasse') -- Diese Werte als CLASSES in LAYER behandeln. 
     AND (    'DKKM1000' = ANY (p.advstandardmodell) -- "Lika 1000" bevorzugen
       --  OR 'DLKM'     = ANY (p.advstandardmodell) -- oder auch Kataster allgemein?
           -- Ersatzweise auch "keine Angabe", aber nur wenn es keinen besseren Text zur Lage gibt
           OR (p.advstandardmodell IS NULL
               -- Alternativen zur Lagebezeichnung suchen in P- und L-Version
               AND (SELECT s.ogc_fid FROM ap_lto s -- irgend ein Feld eines anderen Textes (suchen)
                      JOIN ax_lagebezeichnungohnehausnummer ls ON ls.gml_id = ANY(s.dientzurdarstellungvon)
                     WHERE ls.gml_id = l.gml_id AND NOT s.advstandardmodell IS NULL 
                     LIMIT 1  -- einer reicht als Beweis
                   ) IS NULL  -- "Subquery IS NULL" liefert true wenn kein weiterer Text gefunden wird
               AND (SELECT s.ogc_fid FROM ap_pto s
                      JOIN ax_lagebezeichnungohnehausnummer ls ON ls.gml_id = ANY(s.dientzurdarstellungvon)
                     WHERE ls.gml_id = l.gml_id AND NOT s.advstandardmodell IS NULL LIMIT 1 
                   ) IS NULL 
              ) 
         )
;

COMMENT ON VIEW ap_lto_stra 
  IS 'Sicht für Kartendarstellung: Beschriftung aus "ap_lto" für Lagebezeichnung mit Art "Straße", "Weg", "Platz" oder Klassifizierung.
 Vorzugsweise mit advstandardmodell="DKKM1000", ersatzweise ohne Angabe. Dient im Script pp_laden.sql zum ersten Füllen der Tabelle "pp_strassenname_l".';

-- 2014-08-26: Daten aus dem View "ap_lto_stra" werden im PostProcessing gespeichert in den Tabellen "pp_strassenname_l".
-- Der View übernimmt die Auswahl des passenden advstandardmodell.
-- In der Tabelle werden dann die leer gebliebenen Label aus dem Katalog noch ergänzt.

---###################################################################---------------------------------------------------

SELECT 'Views csv-Export';

-- V i e w s
-- ============================

-- Generelle Export-Struktur "Flurstück - Buchung - Grundbuch - Person"
-- --------------------------------------------------------------------
-- Wird benötigt im Auskunft-Modul "alkisexport.php":
-- Je nach aufrufendem Modul wird der Filter (WHERE) an anderer Stelle gesetzt (gml_id von FS, GB oder Pers.)
-- Für Filter nach "Straße" siehe die nachfolgende Sonderversion "exp_csv_str".

-- Problem / Konflikt:
-- Es kann nur eine lineare Struktur aus Spalten und Zeilen exportiert werden. 
-- Wenn nicht nur die Daten des Ausgangs-Objektes exportiert werden, sondern auch verbundene Tabellen in 
-- einer 1:N-Struktur, dann verdoppeln sich Zeileninhalte und es werden redundante Daten erzeugt. 
-- Diese Redundanzen müssen vom dem Programm gefiltert werden, das die Daten über eine Schnittstelle einliest.
-- Anwendungs-Beispiel: Abrechnung von Anliegerbeiträgen.

DROP VIEW IF EXISTS exp_csv;
CREATE OR REPLACE VIEW exp_csv
AS
 SELECT -- Fall: einfache Buchung (ohne "Recht an")
  -- F l u r s t ü c k
    f.gml_id                             AS fsgml,       -- möglicher Filter Flurstücks-GML-ID
    f.flurstueckskennzeichen             AS fs_kennz,
    f.gemarkungsnummer,                                  -- Teile des FS-Kennz. noch mal einzeln
    f.flurnummer, f.zaehler, f.nenner, 
    f.amtlicheflaeche                    AS fs_flae,
    g.bezeichnung                        AS gemarkung,
  -- G r u n d b u c h
    gb.gml_id                            AS gbgml,       -- möglicher Filter Grundbuch-GML-ID
    gb.bezirk                            AS gb_bezirk,
    gb.buchungsblattnummermitbuchstabenerweiterung AS gb_blatt,
    z.bezeichnung                        AS beznam,      -- GB-Bezirks-Name
  -- B u c h u n g s s t e l l e  (Grundstück)
    s.laufendenummer                     AS bu_lfd,      -- BVNR
    '=' || s.zaehler || '/' || s.nenner  AS bu_ant,      -- als Excel-Formel (nur bei Wohnungsgrundbuch JOIN über 'Recht an')
    s.buchungsart,                                       -- verschlüsselt
    wb.beschreibung                      AS bu_art,      -- Buchungsart entschlüsselt
  -- N a m e n s N u m m e r  (Normalfall mit Person)
    nn.laufendenummernachdin1421         AS nam_lfd, 
    '=' || nn.zaehler|| '/' || nn.nenner AS nam_ant,     -- als Excel-Formel
  -- R e c h t s g e m e i n s c h a f t  (Sonderfall von Namensnummer, ohne Person, ohne Nummer)
    rg.artderrechtsgemeinschaft          AS nam_adr,
    rg.beschreibung                      AS nam_adrv,    -- Art der Rechtsgem. - Value zum Key
    rg.beschriebderrechtsgemeinschaft    AS nam_bes,
  -- P e r s o n
    p.gml_id                             AS psgml,       -- möglicher Filter Personen-GML-ID
    p.anrede,                                            -- Anrede key
    wp.beschreibung                      AS anrv,        -- Anrede Value zum Key
    p.vorname,
    p.namensbestandteil,
    p.nachnameoderfirma,                                 -- Familienname
    p.geburtsdatum,
  -- A d r e s s e  der Person
    a.postleitzahlpostzustellung         AS plz,
    a.ort_post                           AS ort,         -- Anschreifenzeile 1: PLZ+Ort
    a.strasse,  a.hausnummer,                            -- Anschriftenzeile 2: Straße+HsNr
    a.bestimmungsland                    AS land
   FROM ax_flurstueck    f               -- Flurstück
  JOIN ax_gemarkung g                   -- entschlüsseln
    ON f.land=g.land AND f.gemarkungsnummer=g.gemarkungsnummer 
  JOIN ax_buchungsstelle s              -- FS >istGebucht> Buchungstelle
    ON f.istgebucht = s.gml_id
  JOIN ax_buchungsblatt  gb             -- Buchung >istBestandteilVon> Grundbuchblatt
    ON gb.gml_id = s.istbestandteilvon
  JOIN ax_buchungsblattbezirk z 
    ON gb.land=z.land AND gb.bezirk=z.bezirk 
  JOIN ax_namensnummer nn               -- Blatt <istBestandteilVon< NamNum
    ON gb.gml_id = nn.istbestandteilvon
  JOIN ax_person p                      -- NamNum >benennt> Person 
    ON p.gml_id = nn.benennt
  LEFT JOIN ax_anschrift a              -- nur die "letzte" Anschrift zur Person verwenden
    ON a.gml_id = (SELECT gml_id FROM ax_anschrift an WHERE an.gml_id = ANY(p.hat) AND an.endet IS NULL ORDER BY an.beginnt DESC LIMIT 1)
  -- E n t s c h l ü s s e l n:
--LEFT JOIN alkis_wertearten wp ON cast(p.anrede AS character varying) = wp.k AND wp.element = 'ax_person' AND wp.bezeichnung = 'anrede'
  LEFT JOIN ax_anrede_person wp ON p.anrede = wp.wert
--LEFT JOIN alkis_wertearten wb ON cast(s.buchungsart AS character varying) = wb.k AND wb.element = 'ax_buchungsstelle' AND wb.bezeichnung = 'buchungsart'
  LEFT JOIN ax_buchungsart_buchungsstelle wb ON s.buchungsart = wb.wert
  -- 2mal "LEFT JOIN" verdoppelt die Zeile in der Ausgabe. Darum als Subquery in Spalten packen:
  -- Noch mal "GB -> NamNum", aber dieses Mal für "Rechtsgemeinschaft".
  -- Kommt max. 1 mal je GB vor und hat keine Relation auf Person.
  LEFT JOIN
   ( SELECT gr.gml_id, r.artderrechtsgemeinschaft, r.beschriebderrechtsgemeinschaft, wr.beschreibung
       FROM ax_namensnummer r 
       JOIN ax_buchungsblatt gr
         ON r.istbestandteilvon = gr.gml_id -- Blatt <istBestandteilVon< NamNum (Rechtsgemeinschaft) 
    --LEFT JOIN alkis_wertearten wr ON cast(r.artderrechtsgemeinschaft AS character varying)=wr.k AND wr.element='ax_namensnummer' AND wr.bezeichnung='artderrechtsgemeinschaft' 
      LEFT JOIN ax_artderrechtsgemeinschaft_namensnummer wr ON r.artderrechtsgemeinschaft = wr.wert
      WHERE NOT r.artderrechtsgemeinschaft IS NULL ) AS rg -- Rechtsgemeinschaft
   ON rg.gml_id = gb.gml_id  -- zum GB
  WHERE f.endet IS NULL AND s.endet IS NULL and gb.endet IS NULL and nn.endet IS NULL AND p.endet IS NULL
---------
  UNION
---------
 SELECT  -- Fall: "Recht an"
  -- F l u r s t ü c k
    f.gml_id                             AS fsgml,       -- möglicher Filter Flurstücks-GML-ID
    f.flurstueckskennzeichen             AS fs_kennz,
    f.gemarkungsnummer,                                  -- Teile des FS-Kennz. noch mal einzeln
    f.flurnummer, f.zaehler, f.nenner, 
    f.amtlicheflaeche                    AS fs_flae,
    g.bezeichnung                        AS gemarkung,
  -- G r u n d b u c h
    gb.gml_id                            AS gbgml,       -- möglicher Filter Grundbuch-GML-ID
    gb.bezirk                            AS gb_bezirk,
    gb.buchungsblattnummermitbuchstabenerweiterung AS gb_blatt,
    z.bezeichnung                        AS beznam,      -- GB-Bezirks-Name
  -- B u c h u n g s s t e l l e  (Grundstück)
    s.laufendenummer                     AS bu_lfd,      -- BVNR
    '=' || s.zaehler || '/' || s.nenner  AS bu_ant,      -- als Excel-Formel (nur bei Wohnungsgrundbuch JOIN über 'Recht an')
    s.buchungsart,                                       -- verschlüsselt
    wb.beschreibung                      AS bu_art,      -- Buchungsart entschlüsselt
  -- N a m e n s N u m m e r  (Normalfall mit Person)
    nn.laufendenummernachdin1421         AS nam_lfd, 
    '=' || nn.zaehler|| '/' || nn.nenner AS nam_ant,     -- als Excel-Formel
  -- R e c h t s g e m e i n s c h a f t  (Sonderfall von Namensnummer, ohne Person, ohne Nummer)
    rg.artderrechtsgemeinschaft          AS nam_adr,
    rg.beschreibung                      AS nam_adrv,    -- Art der Rechtsgem. - Value zum Key
    rg.beschriebderrechtsgemeinschaft    AS nam_bes,
  -- P e r s o n
    p.gml_id                             AS psgml,       -- möglicher Filter Personen-GML-ID
    p.anrede,                                            -- Anrede key
    wp.beschreibung                      AS anrv,        -- Anrede Value zum Key
    p.vorname,
    p.namensbestandteil,
    p.nachnameoderfirma,                                 -- Familienname
    p.geburtsdatum,
  -- A d r e s s e  der Person
    a.postleitzahlpostzustellung         AS plz,
    a.ort_post                           AS ort,         -- Anschreifenzeile 1: PLZ+Ort
    a.strasse,  a.hausnummer,                            -- Anschriftenzeile 2: Straße+HsNr
    a.bestimmungsland                    AS land
  FROM ax_flurstueck f                  -- Flurstück
  JOIN ax_gemarkung g                   -- entschlüsseln
    ON f.land=g.land AND f.gemarkungsnummer=g.gemarkungsnummer 
  -- FS >istGebucht> Buchungstelle  <an<  Buchungstelle
 -- Variante mit 2 Buchungs-Stellen (Recht An)
  JOIN ax_buchungsstelle dien           -- dienende Buchung
    ON f.istgebucht = dien.gml_id
  JOIN ax_buchungsstelle s              -- herrschende Buchung
    ON dien.gml_id = ANY (s.an)         -- hat Recht an
  JOIN ax_buchungsblatt  gb             -- Buchung >istBestandteilVon> Grundbuchblatt
    ON gb.gml_id = s.istbestandteilvon
  JOIN ax_buchungsblattbezirk z 
    ON gb.land=z.land AND gb.bezirk=z.bezirk 
  JOIN ax_namensnummer nn               -- Blatt <istBestandteilVon< NamNum
    ON gb.gml_id = nn.istbestandteilvon
  JOIN ax_person p                      -- NamNum >benennt> Person 
    ON p.gml_id = nn.benennt
  LEFT JOIN ax_anschrift a               -- nur die "letzte" Anschrift zur Person verwenden
    ON a.gml_id = (SELECT gml_id FROM ax_anschrift an WHERE an.gml_id = ANY(p.hat) AND an.endet IS NULL ORDER BY an.beginnt DESC LIMIT 1)
  -- E n t s c h l ü s s e l n:
  LEFT JOIN ax_anrede_person wp ON p.anrede = wp.wert
  LEFT JOIN ax_buchungsart_buchungsstelle wb ON s.buchungsart = wb.wert
  LEFT JOIN
   ( SELECT gr.gml_id, r.artderrechtsgemeinschaft, r.beschriebderrechtsgemeinschaft, wr.beschreibung
       FROM ax_namensnummer r 
       JOIN ax_buchungsblatt gr
         ON r.istbestandteilvon = gr.gml_id -- Blatt <istBestandteilVon< NamNum (Rechtsgemeinschaft) 
      LEFT JOIN ax_artderrechtsgemeinschaft_namensnummer wr ON r.artderrechtsgemeinschaft = wr.wert
      WHERE NOT r.artderrechtsgemeinschaft IS NULL ) AS rg -- Rechtsgemeinschaft
   ON rg.gml_id = gb.gml_id  -- zum GB
  WHERE f.endet IS NULL AND s.endet IS NULL and gb.endet IS NULL and nn.endet IS NULL AND p.endet IS NULL
    AND dien.endet IS NULL

ORDER BY fs_kennz,   -- f.flurstueckskennzeichen, 
         gb_bezirk,  -- gb.bezirk, 
         gb_blatt,   -- gb.buchungsblattnummermitbuchstabenerweiterung,
         bu_lfd,     -- s.laufendenummer,
         nam_lfd;    -- nn.laufendenummernachdin1421

COMMENT ON VIEW exp_csv 
 IS 'View für einen CSV-Export aus der Buchauskunft mit alkisexport.php. Generelle Struktur. Für eine bestimmte gml_id noch den Filter setzen.';


-- Eine Variante des View "exp_csv":
-- Hier wird zusätzlich die Lagebezeichnung zum Flurstück angebunden in den Varianten MIT/OHNE Hausnummer.
-- Der Filter "WHERE stgml= " auf die "gml_id" von "ax_lagebezeichnungkatalogeintrag" sollte gesetzt werden,
-- um nur die Flurstücke zu bekommen, die an einer Straße liegen.

DROP VIEW IF EXISTS exp_csv_str;

CREATE OR REPLACE VIEW exp_csv_str
AS      -- Version mit 4fach-UNION (2x2 Fälle) statt eingebauter View "flst_an_strasse"
 SELECT -- Fall 1: einfache Buchung (ohne Recht an)  // Lagebezeichnung MIT Hausnummer
    sm.gml_id                            AS stgml,       -- Filter: gml_id der Straße aus "ax_lagebezeichnungkatalogeintrag"
    'm'                                  AS fall,        -- Sätze unterschieden: MIT HsNr
  -- F l u r s t ü c k
    f.gml_id                             AS fsgml,       -- möglicher Filter Flurstücks-GML-ID
    f.flurstueckskennzeichen             AS fs_kennz,
    f.gemarkungsnummer,                                  -- Teile des FS-Kennz. noch mal einzeln
    f.flurnummer, f.zaehler, f.nenner, 
    f.amtlicheflaeche                    AS fs_flae,
    g.bezeichnung                        AS gemarkung,
  -- G r u n d b u c h
  --gb.gml_id                            AS gbgml,       -- möglicher Filter Grundbuch-GML-ID
    gb.bezirk                            AS gb_bezirk,
    gb.buchungsblattnummermitbuchstabenerweiterung AS gb_blatt,
    z.bezeichnung                        AS beznam,      -- GB-Bezirks-Name
  -- B u c h u n g s s t e l l e  (Grundstück)
    s.laufendenummer                     AS bu_lfd,      -- BVNR
    '=' || s.zaehler || '/' || s.nenner  AS bu_ant,      -- als Excel-Formel (nur bei Wohnungsgrundbuch JOIN über 'Recht an')
    s.buchungsart,                                       -- verschlüsselt
    wb.beschreibung                      AS bu_art,      -- Buchungsart entschlüsselt
  -- N a m e n s N u m m e r  (Normalfall mit Person)
    nn.laufendenummernachdin1421         AS nam_lfd, 
    '=' || nn.zaehler|| '/' || nn.nenner AS nam_ant,     -- als Excel-Formel
  -- R e c h t s g e m e i n s c h a f t  (Sonderfall von Namensnummer, ohne Person, ohne Nummer)
    rg.artderrechtsgemeinschaft          AS nam_adr,
    rg.beschreibung                      AS nam_adrv,    -- Art der Rechtsgem. - Value zum Key
    rg.beschriebderrechtsgemeinschaft    AS nam_bes,
  -- P e r s o n
  --p.gml_id                             AS psgml,       -- möglicher Filter Personen-GML-ID
    p.anrede,                                            -- Anrede key
    wp.beschreibung                      AS anrv,        -- Anrede Value zum Key
    p.vorname,
    p.namensbestandteil,
    p.nachnameoderfirma,                                 -- Familienname
    p.geburtsdatum,
  -- A d r e s s e  der Person
    a.postleitzahlpostzustellung         AS plz,
    a.ort_post                           AS ort,         -- Anschriftenzeile 1: PLZ+Ort
    a.strasse,  a.hausnummer,                            -- Anschriftenzeile 2: Straße+HsNr
    a.bestimmungsland                    AS land
  FROM ax_flurstueck    f               -- Flurstück
  -- Flurstück >weistAuf> ax_lagebezeichnungMIThausnummer <JOIN> ax_lagebezeichnungkatalogeintrag
  JOIN ax_lagebezeichnungmithausnummer lm -- Lage MIT
    ON lm.gml_id = ANY (f.weistauf)
  JOIN ax_lagebezeichnungkatalogeintrag sm
   ON lm.land=sm.land AND lm.regierungsbezirk=sm.regierungsbezirk AND lm.kreis=sm.kreis AND lm.gemeinde=sm.gemeinde AND lm.lage=sm.lage 
   JOIN ax_gemarkung g                   -- entschlüsseln
    ON f.land=g.land AND f.gemarkungsnummer=g.gemarkungsnummer 
  JOIN ax_buchungsstelle s              -- FS >istGebucht> Buchungstelle
    ON f.istgebucht = s.gml_id
  JOIN ax_buchungsblatt  gb             -- Buchung >istBestandteilVon> Grundbuchblatt
    ON gb.gml_id = s.istbestandteilvon
  JOIN ax_buchungsblattbezirk z 
    ON gb.land=z.land AND gb.bezirk=z.bezirk 
  JOIN ax_namensnummer nn               -- Blatt <istBestandteilVon< NamNum
    ON gb.gml_id = nn.istbestandteilvon
  JOIN ax_person p                      -- NamNum >benennt> Person 
    ON p.gml_id = nn.benennt
  LEFT JOIN ax_anschrift a              -- nur die "letzte" Anschrift zur Person verwenden
    ON a.gml_id = (SELECT gml_id FROM ax_anschrift an WHERE an.gml_id = ANY(p.hat) AND an.endet IS NULL ORDER BY an.beginnt DESC LIMIT 1)
  -- E n t s c h l ü s s e l n:
  LEFT JOIN ax_anrede_person wp ON p.anrede = wp.wert
  LEFT JOIN ax_buchungsart_buchungsstelle wb ON s.buchungsart = wb.wert
  -- 2mal "LEFT JOIN" verdoppelt die Zeile in der Ausgabe. Darum als Subquery in Spalten packen:
  -- Noch mal "GB -> NamNum", aber dieses Mal für "Rechtsgemeinschaft".
  -- Kommt max. 1 mal je GB vor und hat keine Relation auf Person.
  LEFT JOIN
   ( SELECT gr.gml_id, r.artderrechtsgemeinschaft, r.beschriebderrechtsgemeinschaft, wr.beschreibung
       FROM ax_namensnummer r 
       JOIN ax_buchungsblatt gr
         ON r.istbestandteilvon = gr.gml_id -- Blatt <istBestandteilVon< NamNum (Rechtsgemeinschaft) 
      LEFT JOIN ax_artderrechtsgemeinschaft_namensnummer wr ON r.artderrechtsgemeinschaft = wr.wert
      WHERE NOT r.artderrechtsgemeinschaft IS NULL ) AS rg -- Rechtsgemeinschaft
   ON rg.gml_id = gb.gml_id  -- zum GB
  WHERE f.endet IS NULL AND s.endet IS NULL and gb.endet IS NULL and nn.endet IS NULL AND p.endet IS NULL AND lm.endet IS NULL  
---------
  UNION
---------
 SELECT -- Fall 2: 2 Buchungs-Stellen (Recht An)  //  Lagebezeichnung MIT Hausnummer
    sm.gml_id                            AS stgml,       -- Filter: gml_id der Straße aus "ax_lagebezeichnungkatalogeintrag"
    'm'                                  AS fall,        -- Sätze unterschieden: MIT HsNr
  -- F l u r s t ü c k
    f.gml_id                             AS fsgml,       -- möglicher Filter Flurstücks-GML-ID
    f.flurstueckskennzeichen             AS fs_kennz,
    f.gemarkungsnummer,                                  -- Teile des FS-Kennz. noch mal einzeln
    f.flurnummer, f.zaehler, f.nenner, 
    f.amtlicheflaeche                    AS fs_flae,
    g.bezeichnung                        AS gemarkung,
  -- G r u n d b u c h
  --gb.gml_id                            AS gbgml,       -- möglicher Filter Grundbuch-GML-ID
    gb.bezirk                            AS gb_bezirk,
    gb.buchungsblattnummermitbuchstabenerweiterung AS gb_blatt,
    z.bezeichnung                        AS beznam,      -- GB-Bezirks-Name
  -- B u c h u n g s s t e l l e  (Grundstück)
    s.laufendenummer                     AS bu_lfd,      -- BVNR
    '=' || s.zaehler || '/' || s.nenner  AS bu_ant,      -- als Excel-Formel (nur bei Wohnungsgrundbuch JOIN über 'Recht an')
    s.buchungsart,                                       -- verschlüsselt
    wb.beschreibung                      AS bu_art,      -- Buchungsart entschlüsselt
  -- N a m e n s N u m m e r  (Normalfall mit Person)
    nn.laufendenummernachdin1421         AS nam_lfd, 
    '=' || nn.zaehler|| '/' || nn.nenner AS nam_ant,     -- als Excel-Formel
  -- R e c h t s g e m e i n s c h a f t  (Sonderfall von Namensnummer, ohne Person, ohne Nummer)
    rg.artderrechtsgemeinschaft          AS nam_adr,
    rg.beschreibung                      AS nam_adrv,    -- Art der Rechtsgem. - Value zum Key
    rg.beschriebderrechtsgemeinschaft    AS nam_bes,
  -- P e r s o n
  --p.gml_id                             AS psgml,       -- möglicher Filter Personen-GML-ID
    p.anrede,                                            -- Anrede key
    wp.beschreibung                      AS anrv,        -- Anrede Value zum Key
    p.vorname,
    p.namensbestandteil,
    p.nachnameoderfirma,                                 -- Familienname
    p.geburtsdatum,
   -- A d r e s s e  der Person
    a.postleitzahlpostzustellung         AS plz,
    a.ort_post                           AS ort,         -- Anschriftenzeile 1: PLZ+Ort
    a.strasse,  a.hausnummer,                            -- Anschriftenzeile 2: Straße+HsNr
    a.bestimmungsland                    AS land
  FROM ax_flurstueck f                  -- Flurstück
  -- Flurstück >weistAuf> ax_lagebezeichnungMIThausnummer <JOIN> ax_lagebezeichnungkatalogeintrag
  JOIN ax_lagebezeichnungmithausnummer lm  -- Lage MIT
    ON lm.gml_id = ANY (f.weistauf)
  JOIN ax_lagebezeichnungkatalogeintrag sm
    ON lm.land=sm.land AND lm.regierungsbezirk=sm.regierungsbezirk AND lm.kreis=sm.kreis AND lm.gemeinde=sm.gemeinde AND lm.lage=sm.lage 
  JOIN ax_gemarkung g                   -- entschlüsseln
    ON f.land=g.land AND f.gemarkungsnummer=g.gemarkungsnummer 
  -- FS >istGebucht> Buchungstelle  <an<  Buchungstelle
 -- Variante mit 2 Buchungs-Stellen (Recht An)
  JOIN ax_buchungsstelle dien           -- dienende Buchung
    ON f.istgebucht = dien.gml_id
  JOIN ax_buchungsstelle s              -- herrschende Buchung
    ON dien.gml_id = ANY (s.an)         -- hat Recht an
  JOIN ax_buchungsblatt  gb             -- Buchung >istBestandteilVon> Grundbuchblatt
    ON gb.gml_id = s.istbestandteilvon
  JOIN ax_buchungsblattbezirk z 
    ON gb.land=z.land AND gb.bezirk=z.bezirk 
  JOIN ax_namensnummer nn               -- Blatt <istBestandteilVon< NamNum
    ON gb.gml_id = nn.istbestandteilvon
  JOIN ax_person p                      -- NamNum >benennt> Person 
    ON p.gml_id = nn.benennt
  LEFT JOIN ax_anschrift a              -- nur die "letzte" Anschrift zur Person verwenden
    ON a.gml_id = (SELECT gml_id FROM ax_anschrift an WHERE an.gml_id = ANY(p.hat) AND an.endet IS NULL ORDER BY an.beginnt DESC LIMIT 1)
  -- E n t s c h l ü s s e l n:
  LEFT JOIN ax_anrede_person wp ON p.anrede = wp.wert
  LEFT JOIN ax_buchungsart_buchungsstelle wb ON s.buchungsart = wb.wert
  LEFT JOIN
   ( SELECT gr.gml_id, r.artderrechtsgemeinschaft, r.beschriebderrechtsgemeinschaft, wr.beschreibung
       FROM ax_namensnummer r 
       JOIN ax_buchungsblatt gr
         ON r.istbestandteilvon = gr.gml_id -- Blatt <istBestandteilVon< NamNum (Rechtsgemeinschaft) 
      LEFT JOIN ax_artderrechtsgemeinschaft_namensnummer wr ON r.artderrechtsgemeinschaft = wr.wert
      WHERE NOT r.artderrechtsgemeinschaft IS NULL ) AS rg -- Rechtsgemeinschaft
   ON rg.gml_id = gb.gml_id  -- zum GB
  WHERE f.endet IS NULL AND s.endet IS NULL and gb.endet IS NULL and nn.endet IS NULL AND p.endet IS NULL
    AND dien.endet IS NULL AND lm.endet IS NULL  
---------
  UNION
---------
 SELECT -- Fall 3: einfache Buchung (ohne Recht an)  //  Lagebezeichnung OHNE Hausnummer
    so.gml_id                            AS stgml,       -- Filter: gml_id der Straße aus "ax_lagebezeichnungkatalogeintrag"
    'o'                                  AS fall,        -- Sätze unterschieden: OHNE HsNr
  -- F l u r s t ü c k
    f.gml_id                             AS fsgml,       -- möglicher Filter Flurstücks-GML-ID
    f.flurstueckskennzeichen             AS fs_kennz,
    f.gemarkungsnummer,                                  -- Teile des FS-Kennz. noch mal einzeln
    f.flurnummer, f.zaehler, f.nenner, 
    f.amtlicheflaeche                    AS fs_flae,
    g.bezeichnung                        AS gemarkung,
  -- G r u n d b u c h
  --gb.gml_id                            AS gbgml,       -- möglicher Filter Grundbuch-GML-ID
    gb.bezirk                            AS gb_bezirk,
    gb.buchungsblattnummermitbuchstabenerweiterung AS gb_blatt,
    z.bezeichnung                        AS beznam,      -- GB-Bezirks-Name
  -- B u c h u n g s s t e l l e  (Grundstück)
    s.laufendenummer                     AS bu_lfd,      -- BVNR
    '=' || s.zaehler || '/' || s.nenner  AS bu_ant,      -- als Excel-Formel (nur bei Wohnungsgrundbuch JOIN über 'Recht an')
    s.buchungsart,                                       -- verschlüsselt
    wb.beschreibung                      AS bu_art,      -- Buchungsart entschlüsselt
  -- N a m e n s N u m m e r  (Normalfall mit Person)
    nn.laufendenummernachdin1421         AS nam_lfd, 
    '=' || nn.zaehler|| '/' || nn.nenner AS nam_ant,     -- als Excel-Formel
  -- R e c h t s g e m e i n s c h a f t  (Sonderfall von Namensnummer, ohne Person, ohne Nummer)
    rg.artderrechtsgemeinschaft          AS nam_adr,
    rg.beschreibung                      AS nam_adrv,    -- Art der Rechtsgem. - Value zum Key
    rg.beschriebderrechtsgemeinschaft    AS nam_bes,
  -- P e r s o n
  --p.gml_id                             AS psgml,       -- möglicher Filter Personen-GML-ID
    p.anrede,                                            -- Anrede key
    wp.beschreibung                      AS anrv,        -- Anrede Value zum Key
    p.vorname,
    p.namensbestandteil,
    p.nachnameoderfirma,                                 -- Familienname
    p.geburtsdatum,
  -- A d r e s s e  der Person
    a.postleitzahlpostzustellung         AS plz,
    a.ort_post                           AS ort,         -- Anschriftenzeile 1: PLZ+Ort
    a.strasse,  a.hausnummer,                            -- Anschriftenzeile 2: Straße+HsNr
    a.bestimmungsland                    AS land
  FROM ax_flurstueck    f               -- Flurstück
-- Flurstück >zeigtAuf> ax_lagebezeichnungOHNEhausnummer <JOIN> ax_lagebezeichnungkatalogeintrag
  JOIN ax_lagebezeichnungohnehausnummer lo -- Lage OHNE
    ON lo.gml_id = ANY (f.zeigtauf)
  JOIN ax_lagebezeichnungkatalogeintrag so -- Straße OHNE
    ON lo.land=so.land AND lo.regierungsbezirk=so.regierungsbezirk AND lo.kreis=so.kreis AND lo.gemeinde=so.gemeinde AND lo.lage=so.lage
  JOIN ax_gemarkung g                   -- entschlüsseln
    ON f.land=g.land AND f.gemarkungsnummer=g.gemarkungsnummer 
  JOIN ax_buchungsstelle s              -- FS >istGebucht> Buchungstelle
    ON f.istgebucht = s.gml_id
  JOIN ax_buchungsblatt  gb             -- Buchung >istBestandteilVon> Grundbuchblatt
    ON gb.gml_id = s.istbestandteilvon
  JOIN ax_buchungsblattbezirk z 
    ON gb.land=z.land AND gb.bezirk=z.bezirk 
  JOIN ax_namensnummer nn               -- Blatt <istBestandteilVon< NamNum
    ON gb.gml_id = nn.istbestandteilvon
  JOIN ax_person p                      -- NamNum >benennt> Person 
    ON p.gml_id = nn.benennt
  LEFT JOIN ax_anschrift a              -- nur die "letzte" Anschrift zur Person verwenden
    ON a.gml_id = (SELECT gml_id FROM ax_anschrift an WHERE an.gml_id = ANY(p.hat) AND an.endet IS NULL ORDER BY an.beginnt DESC LIMIT 1)
  -- E n t s c h l ü s s e l n:
  LEFT JOIN ax_anrede_person wp ON p.anrede = wp.wert
  LEFT JOIN ax_buchungsart_buchungsstelle wb ON s.buchungsart = wb.wert
  -- 2mal "LEFT JOIN" verdoppelt die Zeile in der Ausgabe. Darum als Subquery in Spalten packen:
  -- Noch mal "GB -> NamNum", aber dieses Mal für "Rechtsgemeinschaft".
  -- Kommt max. 1 mal je GB vor und hat keine Relation auf Person.
  LEFT JOIN
   ( SELECT gr.gml_id, r.artderrechtsgemeinschaft, r.beschriebderrechtsgemeinschaft, wr.beschreibung
       FROM ax_namensnummer r 
       JOIN ax_buchungsblatt gr
         ON r.istbestandteilvon = gr.gml_id -- Blatt <istBestandteilVon< NamNum (Rechtsgemeinschaft) 
      LEFT JOIN ax_artderrechtsgemeinschaft_namensnummer wr ON r.artderrechtsgemeinschaft = wr.wert
      WHERE NOT r.artderrechtsgemeinschaft IS NULL ) AS rg -- Rechtsgemeinschaft
   ON rg.gml_id = gb.gml_id  -- zum GB
  WHERE f.endet IS NULL AND s.endet IS NULL and gb.endet IS NULL and nn.endet IS NULL AND p.endet IS NULL AND lo.endet IS NULL 
---------
  UNION
---------
 SELECT -- Fall 4: 2 Buchungs-Stellen (Recht An)  //  Lagebezeichnung OHNE Hausnummer
    so.gml_id                            AS stgml,       -- Filter: gml_id der Straße aus "ax_lagebezeichnungkatalogeintrag"
    'o'                                  AS fall,        -- Sätze unterschieden: OHNE HsNr
  -- F l u r s t ü c k
    f.gml_id                             AS fsgml,       -- möglicher Filter Flurstücks-GML-ID
    f.flurstueckskennzeichen             AS fs_kennz,
    f.gemarkungsnummer,                                  -- Teile des FS-Kennz. noch mal einzeln
    f.flurnummer, f.zaehler, f.nenner, 
    f.amtlicheflaeche                    AS fs_flae,
    g.bezeichnung                        AS gemarkung,
  -- G r u n d b u c h
  --gb.gml_id                            AS gbgml,       -- möglicher Filter Grundbuch-GML-ID
    gb.bezirk                            AS gb_bezirk,
    gb.buchungsblattnummermitbuchstabenerweiterung AS gb_blatt,
    z.bezeichnung                        AS beznam,      -- GB-Bezirks-Name
  -- B u c h u n g s s t e l l e  (Grundstück)
    s.laufendenummer                     AS bu_lfd,      -- BVNR
    '=' || s.zaehler || '/' || s.nenner  AS bu_ant,      -- als Excel-Formel (nur bei Wohnungsgrundbuch JOIN über 'Recht an')
    s.buchungsart,                                       -- verschlüsselt
    wb.beschreibung                      AS bu_art,      -- Buchungsart entschlüsselt
  -- N a m e n s N u m m e r  (Normalfall mit Person)
    nn.laufendenummernachdin1421         AS nam_lfd, 
    '=' || nn.zaehler|| '/' || nn.nenner AS nam_ant,     -- als Excel-Formel
  -- R e c h t s g e m e i n s c h a f t  (Sonderfall von Namensnummer, ohne Person, ohne Nummer)
    rg.artderrechtsgemeinschaft          AS nam_adr,
    rg.beschreibung                      AS nam_adrv,    -- Art der Rechtsgem. - Value zum Key
    rg.beschriebderrechtsgemeinschaft    AS nam_bes,
  -- P e r s o n
  --p.gml_id                             AS psgml,       -- möglicher Filter Personen-GML-ID
    p.anrede,                                            -- Anrede key
    wp.beschreibung                      AS anrv,        -- Anrede Value zum Key
    p.vorname,
    p.namensbestandteil,
    p.nachnameoderfirma,                                 -- Familienname
    p.geburtsdatum,
   -- A d r e s s e  der Person
    a.postleitzahlpostzustellung         AS plz,
    a.ort_post                           AS ort,         -- Anschriftenzeile 1: PLZ+Ort
    a.strasse,  a.hausnummer,                            -- Anschriftenzeile 2: Straße+HsNr
    a.bestimmungsland                    AS land
  FROM ax_flurstueck f                  -- Flurstück
-- Flurstück >zeigtAuf> ax_lagebezeichnungOHNEhausnummer <JOIN> ax_lagebezeichnungkatalogeintrag
  JOIN ax_lagebezeichnungohnehausnummer lo -- Lage OHNE
    ON lo.gml_id = ANY (f.zeigtauf)
  JOIN ax_lagebezeichnungkatalogeintrag so -- Straße OHNE
    ON lo.land=so.land AND lo.regierungsbezirk=so.regierungsbezirk AND lo.kreis=so.kreis AND lo.gemeinde=so.gemeinde AND lo.lage=so.lage
  JOIN ax_gemarkung g                   -- entschlüsseln
    ON f.land=g.land AND f.gemarkungsnummer=g.gemarkungsnummer 
  -- FS >istGebucht> Buchungstelle  <an<  Buchungstelle
 -- Variante mit 2 Buchungs-Stellen (Recht An)
  JOIN ax_buchungsstelle dien           -- dienende Buchung
    ON f.istgebucht = dien.gml_id
  JOIN ax_buchungsstelle s              -- herrschende Buchung
    ON dien.gml_id = ANY (s.an)         -- hat Recht an
  JOIN ax_buchungsblatt  gb             -- Buchung >istBestandteilVon> Grundbuchblatt
    ON gb.gml_id = s.istbestandteilvon
  JOIN ax_buchungsblattbezirk z 
    ON gb.land=z.land AND gb.bezirk=z.bezirk 
  JOIN ax_namensnummer nn               -- Blatt <istBestandteilVon< NamNum
    ON gb.gml_id = nn.istbestandteilvon
  JOIN ax_person p                      -- NamNum >benennt> Person 
    ON p.gml_id = nn.benennt
  LEFT JOIN ax_anschrift a              -- nur die "letzte" Anschrift zur Person verwenden
    ON a.gml_id = (SELECT gml_id FROM ax_anschrift an WHERE an.gml_id = ANY(p.hat) AND an.endet IS NULL ORDER BY an.beginnt DESC LIMIT 1)
  -- E n t s c h l ü s s e l n:
  LEFT JOIN ax_anrede_person wp ON p.anrede = wp.wert
  LEFT JOIN ax_buchungsart_buchungsstelle wb ON s.buchungsart = wb.wert
  LEFT JOIN
   ( SELECT gr.gml_id, r.artderrechtsgemeinschaft, r.beschriebderrechtsgemeinschaft, wr.beschreibung
       FROM ax_namensnummer r 
       JOIN ax_buchungsblatt gr
         ON r.istbestandteilvon = gr.gml_id -- Blatt <istBestandteilVon< NamNum (Rechtsgemeinschaft) 
      LEFT JOIN ax_artderrechtsgemeinschaft_namensnummer wr ON r.artderrechtsgemeinschaft = wr.wert
      WHERE NOT r.artderrechtsgemeinschaft IS NULL ) AS rg -- Rechtsgemeinschaft
   ON rg.gml_id = gb.gml_id  -- zum GB
  WHERE f.endet IS NULL AND s.endet IS NULL and gb.endet IS NULL and nn.endet IS NULL AND p.endet IS NULL
    AND dien.endet IS NULL AND lo.endet IS NULL 

ORDER BY fs_kennz,   -- f.flurstueckskennzeichen, 
         gb_bezirk,  -- gb.bezirk, 
         gb_blatt,   -- gb.buchungsblattnummermitbuchstabenerweiterung,
         bu_lfd,     -- s.laufendenummer,
         nam_lfd;    -- nn.laufendenummernachdin1421

COMMENT ON VIEW exp_csv_str 
 IS 'View für einen CSV-Export aus der Buchauskunft mit alkisexport.php. Liefert nur Flurstücke, die eine Lagebezeichnung MIT/OHNE Hausnummer haben. Dazu noch den Filter auf GML-ID der Straßentabelle setzen.';


-- Ende --
