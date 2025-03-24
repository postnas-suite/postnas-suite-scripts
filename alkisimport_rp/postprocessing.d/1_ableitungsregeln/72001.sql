SET client_encoding TO 'UTF8';
SET search_path = :"alkis_schema", :"parent_schema", :"postgis_schema", public;

--
-- Bodenschaetzung (72001; RP)
--

SELECT 'Bodenschaetzung (RP) wird verarbeitet.';

-- Die Fläche ohne Label
SELECT bs.ogc_fid,
        bs.gml_id,  
        bs.wkb_geometry,
        bs.kulturart,  -- KUL
        bs.bodenart, -- KN1
        bs.zustandsstufeoderbodenstufe, -- KN2
        bs.entstehungsartoderklimastufewasserverhaeltnisse, --KN3
        bs.bodenzahlodergruenlandgrundzahl, -- WE1
        bs.ackerzahlodergruenlandzahl, -- WE2
        bs.sonstigeangaben, --SON
        ka.bezeichner AS kulturart_e,
        ba.bezeichner AS bodenart_e,
        zs.bezeichner AS zustandsstufe_e,
        ea1.bezeichner AS entstehart1,
        ea2.bezeichner AS entstehart2,
        so1.bezeichner AS sonst1,  
        so2.bezeichner AS sonst2,
        bs.jahreszahl
    INTO pt_bodenschaetzung 
    FROM ax_bodenschaetzung bs
    LEFT JOIN v_bschaetz_kulturart      ka ON bs.kulturart = ka.wert
    LEFT JOIN v_bschaetz_bodenart       ba ON bs.bodenart  = ba.wert
    LEFT JOIN v_bschaetz_zustandsstufe  zs ON bs.zustandsstufeoderbodenstufe = zs.wert
    LEFT JOIN v_bschaetz_entsteh_klima ea1 
          ON bs.entstehungsartoderklimastufewasserverhaeltnisse[1] = ea1.wert   -- [1] fast immer gefüllt
    LEFT JOIN v_bschaetz_entsteh_klima ea2 
          ON bs.entstehungsartoderklimastufewasserverhaeltnisse[2] = ea2.wert   -- [2] manchmal gefüllt
    LEFT JOIN v_bschaetz_sonst so1 ON bs.sonstigeangaben[1] = so1.wert -- [1] selten gefüllt
    LEFT JOIN v_bschaetz_sonst so2 ON bs.sonstigeangaben[2] = so2.wert -- [2] fast nie
    WHERE bs.endet IS NULL;


-- Differenzierung der Klassenflächen, Klassenabschnitte und Sonderflächen
--------------------------------------------------------------------------

--Polygone in einzelne Liniensegmente zerlegen
SELECT ST_MakeLine(sp,ep) AS wkb_geometry, 
     ogc_fid,
     gml_id,
     kulturart,  -- KUL
     bodenart, -- KN1
     zustandsstufeoderbodenstufe, -- KN2
     entstehungsartoderklimastufewasserverhaeltnisse, --KN3
     bodenzahlodergruenlandgrundzahl, -- WE1
     ackerzahlodergruenlandzahl, -- WE2
     sonstigeangaben --SON
INTO pt_bodensch_gr
FROM
   -- extract the endpoints for every 2-point line segment for each linestring
   (SELECT
      ST_PointN(geom, generate_series(1, ST_NPoints(geom)-1)) as sp,
      ST_PointN(geom, generate_series(2, ST_NPoints(geom)  )) as ep,
      ogc_fid,
      gml_id,
      kulturart,  -- KUL
      bodenart, -- KN1
      zustandsstufeoderbodenstufe, -- KN2
      entstehungsartoderklimastufewasserverhaeltnisse, --KN3
      bodenzahlodergruenlandgrundzahl, -- WE1
      ackerzahlodergruenlandzahl, -- WE2
      sonstigeangaben --SON
    FROM
       -- extract the individual linestrings
      (SELECT (ST_Dump(ST_Boundary(wkb_geometry))).geom, 
               ogc_fid,
               gml_id,
               kulturart,  -- KUL
               bodenart, -- KN1
               zustandsstufeoderbodenstufe, -- KN2
               entstehungsartoderklimastufewasserverhaeltnisse, --KN3
               bodenzahlodergruenlandgrundzahl, -- WE1
               ackerzahlodergruenlandzahl, -- WE2
               sonstigeangaben --SON
       FROM pt_bodenschaetzung
       ) AS linestrings
    ) AS segments;

