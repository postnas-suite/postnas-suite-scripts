--Tabellen der Modifikation löschen
DROP TABLE IF EXISTS s_zuordungspfeil_bodensch;
DROP TABLE IF EXISTS s_zuordungspfeilspitze_bodensch;
DROP TABLE IF EXISTS s_bodensch_ent;
DROP TABLE IF EXISTS s_bodensch_po;
DROP TABLE IF EXISTS s_bodensch_tx;
DROP TABLE IF EXISTS s_bodensch_gr;

-- Zuordnungspfeil Bodenschätzung (Signaturnummer 2701)
-- ----------------------------------------------------

-- CREATE MATERIALIZED VIEW s_zuordungspfeil_bodensch
-- AS 
 SELECT l.ogc_fid, 
        l.wkb_geometry
   INTO s_zuordungspfeil_bodensch  
   FROM ap_lpo l
   JOIN ax_bodenschaetzung b
     ON b.gml_id = ANY (l.dientzurdarstellungvon)
  WHERE l.art = 'Pfeil'
    AND ('DKKM1000' = ANY (l.advstandardmodell))
    AND b.endet IS NULL
    AND l.endet IS NULL;

COMMENT ON TABLE s_zuordungspfeil_bodensch 
  IS 'Sicht für Kartendarstellung: Zuordnungspfeil Bodenschätzung, Liniengeometrie.';


-- DROP VIEW IF EXISTS s_zuordungspfeilspitze_bodensch;
 
-- CREATE MATERIALIZED VIEW s_zuordungspfeilspitze_bodensch 
-- AS 
 SELECT l.ogc_fid, 
        (((st_azimuth(st_pointn(l.wkb_geometry, 1), 
        st_pointn(l.wkb_geometry, 2)) * (- (180)::double precision)) / pi()) + (90)::double precision) AS winkel, 
        st_startpoint(l.wkb_geometry) AS wkb_geometry 
   INTO s_zuordungspfeilspitze_bodensch
   FROM ap_lpo l
   JOIN ax_bodenschaetzung b
     ON b.gml_id = ANY (l.dientzurdarstellungvon )
  WHERE l.art = 'Pfeil'
    AND 'DKKM1000' = ANY (l.advstandardmodell)
    AND b.endet IS NULL
    AND l.endet IS NULL;

COMMENT ON TABLE s_zuordungspfeilspitze_bodensch IS 'Sicht für Kartendarstellung: Zuordnungspfeil Bodenschätzung, Spitze, Punktgeometrie mit Drehwinkel.';


-- Gruppe: Bodenschätzung
-- ----------------------

-- Für Nachschlagen bei Feature-Info: Entschlüsselung in Langform zu einer Klassenfläche, ohne Geometrie.
-- CREATE MATERIALIZED VIEW s_bodensch_ent
-- AS 
 SELECT bs.ogc_fid,
      --bs.advstandardmodell,   -- NUR TEST
        ka.bezeichner                            AS nutzungsart_e,
        ba.bezeichner                            AS bodenart_e,
        zs.bezeichner                            AS zustandsstufe_e,
        bos.bezeichner                           AS bodenstufe_e,
        bs.bodenzahlodergruenlandgrundzahl       AS grundz,
        bs.ackerzahlodergruenlandzahl            AS agzahl,
        ea1.bezeichner                           AS entstehart1,
        ea2.bezeichner                           AS entstehart2,
        kl.bezeichner                            AS klima,
        ws.bezeichner                            AS wasser,
        -- entstehungsartoderklimastufewasserverhaeltnisse ist array!
        bs.sonstigeangaben,                           -- integer array  - Entschlüsseln?
        so1.bezeichner                           AS sonst1, -- Enstschlüsselung 
     -- so2.bezeichner                           AS sonst2, -- immer leer?
        bs.jahreszahl                                 -- integer
   INTO s_bodensch_ent
   FROM      ax_bodenschaetzung bs
   LEFT JOIN v_bschaetz_kulturart      ka ON bs.nutzungsart = ka.wert
   LEFT JOIN v_bschaetz_bodenart       ba ON bs.bodenart  = ba.wert
   LEFT JOIN v_bschaetz_zustandsstufe  zs ON bs.zustandsstufe = zs.wert
   LEFT JOIN v_bschaetz_bodenstufe     bos ON bs.bodenstufe = bos.wert
   LEFT JOIN v_bschaetz_entsteh ea1 
          ON bs.entstehungsart[1] = ea1.wert   -- [1] fast immer gefüllt
   LEFT JOIN v_bschaetz_entsteh ea2 
          ON bs.entstehungsart[2] = ea2.wert   -- [2] manchmal gefüllt
   LEFT JOIN v_bschaetz_klima kl ON bs.klimastufe = kl.wert
   LEFT JOIN v_bschaetz_wasser ws ON bs.wasserverhaeltnisse = ws.wert  
   LEFT JOIN v_bschaetz_sonst so1 ON bs.sonstigeangaben[1] = so1.wert -- [1] selten gefüllt
 --LEFT JOIN v_bschaetz_sonst so2 ON bs.sonstigeangaben[2] = so2.wert -- [2] fast nie
   WHERE bs.endet IS NULL;

