SET client_encoding TO 'UTF8';
SET search_path = :"alkis_schema", :"parent_schema", :"postgis_schema", public;


SELECT 'Gemeinde, Gemarkung, Flur';

SET client_encoding = 'UTF-8';


-- ============================================================================
-- Redundanzen aus alkis_beziehungen beseitigen, die nach NAS replace auftreten
-- ============================================================================
-- Workaround: alle Redundazen nach einem Lauf entfernen.
-- Besser wäre: sofort im Trigger bei replace entfernen.
-- Siehe Schema in FUNCTION delete_feature_kill


-- =================================
-- Flurstuecksnummern-Label-Position
-- =================================

--DELETE FROM pp_flurstueck_nr;
  TRUNCATE pp_flurstueck_nr;  -- effektiver als DELETE


  INSERT INTO pp_flurstueck_nr
          ( fsgml, fsnum, the_geom )
    SELECT f.gml_id,
           f.zaehler::text || COALESCE ('/' || f.nenner::text, '') AS fsnum,
           p.wkb_geometry  -- manuelle Position des Textes
      FROM ap_pto             p
      JOIN ax_flurstueck      f  ON  f.gml_id = ANY (p.dientzurdarstellungvon) 
	   AND f.endet IS NULL 
       AND p.endet IS NULL
       AND  flurstueckskennzeichen NOT IN (SELECT flurstueckskennzeichen from ax_historischesflurstueck);

  

-- ==========================================================================================================
-- Tabellen für pp_strassenname_p und pp_strassenname_l (als ersatz für ) pp_strassenname
-- ==========================================================================================================


-- Straßen - N a m e n  und  - K l a s s i f i k a t i o n
-- Tabellen für die Präsentation von Straßen-Namen und -Klassifikationen
-- Daten aus dem View "ap_pto_stra" werden im PostProcessing gespeichert in der Tabelle "pp_strassenname".
-- Der View übernimmt die Auswahl des passenden "advstandardmodell" und rechnet den Winkel passend um.
-- In der Tabelle werden dann die leer gebliebenen Label aus dem Katalog noch ergänzt. 

-- Tabelle aus View befüllen
-- 2014-08-22 
--  Variante "_p" = Punktgeometrie, Spalte gml_id ergänzt.
--  Es werden nun auch Sätze mit leerem "schriftinhalt" angelegt. Das wird dann nachträglich gefüllt.

-- Alles auf Anfang
TRUNCATE pp_strassenname_p;

-- Zunächst die Sonderschreibweisen (Abkürzungen) und die Standardschreibweisen, 
-- die von der Migration redundant abgelegt wurden.
INSERT INTO pp_strassenname_p (gml_id, schriftinhalt, hor, ver, art, winkel, the_geom)
       SELECT gml_id, schriftinhalt, hor, ver, art, winkel, wkb_geometry
       FROM ap_pto_stra ; -- Der View sucht das passende advstandardmodell

-- Schriftinhalt ergänzen
-- Das sind die Standardschreibweisen aus dem Katalog, die nicht mehr redundant in ap_pto sind.
UPDATE pp_strassenname_p  p
   SET schriftinhalt =     -- Hier ist der Label noch leer
   -- Subquery "Gib mir den Straßennamen":
   ( SELECT k.bezeichnung                         -- Straßenname ..
       FROM ax_lagebezeichnungkatalogeintrag k    --  .. aus Katalog
       JOIN ax_lagebezeichnungohnehausnummer l    -- verwendet als Lage o.H.
         ON (k.land=l.land AND k.regierungsbezirk=l.regierungsbezirk AND k.kreis=l.kreis AND k.gemeinde=l.gemeinde AND k.lage=l.lage )
       --WHERE k.endet IS NULL AND l.endet IS NULL 
      WHERE p.gml_id = l.gml_id                   -- die gml_id wurde aus View importiert
    --  AND k.endet IS NULL AND l.endet IS NULL 
    )
 WHERE     p.schriftinhalt IS NULL
   AND NOT p.the_geom      IS NULL;

-- Die immer noch leeren Texte sind nun sinnlos.
-- Die finden sich ggf. in der Variante "_l" mit Liniengeometrie.
DELETE FROM pp_strassenname_p WHERE schriftinhalt IS NULL;