ALTER TABLE pt_bodensch_gr ADD COLUMN gid serial NOT NULL;
ALTER TABLE pt_bodensch_gr ADD COLUMN signaturnummer int;
ALTER TABLE pt_bodensch_gr ADD CONSTRAINT pt_bodensch_gr_pk PRIMARY KEY (gid);
CREATE INDEX pt_bodensch_gr_geom ON pt_bodensch_gr USING gist (wkb_geometry) TABLESPACE pgdata;


-- Schnittmenge bilden und persistieren
SELECT sbg1.*, 
       sbg2.gid as sbg2gid,
       sbg2.kulturart as sbg2kulturart,  -- KUL
       sbg2.bodenart as sbg2bodenart, -- KN1
       sbg2.zustandsstufeoderbodenstufe as sbg2zustandsstufeoderbodenstufe, -- KN2
       sbg2.entstehungsartoderklimastufewasserverhaeltnisse as sbg2entstehungsartoderklimastufewasserverhaeltnisse, --KN3
       sbg2.bodenzahlodergruenlandgrundzahl as sbg2bodenzahlodergruenlandgrundzahl, -- WE1
       sbg2.ackerzahlodergruenlandzahl as sbg2ackerzahlodergruenlandzahl, -- WE2
       sbg2.sonstigeangaben as sbg2sonstigeangaben
INTO pt_bodensch_schnitt
FROM pt_bodensch_gr sbg1
INNER JOIN pt_bodensch_gr sbg2 ON (ST_Equals(sbg1.wkb_geometry, sbg2.wkb_geometry))
WHERE sbg1.gid > sbg2.gid
;

-- Alle Geometrien, die öfter als 2x vorkommen auf 0 setzen
UPDATE pt_bodensch_gr 
SET signaturnummer = 0
WHERE gid IN (
	SELECT sbg2gid
	FROM (SELECT s1.gid, s1.sbg2gid, row_number() OVER (PARTITION BY s1.gid) AS rownum
		FROM pt_bodensch_schnitt s1
		WHERE s1.gid > s1.sbg2gid
		GROUP BY s1.gid, s1.sbg2gid) AS s2
	WHERE s2.rownum > 1
	ORDER BY s2.gid, rownum DESC
);

-- Zweite Hälfte der Schnittmenge auf 0 setzen
UPDATE pt_bodensch_gr 
SET signaturnummer = 0
WHERE gid IN (
	SELECT sbg.gid
     FROM pt_bodensch_gr sbg 
     INNER JOIN
     pt_bodensch_schnitt sbs 
     ON (ST_Equals(sbg.wkb_geometry, sbs.wkb_geometry)
          AND sbg.gid <> sbs.gid
        )
);


-- Bestimmen der inneren Klassenflächengrenze (durchgezogen)
UPDATE pt_bodensch_gr sbg
SET signaturnummer = 2703
FROM (SELECT sbg1.gid
	FROM pt_bodensch_schnitt sbg1
	WHERE ( sbg1.kulturart <> sbg2kulturart 
		OR ( sbg1.kulturart = sbg2kulturart
			AND ( sbg1.bodenart <> sbg2bodenart
				OR ( sbg1.bodenart = sbg2bodenart 
					AND ( sbg1.zustandsstufeoderbodenstufe <> sbg2zustandsstufeoderbodenstufe 
						OR ( sbg1.zustandsstufeoderbodenstufe = sbg2zustandsstufeoderbodenstufe
							AND sbg1.entstehungsartoderklimastufewasserverhaeltnisse = sbg2entstehungsartoderklimastufewasserverhaeltnisse
							)
						)
					)
				)
			)
		)
) AS a
WHERE sbg.gid = a.gid
AND (sbg.signaturnummer <> 0
	OR sbg.signaturnummer IS NULL)