COMMENT ON TABLE s_bodensch_ent IS 'Sicht für Feature-Info: Bodenschätzung, mit Langtexten entschlüsselt';

-- Variante 1: Nur EIN Layer. 
--             Label mittig in der Fläche, dann ist auch kein Zuordnungs-Pfeil notwendig.

-- Klassenfläche (Geometrie) mit ihrem Kurz-Label-Text, der dann mittig an Standardposition angezeigt werden kann. 
-- CREATE MATERIALIZED VIEW s_bodensch_wms
-- AS 
--  SELECT bs.ogc_fid,
--         bs.wkb_geometry,
--      -- bs.advstandardmodell,     -- NUR TEST
--      -- bs.entstehungsartoderklimastufewasserverhaeltnisse AS entstehart, -- Array der Keys, NUR TEST
--         ka.kurz AS kult,  -- Kulturart, CLASSITEM, steuert die Farbe
--      -- Viele Felder zusammen packen zu einem kompakten Zwei-Zeilen-Label:
--           ba.kurz  ||             -- Bodenart
--           zs.kurz  ||             -- Zustandsstufe
--           ea1.kurz ||             -- Entstehungsart oder Klimastufe, Wasserverhaeltnisse ist ein Array mit 1 bis 2 Elementen
--           coalesce (ea2.kurz, '') -- NULL vermeiden!
--           || ' ' ||               -- Zeilenwechsel im Label (UMN: WRAP)
--           bs.bodenzahlodergruenlandgrundzahl::int || '/' ||
--           bs.ackerzahlodergruenlandzahl::int 
--         AS derlabel               -- LABELITEM Umbruch am Blank
--    FROM      ax_bodenschaetzung bs
--    LEFT JOIN v_bschaetz_kulturart      ka ON bs.kulturart = ka.wert
--    LEFT JOIN v_bschaetz_bodenart       ba ON bs.bodenart  = ba.wert
--    LEFT JOIN v_bschaetz_zustandsstufe  zs ON bs.zustandsstufeoderbodenstufe = zs.wert
--    LEFT JOIN v_bschaetz_entsteh_klima ea1 
--           ON bs.entstehungsartoderklimastufewasserverhaeltnisse[1] = ea1.wert   -- [1] fast immer gefüllt
--    LEFT JOIN v_bschaetz_entsteh_klima ea2 
--           ON bs.entstehungsartoderklimastufewasserverhaeltnisse[2] = ea2.wert   -- [2] manchmal gefüllt
--    WHERE bs.endet IS NULL;

-- COMMENT ON MATERIALIZED VIEW s_bodensch_wms IS 'Sicht für Kartendarstellung: Bodenschätzung mit kompakten Informationen für Label.';


-- Variante 2: Fläche und Text als getrennte Layer. Text an manueller Position, 
--             ggf. außerhalb der Fläche. Dann ist ein Zuordnungspfeil notwendig.