-- Nun das Gleiche noch einmal für Linien-Geometrie

-- Auf Anfang
TRUNCATE pp_strassenname_l;

-- Zunächst die Sonderschreibweisen (Abkürzungen) und die Standardschreibweisen, 
-- die von der Migration redundant abgelegt wurden.
INSERT INTO pp_strassenname_l (gml_id, schriftinhalt, hor, ver, art, the_geom)
       SELECT gml_id, schriftinhalt, hor, ver, art, wkb_geometry
       FROM ap_lto_stra; -- Der View sucht das passende advstandardmodell

-- Schriftinhalt ergänzen (korrigiert 2014-08-25)
-- Das sind die Standardschreibweisen aus dem Katalog, die nicht mehr redundant in ap_pto sind.
-- Der Satz mit der passenen gml_id (Lage o.H.) ist aus dem View bereits importiert.
-- Jetzt noch den dazu passenen Schriftinhalt aus dem Katalog holen.
UPDATE pp_strassenname_l  p
   SET schriftinhalt =     -- Hier ist der Label noch leer
   -- Subquery "Gib mir den Straßennamen":
   ( SELECT k.bezeichnung                         -- Straßenname ..
       FROM ax_lagebezeichnungkatalogeintrag k    --  .. aus Katalog
       JOIN ax_lagebezeichnungohnehausnummer l    -- verwendet als Lage o.H.
         ON (k.land=l.land AND k.regierungsbezirk=l.regierungsbezirk AND k.kreis=l.kreis AND k.gemeinde=l.gemeinde AND k.lage=l.lage )
      WHERE p.gml_id = l.gml_id                   -- die gml_id wurde aus View importiert
    )
 WHERE     p.schriftinhalt IS NULL
   AND NOT p.the_geom      IS NULL;

-- Die immer noch leeren Texte sind sinnlos.
DELETE FROM pp_strassenname_l WHERE schriftinhalt IS NULL;

-- ========================================================
-- Tabellen fuer die Zuordnung vom Gemarkungen zu Gemeinden
-- ========================================================

-- Für die Regelung der Zugriffsberechtigung einer Gemeindeverwaltung auf die 
-- Flurstücke in ihrem Gebiet braucht man die Information, in welcher Gemeinde eine Gemarkung liegt.
-- 'ax_gemeinde' und 'ax_gemarkung' haben aber im ALKIS keinerlei Beziehung zueinander - kaum zu glauben!
-- Nur über die Auswertung der Flurstücke kann man die Zuordnung ermitteln.
-- Da nicht ständig mit 'SELECT DISTINCT' sämtliche Flurstücke durchsucht werden können, 
-- muss diese Information als (redundante) Tabelle nach dem Laden zwischengespeichert werden. 


ALTER TABLE pp_gemeinde DROP CONSTRAINT pp_gemeinde_pk;

ALTER TABLE pp_gemeinde
  ADD CONSTRAINT pp_gemeinde_pk PRIMARY KEY(land, kreis, gemeinde);
  
 ------------------------------------- 
 
 ALTER TABLE pp_flur DROP CONSTRAINT pp_flur_pk;

ALTER TABLE pp_flur
  ADD CONSTRAINT pp_flur_pk PRIMARY KEY(land, kreis, gemarkung, flurnummer);
 
 
 ------------------------------------- 
 
 ALTER TABLE gemeinde_person DROP CONSTRAINT gemeinde_person_pk;

ALTER TABLE gemeinde_person
  ADD CONSTRAINT gemeinde_person_pk PRIMARY KEY(kreis, gemeinde, person);

-----------------------------------------------------------------------


-- G E M A R K U N G

--DELETE FROM pp_gemarkung;
  TRUNCATE pp_gemarkung;

-- Vorkommende Paarungen Gemarkung <-> Gemeinde in ax_Flurstueck
INSERT INTO pp_gemarkung
  (               land, regierungsbezirk, kreis, gemeinde, gemarkung       )
  SELECT DISTINCT gemeindezugehoerigkeit_land, gemeindezugehoerigkeit_regierungsbezirk, gemeindezugehoerigkeit_kreis, gemeindezugehoerigkeit_gemeinde, gemarkungsnummer
  FROM            ax_flurstueck
  WHERE           endet IS NULL AND gemeindezugehoerigkeit_gemeinde IS NOT NULL
  ORDER BY        gemeindezugehoerigkeit_land, gemeindezugehoerigkeit_regierungsbezirk, gemeindezugehoerigkeit_kreis, gemeindezugehoerigkeit_gemeinde, gemarkungsnummer
