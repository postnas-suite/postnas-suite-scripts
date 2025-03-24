DROP TABLE IF EXISTS pt_schutzzone;
DROP TABLE IF EXISTS pt_schutzzone_schutzgebietnachwasserrecht;

--Temp-Tabelle um istteilvon aufzulösen
SELECT  gml_id, anlass, beginnt, endet, advstandardmodell, sonstigesmodell, 
       zeigtaufexternes_art, zeigtaufexternes_name, zeigtaufexternes_uri, 
       nummerderschutzzone, rechtszustand, zone, istabgeleitetaus, traegtbeizu, 
       hatdirektunten, unnest(istteilvon) as istteilvon, wkb_geometry
  INTO pt_schutzzone
  FROM ax_schutzzone;


--Join Schutzzone mit SchutzgebietNachWasserrecht
SELECT sz.gml_id, sz.anlass, sz.beginnt, sz.endet, sz.advstandardmodell, sz.sonstigesmodell, 
       sz.zeigtaufexternes_art, sz.zeigtaufexternes_name, sz.zeigtaufexternes_uri, 
       sz.nummerderschutzzone, sz.rechtszustand, sz.zone, sz.istabgeleitetaus, sz.traegtbeizu, 
       sz.hatdirektunten, sz.istteilvon, sz.wkb_geometry,
       sw.gml_id as gml_id_sw, sw.anlass as anlass_sw, sw.beginnt as beginnt_sw, sw.endet as endet_sw, sw.advstandardmodell as advstandardmodell_sw, sw.sonstigesmodell as sonstigesmodell_sw, 
       sw.zeigtaufexternes_art as zeigtaufexternes_art_sw, sw.zeigtaufexternes_name as zeigtaufexternes_name_sw, sw.zeigtaufexternes_uri as zeigtaufexternes_uri_sw, 
       sw.artderfestlegung, sw.land, sw.stelle, sw.funktion, sw.name, sw.nummerdesschutzgebietes, 
       sw.statement, sw.processstep_ax_li_processstep_mitdatenerhebung_description, 
       sw.processstep_rationale, sw.processstep_datetime, sw.processstep_individualname, 
       sw.processstep_organisationname, sw.processstep_positionname, sw.processstep_phone, 
       sw.processstep_address, sw.processstep_onlineresource, sw.processstep_hoursofservice, 
       sw.processstep_contactinstructions, sw.processstep_role, sw.processstep_ax_datenerhebung, 
       sw.processstep_scaledenominator, sw.processstep_sourcereferencesystem, 
       sw.processstep_sourceextent, sw.processstep_sourcestep, sw.herkunft_source_source_ax_datenerhebung, 
       sw.herkunft_source_source_scaledenominator, sw.herkunft_source_source_sourcereferencesystem, 
       sw.herkunft_source_source_sourceextent, sw.herkunft_source_source_sourcestep, 
       sw.bestehtaus, sw.istteilvon as istteilvon_sw
  INTO pt_schutzzone_schutzgebietnachwasserrecht
  FROM pt_schutzzone sz
  LEFT JOIN ax_schutzgebietnachwasserrecht sw ON sz.istteilvon = sw.gml_id;


--gid-Spalte erstellen fuer primary key--
ALTER TABLE pt_schutzzone_schutzgebietnachwasserrecht ADD COLUMN ogc_fid serial NOT NULL;

-- Constrains--
ALTER TABLE pt_schutzzone_schutzgebietnachwasserrecht ADD CONSTRAINT pt_schutzzone_schutzgebietnachwasserrecht_pk PRIMARY KEY (ogc_fid);
ALTER TABLE pt_schutzzone_schutzgebietnachwasserrecht ADD CONSTRAINT enforce_dims_the_geom CHECK (st_ndims(wkb_geometry) = 2);
ALTER TABLE pt_schutzzone_schutzgebietnachwasserrecht ADD CONSTRAINT enforce_srid_the_geom CHECK (st_srid(wkb_geometry) = 25832);

-- INSERT into postgis_21.geometry_column--s
INSERT INTO postgis.geometry_columns(f_table_catalog,f_table_schema, f_table_name, f_geometry_column,coord_dimension, srid, type)
    VALUES ('','public', 'pt_schutzzone_schutzgebietnachwasserrecht', 'wkb_geometry', 2, 25832, 'MULTIPOLYGON');

-- Index: ax_schutzzone_wkb_geometry_idx
CREATE INDEX pt_schutzzone_schutzgebietnachwasserrecht_geom ON pt_schutzzone_schutzgebietnachwasserrecht USING gist (wkb_geometry) TABLESPACE pgdata;