-- Die Fläche ohne Label
-- CREATE MATERIALIZED VIEW s_bodensch_po
-- AS
 SELECT ogc_fid,
        wkb_geometry,
        nutzungsart,  -- KUL
        bodenart, -- KN1
        zustandsstufe,
        bodenstufe, -- KN2
        entstehungsart,
        klimastufe,
        wasserverhaeltnisse, --KN3
        bodenzahlodergruenlandgrundzahl, -- WE1
        ackerzahlodergruenlandzahl, -- WE2
        sonstigeangaben --SON
  INTO s_bodensch_po
  FROM ax_bodenschaetzung
  WHERE endet IS NULL;

COMMENT ON TABLE s_bodensch_po IS 'Sicht für Kartendarstellung: Klassenfläche der Bodenschätzung ohne Label.';

-- Der Label zu den Klassenabschnitten
-- ACHTUNG: Zu einigen Abschnitten gibt es mehrerere (identische) Label an verschiedenen Positionen! 
-- CREATE MATERIALIZED VIEW s_bodensch_tx
-- AS 
 SELECT bs.ogc_fid,
        p.wkb_geometry,           -- Geomterie (Punkt) des Labels
     -- bs.wkb_geometry,          -- Geometrie der Fläche, nicht des Label
        bs.advstandardmodell,     -- NUR TEST
     -- bs.entstehungsartoderklimastufewasserverhaeltnisse AS entstehart, -- Array der Keys, NUR TEST
        ka.kurz AS kult,  -- Kulturart, CLASSITEM, steuert die Farbe
     -- p.horizontaleausrichtung,  -- Feinpositionierung  ..    (zentrisch)
	 -- p.vertikaleausrichtung,    --  .. des Labels            (basis)   -> uc
     -- Viele Felder zusammen packen zu einem kompakten Zwei-Zeilen-Label:
        CASE
            WHEN bs.nutzungsart = 1000 THEN   -- Ackerland (A)
                 ba.kurz  ||              -- Bodenart
                 coalesce (zs.kurz, '')  ||              -- Zustandsstufe
                 coalesce (ea1.kurz, '') ||              -- Entstehungsart oder Klimastufe, Wasserverhaeltnisse
                 coalesce (ea2.kurz, '') || -- Noch mal, ist ein Array mit 1 bis 2 Elementen
                 coalesce (kl.kurz, '') ||
                 coalesce (ws.kurz, '')
                 || '|' ||                -- Zeilenwechsel im Label (UMN: WRAP ' ')
                 regexp_replace( coalesce (bs.bodenzahlodergruenlandgrundzahl, '-') , '^0*', '', 'g')  || '/' ||
                 regexp_replace( coalesce (bs.ackerzahlodergruenlandzahl, '-') , '^0*', '', 'g') ||
                 CASE 
                     WHEN bs.sonstigeangaben[1] IS NOT NULL AND bs.sonstigeangaben[1] NOT IN (3000,4000) THEN
                          '|' || so1.kurz
                     WHEN bs.sonstigeangaben[1] IS NOT NULL AND bs.sonstigeangaben[1] IN (3000,4000) THEN
                          '|' || so1.kurz || bs.jahreszahl
                     ELSE ''
                 END ||
                 CASE
                     WHEN bs.sonstigeangaben[2] IS NOT NULL AND bs.sonstigeangaben[2] NOT IN (3000,4000) THEN
                          ' ' || so2.kurz
                     WHEN bs.sonstigeangaben[2] IS NOT NULL AND bs.sonstigeangaben[2] IN (3000,4000) THEN
                          ' ' || so2.kurz || bs.jahreszahl
                     ELSE ''
                 END     
            WHEN bs.nutzungsart = 2000 THEN   -- Acker-Grünland (AGr)
                 '(' ||
                 ba.kurz  ||              -- Bodenart
                 coalesce (zs.kurz, '')  ||              -- Zustandsstufe
                 coalesce (ea1.kurz, '') ||              -- Entstehungsart oder Klimastufe, Wasserverhaeltnisse
                 coalesce (ea2.kurz, '') || -- Noch mal, ist ein Array mit 1 bis 2 Elementen
                 coalesce (kl.kurz, '') ||
                 coalesce (ws.kurz, '')
                 || ')'
                 || '|' ||                -- Zeilenwechsel im Label (UMN: WRAP ' ')
                 regexp_replace( coalesce (bs.bodenzahlodergruenlandgrundzahl, '-') , '^0*', '', 'g')  || '/' ||
                 regexp_replace( coalesce (bs.ackerzahlodergruenlandzahl, '-') , '^0*', '', 'g') ||
                 CASE 
                     WHEN bs.sonstigeangaben[1] IS NOT NULL AND bs.sonstigeangaben[1] NOT IN (3000,4000) THEN
                          '|' || so1.kurz
                     WHEN bs.sonstigeangaben[1] IS NOT NULL AND bs.sonstigeangaben[1] IN (3000,4000) THEN
                          '|' || so1.kurz || bs.jahreszahl
                     ELSE ''
                 END ||
                 CASE
                     WHEN bs.sonstigeangaben[2] IS NOT NULL AND bs.sonstigeangaben[2] NOT IN (3000,4000) THEN
                          ' ' || so2.kurz
                     WHEN bs.sonstigeangaben[2] IS NOT NULL AND bs.sonstigeangaben[2] IN (3000,4000) THEN
                          ' ' || so2.kurz || bs.jahreszahl
                     ELSE ''
                 END     
            WHEN bs.nutzungsart = 3000 THEN   -- Grünland (Gr)
                 ba.kurz  ||              -- Bodenart
                 coalesce (bos.kurz, '') ||     -- Bodenstufe
                 coalesce (ea1.kurz, '') ||     -- Entstehungsart 
			     coalesce (ea2.kurz, '') ||     -- Entstehungsart, ist ein Array mit 1 bis 2 Elementen
				 coalesce (kl.kurz, '') ||		-- Klimastufe 
				 coalesce (ws.kurz, '')			-- Wasserstufe
                 || '|' ||                -- Zeilenwechsel im Label (UMN: WRAP ' ')
                 regexp_replace( coalesce (bs.bodenzahlodergruenlandgrundzahl, '-') , '^0*', '', 'g')  || '/' ||
                 regexp_replace( coalesce (bs.ackerzahlodergruenlandzahl, '-') , '^0*', '', 'g') ||
                 CASE 
                     WHEN bs.sonstigeangaben[1] IS NOT NULL AND bs.sonstigeangaben[1] NOT IN (3000,4000) THEN
                          '|' || so1.kurz
                     WHEN bs.sonstigeangaben[1] IS NOT NULL AND bs.sonstigeangaben[1] IN (3000,4000) THEN
                          '|' || so1.kurz || bs.jahreszahl
                     ELSE ''
                 END ||
                 CASE
                     WHEN bs.sonstigeangaben[2] IS NOT NULL AND bs.sonstigeangaben[2] NOT IN (3000,4000) THEN
                          ' ' || so2.kurz
                     WHEN bs.sonstigeangaben[2] IS NOT NULL AND bs.sonstigeangaben[2] IN (3000,4000) THEN
                          ' ' || so2.kurz || bs.jahreszahl
                     ELSE ''
                 END     
            WHEN bs.nutzungsart = 4000 THEN   -- Grünland-Acker (GrA)
            	 '(' ||
                 ba.kurz  ||              -- Bodenart
                 coalesce (bos.kurz, '') ||     -- Bodenstufe
                 coalesce (ea1.kurz, '') ||     -- Entstehungsart 
			     coalesce (ea2.kurz, '') ||     -- Entstehungsart, ist ein Array mit 1 bis 2 Elementen
				 coalesce (kl.kurz, '') ||		-- Klimastufe 
				 coalesce (ws.kurz, '')			-- Wasserstufe
                 || ')'
                 || '|' ||                -- Zeilenwechsel im Label (UMN: WRAP ' ')
                 regexp_replace( coalesce (bs.bodenzahlodergruenlandgrundzahl, '-') , '^0*', '', 'g')  || '/' ||
                 regexp_replace( coalesce (bs.ackerzahlodergruenlandzahl, '-') , '^0*', '', 'g') ||
                 CASE 
                     WHEN bs.sonstigeangaben[1] IS NOT NULL AND bs.sonstigeangaben[1] NOT IN (3000,4000) THEN
                          '|' || so1.kurz
                     WHEN bs.sonstigeangaben[1] IS NOT NULL AND bs.sonstigeangaben[1] IN (3000,4000) THEN
                          '|' || so1.kurz || bs.jahreszahl
                     ELSE ''
                 END ||
                 CASE
                     WHEN bs.sonstigeangaben[2] IS NOT NULL AND bs.sonstigeangaben[2] NOT IN (3000,4000) THEN
                          ' ' || so2.kurz
                     WHEN bs.sonstigeangaben[2] IS NOT NULL AND bs.sonstigeangaben[2] IN (3000,4000) THEN
                          ' ' || so2.kurz || bs.jahreszahl
                     ELSE ''
                 END    
        END
        AS derlabel                -- LABELITEM, Umbruch am Leerzeichen
   INTO s_bodensch_tx
   FROM ap_pto                                 p
   JOIN ax_bodenschaetzung                     bs ON bs.gml_id = ANY(p.dientzurdarstellungvon)
   LEFT JOIN v_bschaetz_kulturart      ka ON bs.nutzungsart = ka.wert
   LEFT JOIN v_bschaetz_bodenart       ba ON bs.bodenart  = ba.wert
   LEFT JOIN v_bschaetz_zustandsstufe  zs ON bs.zustandsstufe = zs.wert
   LEFT JOIN v_bschaetz_bodenstufe     bos ON bs.bodenstufe = bos.wert
   LEFT JOIN v_bschaetz_entsteh ea1 
          ON bs.entstehungsart[1] = ea1.wert 
   LEFT JOIN v_bschaetz_entsteh ea2 
          ON bs.entstehungsart[2] = ea2.wert 
   LEFT JOIN v_bschaetz_klima kl ON bs.klimastufe = kl.wert
   LEFT JOIN v_bschaetz_wasser ws ON bs.wasserverhaeltnisse = ws.wert
   LEFT JOIN v_bschaetz_sonst so1 
          ON bs.sonstigeangaben[1] = so1.wert 
   LEFT JOIN v_bschaetz_sonst so2 
          ON bs.sonstigeangaben[2] = so2.wert 
  WHERE  p.endet  IS NULL
     AND bs.endet IS NULL ;