;

-- Namen der Gemarkung dazu als Optimierung bei der Auskunft 
UPDATE pp_gemarkung a
   SET gemarkungsname =
   ( SELECT b.bezeichnung 
     FROM    ax_gemarkung b
     WHERE a.land=b.land 
       AND a.gemarkung=b.gemarkungsnummer
       AND b.endet IS NULL
   );


-- G E M E I N D E

--DELETE FROM pp_gemeinde;
  TRUNCATE pp_gemeinde;

-- Vorkommende Gemeinden aus den gemarkungen
INSERT INTO pp_gemeinde
  (               land, regierungsbezirk, kreis, gemeinde)
  SELECT DISTINCT land, regierungsbezirk, kreis, gemeinde
  FROM            pp_gemarkung
  ORDER BY        land, regierungsbezirk, kreis, gemeinde
;


-- Namen der Gemeinde dazu als Optimierung bei der Auskunft 
UPDATE pp_gemeinde a
   SET gemeindename =
   ( SELECT b.bezeichnung 
     FROM    ax_gemeinde b
     WHERE a.land=b.land 
       AND a.regierungsbezirk=b.regierungsbezirk 
       AND a.kreis=b.kreis
       AND a.gemeinde=b.gemeinde
       AND b.endet IS NULL
   );


-- ==============================================================================
-- Geometrien der Flurstücke schrittweise zu groesseren Einheiten zusammen fassen
-- ==============================================================================

-- Dies macht nur Sinn, wenn der Inhalt der Datenbank einen ganzen Katasterbezirk enthält.
-- Wenn ein Gebiet durch geometrische Filter im NBA ausgegeben wurde, dann gibt es Randstreifen, 
-- die zu Pseudo-Fluren zusammen gefasst werden. Fachlich falsch!

-- Ausführungszeit: 1 mittlere Stadt mit ca. 14.000 Flurstücken > 100 Sek

DELETE FROM pp_flur;

INSERT INTO pp_flur (land, gemeinde, regierungsbezirk, kreis, gemarkung, flurnummer, anz_fs, the_geom )
   SELECT  f.gemeindezugehoerigkeit_land,f.gemeindezugehoerigkeit_gemeinde, f.gemeindezugehoerigkeit_regierungsbezirk, f.gemeindezugehoerigkeit_kreis, f.gemarkungsnummer as gemarkung, f.flurnummer,
           count(gml_id) as anz_fs,
        --   st_multi(st_union(st_buffer(f.wkb_geometry,0.05))) AS the_geom -- Zugabe um Zwischenräe zu vermeiden
           st_multi(st_union(st_buffer(f.wkb_geometry,5))) AS the_geom -- Zugabe um Zwischenräe zu vermeiden
     FROM  ax_flurstueck f
     WHERE f.endet IS NULL
  GROUP BY f.gemeindezugehoerigkeit_land, f.gemeindezugehoerigkeit_gemeinde,f.gemeindezugehoerigkeit_regierungsbezirk, 
            f.gemeindezugehoerigkeit_kreis, f.gemarkungsnummer, f.flurnummer;

UPDATE pp_flur SET the_geom = st_multi(st_MakePolygon(st_exteriorring(st_geometryn(the_geom,1)))) WHERE st_numgeometries(the_geom) = 1;

--SELECT * FROM pp_flur WHERE st_numgeometries(the_geom) >1

-- Fluren zu Gemarkungen zusammen fassen



-- Fluren zu Gemarkungen zusammen fassen
-- -------------------------------------

-- FEHLER: 290 Absturz PG! Bei Verwendung der ungebufferten präzisen Geometrie.  
-- bufferOriginalPrecision failed (TopologyException: unable to assign hole to a shell), trying with reduced precision
-- UPDATE: ../../source/headers/geos/noding/SegmentString.h:175: void geos::noding::SegmentString::testInvariant() const: Zusicherung »pts->size() > 1« nicht erfüllt.

