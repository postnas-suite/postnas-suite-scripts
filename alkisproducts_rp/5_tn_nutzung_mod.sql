(SELECT cast(concat(gml_id,'TN') as character varying) AS oid,
	beginnt::date AS aktualit,
	wkb_geometry AS geometrie,
	cast('Bahnverkehr' as character varying) AS nutzart,
	CASE
	WHEN funktion IS NOT NULL THEN concat(funktion_beschreibung,';',bahnkategorie_beschreibung) 
	ELSE bahnkategorie_beschreibung 
	END AS bez,
	zweitname AS name
INTO pt_nutzung
FROM pt_bahnverkehr)
UNION
(SELECT cast(concat(gml_id,'TN') as character varying) AS oid,
        beginnt::date AS aktualit,
        wkb_geometry AS geometrie,
        cast('Bergbaubetrieb' as character varying) AS nutzart,
        abbaugut_beschreibung AS bez,
        name
FROM pt_bergbaubetrieb)
UNION
(SELECT cast(concat(gml_id,'TN') as character varying) AS oid,
        beginnt::date AS aktualit,
        wkb_geometry AS geometrie,
        cast('Fläche besonderer funktionaler Prägung' as character varying) AS nutzart,
        funktion_beschreibung AS bez,
        name
FROM pt_flaechebesondererfunktionalerpraegung)
UNION
(SELECT cast(concat(gml_id,'TN') as character varying) AS oid,
        beginnt::date AS aktualit,
        wkb_geometry AS geometrie,
        cast('Fläche gemischter Nutzung' as character varying) AS nutzart,
        funktion_beschreibung AS bez,
        name
FROM pt_flaechegemischternutzung)
UNION
(SELECT cast(concat(gml_id,'TN') as character varying) AS oid,
        beginnt::date AS aktualit,
        wkb_geometry AS geometrie,
        cast('Fließgewässer' as character varying) AS nutzart,
        funktion_beschreibung AS bez,
        NULL AS name
FROM pt_fliessgewaesser)
UNION
(SELECT cast(concat(gml_id,'TN') as character varying) AS oid,
        beginnt::date AS aktualit,
        wkb_geometry AS geometrie,
        cast('Flugverkehr' as character varying) AS nutzart,
        CASE
        WHEN funktion IS NOT NULL AND art IS NULL THEN funktion_beschreibung
	WHEN funktion IS NULL AND art IS NOT NULL THEN art_beschreibung
	WHEN funktion IS NOT NULL AND art IS NOT NULL THEN concat(funktion_beschreibung,';',art_beschreibung)
        END AS bez,
        array_to_string(zweitname, '; ') AS name
FROM pt_flugverkehr)
UNION
(SELECT cast(concat(gml_id,'TN') as character varying) AS oid,
        beginnt::date AS aktualit,
        wkb_geometry AS geometrie,
        cast('Friedhof' as character varying) AS nutzart,
        funktion_beschreibung AS bez,
        name
FROM pt_friedhof)
UNION
(SELECT cast(concat(gml_id,'TN') as character varying) AS oid,
        beginnt::date AS aktualit,
        wkb_geometry AS geometrie,
        cast('Gehölz' as character varying) AS nutzart,
        NULL AS bez,
        name
FROM ax_gehoelz)
UNION
(SELECT cast(concat(gml_id,'TN') as character varying) AS oid,
        beginnt::date AS aktualit,
        wkb_geometry AS geometrie,
        cast('Hafenbecken' as character varying) AS nutzart,
        NULL AS bez,
        NULL AS name
FROM ax_hafenbecken)
UNION
(SELECT cast(concat(gml_id,'TN') as character varying) AS oid,
        beginnt::date AS aktualit,
        wkb_geometry AS geometrie,
        cast('Halde' as character varying) AS nutzart,
        NULL AS bez,
        name
FROM ax_halde)
UNION
(SELECT cast(concat(gml_id,'TN') as character varying) AS oid,
        beginnt::date AS aktualit,
        wkb_geometry AS geometrie,
        cast('Heide' as character varying) AS nutzart,
        NULL AS bez,
        name
FROM ax_heide)
UNION
(SELECT cast(concat(gml_id,'TN') as character varying) AS oid,
        beginnt::date AS aktualit,
        wkb_geometry AS geometrie,
        cast('Industrie- und Gewerbefläche' as character varying) AS nutzart,
        CASE
        WHEN funktion IS NOT NULL AND foerdergut IS NULL THEN funktion_beschreibung
        WHEN funktion IS NOT NULL AND foerdergut IS NOT NULL THEN concat(funktion_beschreibung,';',foerdergut_beschreibung)
        END AS bez,
        name
FROM pt_industrieundgewerbeflaeche)
UNION
(SELECT cast(concat(gml_id,'TN') as character varying) AS oid,
        beginnt::date AS aktualit,
        wkb_geometry AS geometrie,
        cast('Landwirtschaft' as character varying) AS nutzart,
        vegetationsmerkmal_beschreibung AS bez,
        name
FROM pt_landwirtschaft)
UNION
(SELECT cast(concat(gml_id,'TN') as character varying) AS oid,
        beginnt::date AS aktualit,
        wkb_geometry AS geometrie,
        cast('Moor' as character varying) AS nutzart,
        NULL AS bez,
        name
FROM ax_moor)
UNION
(SELECT cast(concat(gml_id,'TN') as character varying) AS oid,
        beginnt::date AS aktualit,
        wkb_geometry AS geometrie,
        cast('Platz' as character varying) AS nutzart,
        funktion_beschreibung AS bez,
        array_to_string(zweitname, '; ') AS name
FROM pt_platz)
UNION
(SELECT cast(concat(gml_id,'TN') as character varying) AS oid,
        beginnt::date AS aktualit,
        wkb_geometry AS geometrie,
        cast('Schiffsverkehr' as character varying) AS nutzart,
        funktion_beschreibung AS bez,
        NULL AS name
FROM pt_schiffsverkehr)
UNION
(SELECT cast(concat(gml_id,'TN') as character varying) AS oid,
        beginnt::date AS aktualit,
        wkb_geometry AS geometrie,
        cast('Sport-, Freizeit- und Erholungsfläche' as character varying) AS nutzart,
        funktion_beschreibung AS bez,
        name
FROM pt_sportfreizeitunderholungsflaeche)
UNION
(SELECT cast(concat(gml_id,'TN') as character varying) AS oid,
        beginnt::date AS aktualit,
        wkb_geometry AS geometrie,
        cast('Stehendes Gewässer' as character varying) AS nutzart,
        funktion_beschreibung AS bez,
        NULL AS name
FROM pt_stehendesgewaesser)
UNION
(SELECT cast(concat(gml_id,'TN') as character varying) AS oid,
        beginnt::date AS aktualit,
        wkb_geometry AS geometrie,
        cast('Straßenverkehr' as character varying) AS nutzart,
        funktion_beschreibung AS bez,
        zweitname AS name
FROM pt_strassenverkehr)
UNION
(SELECT cast(concat(gml_id,'TN') as character varying) AS oid,
        beginnt::date AS aktualit,
        wkb_geometry AS geometrie,
        cast('Sumpf' as character varying) AS nutzart,
        NULL AS bez,
        name
FROM ax_sumpf)
UNION
(SELECT cast(concat(gml_id,'TN') as character varying) AS oid,
        beginnt::date AS aktualit,
        wkb_geometry AS geometrie,
        cast('Tagebau, Grube, Steinbruch' as character varying) AS nutzart,
        abbaugut_beschreibung AS bez,
        name
FROM pt_tagebaugrubesteinbruch)
UNION
(SELECT cast(concat(gml_id,'TN') as character varying) AS oid,
        beginnt::date AS aktualit,
        wkb_geometry AS geometrie,
        cast('Unland, Vegetationslose Fläche' as character varying) AS nutzart,
        CASE 
        WHEN funktion IS NOT NULL AND oberflaechenmaterial IS NULL THEN funktion_beschreibung
        WHEN funktion IS NOT NULL AND oberflaechenmaterial IS NOT NULL THEN concat(funktion_beschreibung,';',oberflaechenmaterial_beschreibung)
        END AS bez,
        name
FROM pt_unlandvegetationsloseflaeche)
UNION
(SELECT cast(concat(gml_id,'TN') as character varying) AS oid,
        beginnt::date AS aktualit,
        wkb_geometry AS geometrie,
        cast('Wald' as character varying) AS nutzart,
        vegetationsmerkmal_beschreibung AS bez,
        name
FROM pt_wald)
UNION
(SELECT cast(concat(gml_id,'TN') as character varying) AS oid,
        beginnt::date AS aktualit,
        wkb_geometry AS geometrie,
        cast('Weg' as character varying) AS nutzart,
        funktion_beschreibung AS bez,
        NULL AS name
FROM pt_weg)
UNION
(SELECT cast(concat(gml_id,'TN') as character varying) AS oid,
        beginnt::date AS aktualit,
        wkb_geometry AS geometrie,
        cast('Wohnbaufläche' as character varying) AS nutzart,
        artderbebauung_beschreibung AS bez,
        name
FROM pt_wohnbauflaeche);