COMMENT ON TABLE s_bodensch_tx IS 'Sicht für Kartendarstellung: Kompakter Label zur Klassenfläche der Bodenschätzung an manueller Position. 
Der Label wird zusammengesetzt aus: Bodenart, Zustandsstufe, Entstehungsart oder Klimastufe/Wasserverhältnisse, Bodenzahl oder Grünlandgrundzahl und Ackerzahl oder Grünlandzahl.';

-- Differenzierung der Klassenflächen, Klassenabschnitte und Sonderflächen
--------------------------------------------------------------------------

--Polygone in einzelne Liniensegmente zerlegen
-- CREATE MATERIALIZED VIEW s_bodensch_gr
-- AS 

-- Menge: 14.528.843 - 25.07.2023
SELECT ST_MakeLine(sp,ep) AS wkb_geometry, 
     ogc_fid,
     nutzungsart,  -- KUL
     bodenart, -- KN1
     zustandsstufe,
     bodenstufe, -- KN2
     entstehungsart,
     klimastufe,
     wasserverhaeltnisse, --KN3
     bodenzahlodergruenlandgrundzahl, -- WE1
     ackerzahlodergruenlandzahl, -- WE2
     sonstigeangaben --SON
INTO s_bodensch_gr
FROM
   -- extract the endpoints for every 2-point line segment for each linestring
   (SELECT
      ST_PointN(geom, generate_series(1, ST_NPoints(geom)-1)) as sp,
      ST_PointN(geom, generate_series(2, ST_NPoints(geom)  )) as ep,
      ogc_fid,
      nutzungsart,  -- KUL
      bodenart, -- KN1
      zustandsstufe,
      bodenstufe, -- KN2
      entstehungsart,
      klimastufe,
      wasserverhaeltnisse, --KN3
      bodenzahlodergruenlandgrundzahl, -- WE1
      ackerzahlodergruenlandzahl, -- WE2
      sonstigeangaben --SON
    FROM
       -- extract the individual linestrings
      (SELECT (ST_Dump(ST_Boundary(wkb_geometry))).geom, 
               ogc_fid,
               nutzungsart,  -- KUL
               bodenart, -- KN1
               zustandsstufe,
               bodenstufe, -- KN2
               entstehungsart,
               klimastufe,
               wasserverhaeltnisse, --KN3
               bodenzahlodergruenlandgrundzahl, -- WE1
               ackerzahlodergruenlandzahl, -- WE2
               sonstigeangaben --SON
       FROM s_bodensch_po
       ) AS linestrings
    ) AS segments;