-- Flächen vereinigen
UPDATE pp_gemarkung a
  SET the_geom = 
   ( SELECT st_multi(st_union(st_buffer(b.the_geom,0.1))) AS the_geom -- Puffer/Zugabe um Löcher zu vermeiden
       FROM pp_flur b
      WHERE a.land      = b.land 
        AND a.gemarkung = b.gemarkung
   );

-- Fluren zaehlen
UPDATE pp_gemarkung a
  SET anz_flur = 
   ( SELECT count(flurnummer) AS anz_flur 
     FROM    pp_flur b
     WHERE a.land      = b.land 
       AND a.gemarkung = b.gemarkung
   ); -- Gemarkungsnummer ist je BundesLand eindeutig


-- Gemarkungen zu Gemeinden zusammen fassen
-- ----------------------------------------

-- Flächen vereinigen (aus der bereits vereinfachten Geometrie)
UPDATE pp_gemeinde a
  SET the_geom = 
   ( SELECT st_multi(st_union(st_buffer(b.the_geom,0.1))) AS the_geom -- noch mal Zugabe
     FROM    pp_gemarkung b
     WHERE a.land     = b.land 
       AND a.gemeinde = b.gemeinde
   );

-- Gemarkungen zählen
UPDATE pp_gemeinde a
  SET anz_gemarkg = 
   ( SELECT count(gemarkung) AS anz_gemarkg 
     FROM    pp_gemarkung b
     WHERE a.land     = b.land 
       AND a.gemeinde = b.gemeinde
   );


-- Geometrie glätten / vereinfachen
-- Diese "simplen" Geometrien sollen nur für die Darstellung einer Übersicht verwendet werden.
-- Ablage der simplen Geometrie in einem alternativen Geometriefeld im gleichen Datensatz.

UPDATE pp_flur      SET simple_geom = st_simplify(the_geom, 0.4); -- Flur 

UPDATE pp_gemarkung SET simple_geom = st_simplify(the_geom, 2.0); -- Gemarkung  (Wirkung siehe pp_gemarkung_analyse)

UPDATE pp_gemeinde  SET simple_geom = st_simplify(the_geom, 5.0); -- Gemeinde (Wirkung siehe pp_gemeinde_analyse)


-- =======================================================
-- Tabelle fuer die Zuordnung vom Eigentümern zu Gemeinden
-- =======================================================


-- erst mal sauber machen
DELETE FROM gemeinde_person;

-- alle direkten Buchungen mit View ermitteln und in Tabelle speichern
-- Für eine Stadt: ca. 20 Sekunden
INSERT INTO  gemeinde_person 
       (land, regierungsbezirk, kreis, gemeinde, person, buchtyp)
 SELECT land, regierungsbezirk, kreis, gemeinde, person, 1
   FROM gemeinde_person_typ1;


-- noch die komplexeren Buchungen ergänzen (Recht an ..)
-- Mit View ermitteln und in Tabelle speichern
-- Für eine Stadt: ca. 10 Sekunden
INSERT INTO  gemeinde_person 
       (  land,   regierungsbezirk,   kreis,   gemeinde,   person,  buchtyp)
 SELECT q.land, q.regierungsbezirk, q.kreis, q.gemeinde, q.person,  2
   FROM gemeinde_person_typ2 q   -- Quelle
   LEFT JOIN gemeinde_person z   -- Ziel
     ON q.person   = z.person    -- Aber nur, wenn dieser Fall im Ziel
    AND q.land     = z.land 
    AND q.regierungsbezirk = z.regierungsbezirk 
    AND q.kreis    = z.kreis 
    AND q.gemeinde = z.gemeinde
  WHERE z.gemeinde is Null;      -- ..  noch nicht vorhanden ist


-- ==========================================================================================================
-- Tabellen für pp_strassenname_p und pp_strassenname_l (als ersatz für ) pp_strassenname
-- ==========================================================================================================


-- Straßen - N a m e n  und  - K l a s s i f i k a t i o n
-- Tabellen für die Präsentation von Straßen-Namen und -Klassifikationen
-- Daten aus dem View "ap_pto_stra" werden im PostProcessing gespeichert in der Tabelle "pp_strassenname".
-- Der View übernimmt die Auswahl des passenden "advstandardmodell" und rechnet den Winkel passend um.
-- In der Tabelle werden dann die leer gebliebenen Label aus dem Katalog noch ergänzt. 