;

-- Bestimmen der Klassensbschnittsgrenze (gestrichelt)
UPDATE pt_bodensch_gr sbg
SET signaturnummer = 2705
FROM (SELECT sbg1.gid
	FROM pt_bodensch_schnitt sbg1
	WHERE sbg1.kulturart = sbg2kulturart 
	AND sbg1.bodenart = sbg2bodenart 
	AND sbg1.zustandsstufeoderbodenstufe = sbg2zustandsstufeoderbodenstufe 
	AND sbg1.entstehungsartoderklimastufewasserverhaeltnisse = sbg2entstehungsartoderklimastufewasserverhaeltnisse 
	AND sbg1.bodenzahlodergruenlandgrundzahl <> sbg2bodenzahlodergruenlandgrundzahl 
) AS a
WHERE sbg.gid = a.gid
AND signaturnummer <> 0
;

-- Bestimmen der Sonderflächengrenze (strichpunktiert)
UPDATE pt_bodensch_gr sbg
SET signaturnummer = 2707
FROM (SELECT sbg1.gid
	FROM pt_bodensch_schnitt sbg1
	WHERE sbg1.kulturart = sbg2kulturart 
	AND sbg1.bodenart = sbg2bodenart 
	AND sbg1.zustandsstufeoderbodenstufe = sbg2zustandsstufeoderbodenstufe 
	AND sbg1.entstehungsartoderklimastufewasserverhaeltnisse = sbg2entstehungsartoderklimastufewasserverhaeltnisse 
	AND sbg1.bodenzahlodergruenlandgrundzahl = sbg2bodenzahlodergruenlandgrundzahl 
	AND ( sbg1.ackerzahlodergruenlandzahl <> sbg2ackerzahlodergruenlandzahl 
		OR ( sbg1.ackerzahlodergruenlandzahl = sbg2ackerzahlodergruenlandzahl
		     AND sbg1.sonstigeangaben <> sbg2sonstigeangaben 
               ) 
          )
) AS a
WHERE sbg.gid = a.gid
AND signaturnummer <> 0
;

-- Bestimmen der äußeren Klassenflächengrenze (durchgezogen)
UPDATE pt_bodensch_gr sbg
SET signaturnummer = 2703
WHERE signaturnummer IS NULL
; 


INSERT INTO po_lines(gml_id,thema,layer,line,signaturnummer,modell)
SELECT
	p.gml_id,
	'Bodenschaetzung' AS thema,
	'ax_bodenschaetzung' AS layer,
	p.wkb_geometry AS line,
	p.signaturnummer,
	'{DLKM}' AS modell
FROM pt_bodensch_gr p
WHERE p.signaturnummer <> 0;