ALTER TABLE s_bodensch_gr ADD COLUMN gid serial NOT NULL;
ALTER TABLE s_bodensch_gr ADD COLUMN signaturnummer int;
--ALTER TABLE s_bodensch_gr ADD CONSTRAINT s_bodensch_gr_pk PRIMARY KEY (gid);
CREATE INDEX s_bodensch_gr_geom ON s_bodensch_gr USING gist (wkb_geometry) TABLESPACE pgdata;


-- Schnittmenge bilden und persistieren (ca. 3,11 Millionen)
-- Menge: 3.114.933 - 25.07.202
SELECT sbg1.*, 
       sbg2.gid as sbg2gid,
       sbg2.nutzungsart as sbg2nutzungsart,  -- KUL
       sbg2.bodenart as sbg2bodenart, -- KN1
       sbg2.zustandsstufe as sbg2zustandsstufe, -- KN2
       sbg2.bodenstufe as sbg2bodenstufe, -- KN2
       sbg2.entstehungsart as sbg2entstehungsart, --KN3
       sbg2.klimastufe as sbg2klimastufe, --KN3
       sbg2.wasserverhaeltnisse as sbg2wasserverhaeltnisse, --KN3
       sbg2.bodenzahlodergruenlandgrundzahl as sbg2bodenzahlodergruenlandgrundzahl, -- WE1
       sbg2.ackerzahlodergruenlandzahl as sbg2ackerzahlodergruenlandzahl, -- WE2
       sbg2.sonstigeangaben as sbg2sonstigeangaben