-- Tabelle aus View befüllen
-- 2014-08-22 
--  Variante "_p" = Punktgeometrie, Spalte gml_id ergänzt.
--  Es werden nun auch Sätze mit leerem "schriftinhalt" angelegt. Das wird dann nachträglich gefüllt.

-- Alles auf Anfang
TRUNCATE pp_strassenname_p;

-- Zunächst die Sonderschreibweisen (Abkürzungen) und die Standardschreibweisen, 
-- die von der Migration redundant abgelegt wurden.
INSERT INTO pp_strassenname_p (gml_id, schriftinhalt, hor, ver, art, winkel, the_geom)
       SELECT gml_id, schriftinhalt, hor, ver, art, winkel, wkb_geometry
       FROM ap_pto_stra ; -- Der View sucht das passende advstandardmodell

-- Schriftinhalt ergänzen
-- Das sind die Standardschreibweisen aus dem Katalog, die nicht mehr redundant in ap_pto sind.
UPDATE pp_strassenname_p  p
   SET schriftinhalt =     -- Hier ist der Label noch leer
   -- Subquery "Gib mir den Straßennamen":
   ( SELECT k.bezeichnung                         -- Straßenname ..
       FROM ax_lagebezeichnungkatalogeintrag k    --  .. aus Katalog
       JOIN ax_lagebezeichnungohnehausnummer l    -- verwendet als Lage o.H.
         ON (k.land=l.land AND k.regierungsbezirk=l.regierungsbezirk AND k.kreis=l.kreis AND k.gemeinde=l.gemeinde AND k.lage=l.lage )
       --WHERE k.endet IS NULL AND l.endet IS NULL 
      WHERE p.gml_id = l.gml_id                   -- die gml_id wurde aus View importiert
    --  AND k.endet IS NULL AND l.endet IS NULL 
    )
 WHERE     p.schriftinhalt IS NULL
   AND NOT p.the_geom      IS NULL;

-- Die immer noch leeren Texte sind nun sinnlos.
-- Die finden sich ggf. in der Variante "_l" mit Liniengeometrie.
DELETE FROM pp_strassenname_p WHERE schriftinhalt IS NULL;

-- Nun das Gleiche noch einmal für Linien-Geometrie

-- Auf Anfang
TRUNCATE pp_strassenname_l;

-- Zunächst die Sonderschreibweisen (Abkürzungen) und die Standardschreibweisen, 
-- die von der Migration redundant abgelegt wurden.
INSERT INTO pp_strassenname_l (gml_id, schriftinhalt, hor, ver, art, the_geom)
       SELECT gml_id, schriftinhalt, hor, ver, art, wkb_geometry
       FROM ap_lto_stra; -- Der View sucht das passende advstandardmodell

-- Schriftinhalt ergänzen (korrigiert 2014-08-25)
-- Das sind die Standardschreibweisen aus dem Katalog, die nicht mehr redundant in ap_pto sind.
-- Der Satz mit der passenen gml_id (Lage o.H.) ist aus dem View bereits importiert.
-- Jetzt noch den dazu passenen Schriftinhalt aus dem Katalog holen.
UPDATE pp_strassenname_l  p
   SET schriftinhalt =     -- Hier ist der Label noch leer
   -- Subquery "Gib mir den Straßennamen":
   ( SELECT k.bezeichnung                         -- Straßenname ..
       FROM ax_lagebezeichnungkatalogeintrag k    --  .. aus Katalog
       JOIN ax_lagebezeichnungohnehausnummer l    -- verwendet als Lage o.H.
         ON (k.land=l.land AND k.regierungsbezirk=l.regierungsbezirk AND k.kreis=l.kreis AND k.gemeinde=l.gemeinde AND k.lage=l.lage )
      WHERE p.gml_id = l.gml_id                   -- die gml_id wurde aus View importiert
    )
 WHERE     p.schriftinhalt IS NULL
   AND NOT p.the_geom      IS NULL;

-- Die immer noch leeren Texte sind sinnlos.
DELETE FROM pp_strassenname_l WHERE schriftinhalt IS NULL;

-- ENDE --