INSERT INTO po_labels(gml_id,thema,layer,point,text,signaturnummer,drehwinkel,horizontaleausrichtung,vertikaleausrichtung,skalierung,fontsperrung,modell)
SELECT
	bs.gml_id,
	'Bodenschaetzung' AS thema,
	'ax_bodenschaetzung' AS layer,
	t.wkb_geometry AS point,
	    CASE
            WHEN bs.kulturart = 1000 THEN   -- Ackerland (A)
                 ba.kurz  ||              -- Bodenart
                 zs.kurz  ||              -- Zustandsstufe
                 coalesce (ea1.kurz, '') ||              -- Entstehungsart oder Klimastufe, Wasserverhaeltnisse
                 coalesce (ea2.kurz, '')  -- Noch mal, ist ein Array mit 1 bis 2 Elementen
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
            WHEN bs.kulturart = 2000 THEN   -- Acker-Grünland (AGr)
                 '(' ||
                 ba.kurz  ||              -- Bodenart
                 zs.kurz  ||              -- Zustandsstufe
                 coalesce (ea1.kurz, '') ||              -- Entstehungsart oder Klimastufe, Wasserverhaeltnisse
                 coalesce (ea2.kurz, '')  -- Noch mal, ist ein Array mit 1 bis 2 Elementen
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
            WHEN bs.kulturart = 3000 THEN   -- Grünland (Gr)
                 ba.kurz  ||              -- Bodenart
                 zs.kurz  ||              -- Zustandsstufe
                 CASE 
                 	 WHEN bs.entstehungsartoderklimastufewasserverhaeltnisse[1] < 7000 THEN
                 		  coalesce (ea1.kurz, '')      -- Entstehungsart oder Klimastufe, Wasserverhaeltnisse
                 	 ELSE coalesce (ea2.kurz, '')      -- Noch mal, ist ein Array mit 1 bis 2 Elementen
                 END ||
                 CASE 
                 	 WHEN bs.entstehungsartoderklimastufewasserverhaeltnisse[2] > 7000 THEN
                 	  	  coalesce (ea2.kurz, '')      -- Entstehungsart oder Klimastufe, Wasserverhaeltnisse
                 	 ELSE coalesce (ea1.kurz, '')      -- Noch mal, ist ein Array mit 1 bis 2 Elementen
                 END
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
            WHEN bs.kulturart = 4000 THEN   -- Grünland-Acker (GrA)
            	 '(' ||
                 ba.kurz  ||              -- Bodenart
                 zs.kurz  ||              -- Zustandsstufe
                 CASE 
                 	 WHEN bs.entstehungsartoderklimastufewasserverhaeltnisse[1] < 7000 THEN
                 		  coalesce (ea1.kurz, '')      -- Entstehungsart oder Klimastufe, Wasserverhaeltnisse
                 	 ELSE coalesce (ea2.kurz, '')      -- Noch mal, ist ein Array mit 1 bis 2 Elementen
                 END ||
                 CASE 
                 	 WHEN bs.entstehungsartoderklimastufewasserverhaeltnisse[2] > 7000 THEN
                 	  	  coalesce (ea2.kurz, '')      -- Entstehungsart oder Klimastufe, Wasserverhaeltnisse
                 	 ELSE coalesce (ea1.kurz, '')      -- Noch mal, ist ein Array mit 1 bis 2 Elementen
                 END
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
    AS text,
	    CASE
            WHEN bs.kulturart IN (1000,2000) THEN 
                4148
            WHEN bs.kulturart IN (3000,4000) THEN 
                4147
        END
    AS signaturnummer,
	drehwinkel,horizontaleausrichtung,vertikaleausrichtung,skalierung,fontsperrung,
	coalesce(t.advstandardmodell||t.sonstigesmodell,bs.advstandardmodell||bs.sonstigesmodell) AS modell
FROM ax_bodenschaetzung bs
JOIN ap_pto t ON ARRAY[bs.gml_id] <@ t.dientzurdarstellungvon AND t.endet IS NULL
LEFT JOIN v_bschaetz_kulturart      ka ON bs.kulturart = ka.wert
LEFT JOIN v_bschaetz_bodenart       ba ON bs.bodenart  = ba.wert
LEFT JOIN v_bschaetz_zustandsstufe  zs ON bs.zustandsstufeoderbodenstufe = zs.wert
LEFT JOIN v_bschaetz_entsteh_klima ea1 
        ON bs.entstehungsartoderklimastufewasserverhaeltnisse[1] = ea1.wert 
LEFT JOIN v_bschaetz_entsteh_klima ea2 
        ON bs.entstehungsartoderklimastufewasserverhaeltnisse[2] = ea2.wert 
LEFT JOIN v_bschaetz_sonst so1 
        ON bs.sonstigeangaben[1] = so1.wert 
LEFT JOIN v_bschaetz_sonst so2 
        ON bs.sonstigeangaben[2] = so2.wert 
WHERE bs.gml_id LIKE 'DERP%' AND bs.endet IS NULL;