INTO s_bodensch_schnitt
FROM s_bodensch_gr sbg1
INNER JOIN s_bodensch_gr sbg2 ON (ST_Equals(sbg1.wkb_geometry, sbg2.wkb_geometry))
WHERE sbg1.gid > sbg2.gid
;

-- Alle Geometrien, die öfter als 2x vorkommen auf 0 setzen
-- Menge: 281 - 25.07.2023
UPDATE s_bodensch_gr 
SET signaturnummer = 0
WHERE gid IN (
	SELECT sbg2gid
	FROM (SELECT s1.gid, s1.sbg2gid, row_number() OVER (PARTITION BY s1.gid) AS rownum
		FROM s_bodensch_schnitt s1
		WHERE s1.gid > s1.sbg2gid
		GROUP BY s1.gid, s1.sbg2gid) AS s2
	WHERE s2.rownum > 1
	ORDER BY s2.gid, rownum DESC
);

-- Zweite Hälfte der Schnittmenge auf 0 setzen
UPDATE s_bodensch_gr 
SET signaturnummer = 0
WHERE gid IN (
	SELECT sbg.gid
     FROM s_bodensch_gr sbg 
     INNER JOIN
     s_bodensch_schnitt sbs 
     ON (ST_Equals(sbg.wkb_geometry, sbs.wkb_geometry)
          AND sbg.gid <> sbs.gid
        )
);

UPDATE s_bodensch_gr sbg
SET signaturnummer = 2703
FROM (SELECT sbg1.gid
	FROM s_bodensch_schnitt sbg1
	WHERE  sbg1.nutzungsart <> sbg2nutzungsart
		OR sbg1.bodenart <> sbg2bodenart
		OR coalesce(sbg1.zustandsstufe, 0) <> coalesce(sbg2zustandsstufe, 0) 
        OR coalesce(sbg1.bodenstufe, 0) <> coalesce(sbg2zustandsstufe, 0)
		OR coalesce(sbg1.entstehungsart, '{}') = coalesce(sbg2entstehungsart, '{}')
        OR coalesce(sbg1.klimastufe, 0) = coalesce(sbg2klimastufe, 0)
        OR coalesce(sbg1.wasserverhaeltnisse, 0) = coalesce(sbg2wasserverhaeltnisse, 0)                                 
) AS a
WHERE sbg.gid = a.gid
AND (sbg.signaturnummer <> 0
	OR sbg.signaturnummer IS NULL)