--gid-Spalte erstellen fuer primary key--
ALTER TABLE pt_nutzung ADD COLUMN ogc_fid serial NOT NULL;

-- Constrains--
ALTER TABLE pt_nutzung ADD CONSTRAINT pt_nutzung_pkey PRIMARY KEY (ogc_fid);
ALTER TABLE pt_nutzung ADD CONSTRAINT enforce_dims_the_geom CHECK (st_ndims(geometrie) = 2);
ALTER TABLE pt_nutzung ADD CONSTRAINT enforce_srid_the_geom CHECK (st_srid(geometrie) = 25832);

--Index--
CREATE INDEX pt_nutzung_geom ON pt_nutzung USING gist (geometrie) TABLESPACE pgdata;
CREATE INDEX pt_nutzung_oid ON pt_nutzung USING btree (oid COLLATE pg_catalog."default") TABLESPACE pgdata;
CREATE INDEX pt_nutzung_nutzart ON pt_nutzung USING btree (nutzart COLLATE pg_catalog."default") TABLESPACE pgdata;

-- INSERT into postgis_21.geometry_column--s
INSERT INTO postgis.geometry_columns(f_table_catalog,f_table_schema, f_table_name, f_geometry_column,coord_dimension, srid, type)
    VALUES ('','public', 'pt_nutzung', 'geometrie', 2, 25832, 'MULTIPOLYGON');