;

-- Bestimmen der Klassensbschnittsgrenze (gestrichelt)
-- Menge: 225.218 - 25.07.2023
UPDATE s_bodensch_gr sbg
SET signaturnummer = 2705
FROM (SELECT sbg1.gid
	FROM s_bodensch_schnitt sbg1
	WHERE sbg1.nutzungsart = sbg2nutzungsart
	AND sbg1.bodenart = sbg2bodenart 
	AND coalesce(sbg1.zustandsstufe, 0) = coalesce(sbg2zustandsstufe, 0)
     AND coalesce(sbg1.bodenstufe, 0) = coalesce(sbg2bodenstufe, 0)
	AND coalesce(sbg1.entstehungsart, '{}') = coalesce(sbg2entstehungsart, '{}') 
     AND coalesce(sbg1.klimastufe, 0) = coalesce(sbg2klimastufe, 0) 
     AND coalesce(sbg1.wasserverhaeltnisse, 0) = coalesce(sbg2wasserverhaeltnisse, 0)
	AND coalesce(sbg1.bodenzahlodergruenlandgrundzahl, '') <> coalesce(sbg2bodenzahlodergruenlandgrundzahl, '')
) AS a
WHERE sbg.gid = a.gid
AND signaturnummer <> 0
;

-- Bestimmen der Sonderflächengrenze (strichpunktiert)
-- Menge: 287.156 - 25.07.2023
UPDATE s_bodensch_gr sbg
SET signaturnummer = 2707
FROM (SELECT sbg1.gid
	FROM s_bodensch_schnitt sbg1
	WHERE sbg1.nutzungsart = sbg2nutzungsart 
	AND sbg1.bodenart = sbg2bodenart  
     AND coalesce(sbg1.zustandsstufe, 0) = coalesce(sbg2zustandsstufe, 0)
     AND coalesce(sbg1.bodenstufe, 0) = coalesce(sbg2bodenstufe, 0)
	AND coalesce(sbg1.entstehungsart, '{}') = coalesce(sbg2entstehungsart, '{}') 
     AND coalesce(sbg1.klimastufe, 0) = coalesce(sbg2klimastufe, 0) 
     AND coalesce(sbg1.wasserverhaeltnisse, 0) = coalesce(sbg2wasserverhaeltnisse, 0)
    AND coalesce(sbg1.bodenzahlodergruenlandgrundzahl, '') = coalesce(sbg2bodenzahlodergruenlandgrundzahl, '')
	AND ( coalesce(sbg1.ackerzahlodergruenlandzahl, '') <> coalesce(sbg2ackerzahlodergruenlandzahl, '')
		OR ( coalesce(sbg1.ackerzahlodergruenlandzahl, '') = coalesce(sbg2ackerzahlodergruenlandzahl, '')
		     AND coalesce(sbg1.sonstigeangaben, '{}') <> coalesce(sbg2sonstigeangaben, '{}')
               ) 
          )
) AS a
WHERE sbg.gid = a.gid
AND signaturnummer <> 0
;

-- Bestimmen der äußeren Klassenflächengrenze (durchgezogen)
UPDATE s_bodensch_gr sbg
SET signaturnummer = 2703
WHERE signaturnummer IS NULL
; 

-- Kontrolle der Verteilung:
-------------------------------
-- Anzahl:     Signaturnummer:
-- 281	     0
-- 225216	     2705
-- 287156	     2707
-- 2410829	2703
-- 11605361	NULL
---------------------------------------------
-- SELECT count(*) as anzahl, signaturnummer 
-- FROM s_bodensch_gr sbg
-- GROUP BY signaturnummer
-- ORDER BY anzahl ASC
-- ;


-- Redundanz suchen:
--  SELECT ogc_fid, count(advstandardmodell) AS anzahl FROM s_bodensch_tx GROUP BY ogc_fid HAVING count(advstandardmodell) > 1;
--  SELECT * FROM s_bodensch_tx WHERE ogc_fid in (2848, 1771, 3131, 3495) ORDER BY ogc_fid;
