--ax_industrieundgewerbeflaeche
SELECT ogc_fid, gml_id, anlass, beginnt, endet, advstandardmodell, sonstigesmodell, 
       zeigtaufexternes_art, zeigtaufexternes_name, zeigtaufexternes_uri, 
       datumderletztenueberpruefung, statement, processstep_ax_li_processstep_mitdatenerhebung_description, 
       processstep_rationale, processstep_datetime, processstep_individualname, 
       processstep_organisationname, processstep_positionname, processstep_phone, 
       processstep_address, processstep_onlineresource, processstep_hoursofservice, 
       processstep_contactinstructions, processstep_role, processstep_ax_datenerhebung, 
       processstep_scaledenominator, processstep_sourcereferencesystem, 
       processstep_sourceextent, processstep_sourcestep, herkunft_source_source_ax_datenerhebung, 
       herkunft_source_source_scaledenominator, herkunft_source_source_sourcereferencesystem, 
       herkunft_source_source_sourceextent, herkunft_source_source_sourcestep, 
       bezeichnung, foerdergut, foe.beschreibung as foerdergut_beschreibung, 
       funktion, fu.beschreibung as funktion_beschreibung, lagergut, name, primaerenergie, 
       zustand, istabgeleitetaus, traegtbeizu, hatdirektunten, istteilvon, 
       wkb_geometry
  INTO pt_industrieundgewerbeflaeche
  FROM ax_industrieundgewerbeflaeche ax
  LEFT JOIN ax_funktion_industrieundgewerbeflaeche fu ON ax.funktion = fu.wert
  LEFT JOIN ax_foerdergut_industrieundgewerbeflaeche foe ON ax.foerdergut = foe.wert;

--ax_flaechegemischternutzung
SELECT ogc_fid, gml_id, anlass, beginnt, endet, advstandardmodell, sonstigesmodell, 
       zeigtaufexternes_art, zeigtaufexternes_name, zeigtaufexternes_uri, 
       datumderletztenueberpruefung, statement, processstep_ax_li_processstep_mitdatenerhebung_description, 
       processstep_rationale, processstep_datetime, processstep_individualname, 
       processstep_organisationname, processstep_positionname, processstep_phone, 
       processstep_address, processstep_onlineresource, processstep_hoursofservice, 
       processstep_contactinstructions, processstep_role, processstep_ax_datenerhebung, 
       processstep_scaledenominator, processstep_sourcereferencesystem, 
       processstep_sourceextent, processstep_sourcestep, herkunft_source_source_ax_datenerhebung, 
       herkunft_source_source_scaledenominator, herkunft_source_source_sourcereferencesystem, 
       herkunft_source_source_sourceextent, herkunft_source_source_sourcestep, 
       artderbebauung, funktion, fu.beschreibung as funktion_beschreibung, name, zustand, istabgeleitetaus, traegtbeizu, 
       hatdirektunten, istteilvon, wkb_geometry
  INTO pt_flaechegemischternutzung
  FROM ax_flaechegemischternutzung ax
  LEFT JOIN ax_funktion_flaechegemischternutzung fu ON ax.funktion = fu.wert;

--ax_flaechebesondererfunktionalerpraegung
SELECT ogc_fid, gml_id, anlass, beginnt, endet, advstandardmodell, sonstigesmodell, 
       zeigtaufexternes_art, zeigtaufexternes_name, zeigtaufexternes_uri, 
       datumderletztenueberpruefung, statement, processstep_ax_li_processstep_mitdatenerhebung_description, 
       processstep_rationale, processstep_datetime, processstep_individualname, 
       processstep_organisationname, processstep_positionname, processstep_phone, 
       processstep_address, processstep_onlineresource, processstep_hoursofservice, 
       processstep_contactinstructions, processstep_role, processstep_ax_datenerhebung, 
       processstep_scaledenominator, processstep_sourcereferencesystem, 
       processstep_sourceextent, processstep_sourcestep, herkunft_source_source_ax_datenerhebung, 
       herkunft_source_source_scaledenominator, herkunft_source_source_sourcereferencesystem, 
       herkunft_source_source_sourceextent, herkunft_source_source_sourcestep, 
       artderbebauung, funktion, fu.beschreibung as funktion_beschreibung, name, zustand, istabgeleitetaus, traegtbeizu, 
       hatdirektunten, istteilvon, wkb_geometry
  INTO pt_flaechebesondererfunktionalerpraegung
  FROM ax_flaechebesondererfunktionalerpraegung ax
  LEFT JOIN ax_funktion_flaechebesondererfunktionalerpraegung fu ON ax.funktion = fu.wert;

--ax_sportfreizeitunderholungsflaeche
SELECT ogc_fid, gml_id, anlass, beginnt, endet, advstandardmodell, sonstigesmodell, 
       zeigtaufexternes_art, zeigtaufexternes_name, zeigtaufexternes_uri, 
       datumderletztenueberpruefung, statement, processstep_ax_li_processstep_mitdatenerhebung_description, 
       processstep_rationale, processstep_datetime, processstep_individualname, 
       processstep_organisationname, processstep_positionname, processstep_phone, 
       processstep_address, processstep_onlineresource, processstep_hoursofservice, 
       processstep_contactinstructions, processstep_role, processstep_ax_datenerhebung, 
       processstep_scaledenominator, processstep_sourcereferencesystem, 
       processstep_sourceextent, processstep_sourcestep, herkunft_source_source_ax_datenerhebung, 
       herkunft_source_source_scaledenominator, herkunft_source_source_sourcereferencesystem, 
       herkunft_source_source_sourceextent, herkunft_source_source_sourcestep, 
       bezeichnung, funktion, fu.beschreibung as funktion_beschreibung, name, zustand, istabgeleitetaus, traegtbeizu, 
       hatdirektunten, istteilvon, wkb_geometry
  INTO pt_sportfreizeitunderholungsflaeche
  FROM ax_sportfreizeitunderholungsflaeche ax
  LEFT JOIN ax_funktion_sportfreizeitunderholungsflaeche fu ON ax.funktion = fu.wert;

--ax_friedhof
SELECT ogc_fid, gml_id, anlass, beginnt, endet, advstandardmodell, sonstigesmodell, 
       zeigtaufexternes_art, zeigtaufexternes_name, zeigtaufexternes_uri, 
       datumderletztenueberpruefung, statement, processstep_ax_li_processstep_mitdatenerhebung_description, 
       processstep_rationale, processstep_datetime, processstep_individualname, 
       processstep_organisationname, processstep_positionname, processstep_phone, 
       processstep_address, processstep_onlineresource, processstep_hoursofservice, 
       processstep_contactinstructions, processstep_role, processstep_ax_datenerhebung, 
       processstep_scaledenominator, processstep_sourcereferencesystem, 
       processstep_sourceextent, processstep_sourcestep, herkunft_source_source_ax_datenerhebung, 
       herkunft_source_source_scaledenominator, herkunft_source_source_sourcereferencesystem, 
       herkunft_source_source_sourceextent, herkunft_source_source_sourcestep, 
       funktion, fu.beschreibung as funktion_beschreibung, name, zustand, istabgeleitetaus, traegtbeizu, hatdirektunten,
       istteilvon, wkb_geometry 
  INTO pt_friedhof
  FROM ax_friedhof ax
  LEFT JOIN ax_funktion_friedhof fu ON ax.funktion = fu.wert;

--ax_strassenverkehr
SELECT ogc_fid, gml_id, anlass, beginnt, endet, advstandardmodell, sonstigesmodell, 
       zeigtaufexternes_art, zeigtaufexternes_name, zeigtaufexternes_uri, 
       datumderletztenueberpruefung, statement, processstep_ax_li_processstep_mitdatenerhebung_description, 
       processstep_rationale, processstep_datetime, processstep_individualname, 
       processstep_organisationname, processstep_positionname, processstep_phone, 
       processstep_address, processstep_onlineresource, processstep_hoursofservice, 
       processstep_contactinstructions, processstep_role, processstep_ax_datenerhebung, 
       processstep_scaledenominator, processstep_sourcereferencesystem, 
       processstep_sourceextent, processstep_sourcestep, herkunft_source_source_ax_datenerhebung, 
       herkunft_source_source_scaledenominator, herkunft_source_source_sourcereferencesystem, 
       herkunft_source_source_sourceextent, herkunft_source_source_sourcestep, 
       funktion, fu.beschreibung as funktion_beschreibung, unverschluesselt, gemeinde, kreis, lage, land, regierungsbezirk, 
       zustand, zweitname, istabgeleitetaus, traegtbeizu, hatdirektunten, 
       istteilvon, wkb_geometry
  INTO pt_strassenverkehr
  FROM ax_strassenverkehr ax
  LEFT JOIN ax_funktion_strasse fu ON ax.funktion = fu.wert;

--ax_weg
SELECT ogc_fid, gml_id, anlass, beginnt, endet, advstandardmodell, sonstigesmodell, 
       zeigtaufexternes_art, zeigtaufexternes_name, zeigtaufexternes_uri, 
       datumderletztenueberpruefung, statement, processstep_ax_li_processstep_mitdatenerhebung_description, 
       processstep_rationale, processstep_datetime, processstep_individualname, 
       processstep_organisationname, processstep_positionname, processstep_phone, 
       processstep_address, processstep_onlineresource, processstep_hoursofservice, 
       processstep_contactinstructions, processstep_role, processstep_ax_datenerhebung, 
       processstep_scaledenominator, processstep_sourcereferencesystem, 
       processstep_sourceextent, processstep_sourcestep, herkunft_source_source_ax_datenerhebung, 
       herkunft_source_source_scaledenominator, herkunft_source_source_sourcereferencesystem, 
       herkunft_source_source_sourceextent, herkunft_source_source_sourcestep, 
       bezeichnung, funktion, fu.beschreibung as funktion_beschreibung, unverschluesselt, gemeinde, kreis, lage, 
       land, regierungsbezirk, istabgeleitetaus, traegtbeizu, hatdirektunten, 
       istteilvon, wkb_geometry
  INTO pt_weg
  FROM ax_weg ax
  LEFT JOIN ax_funktion_weg fu ON ax.funktion = fu.wert;

--ax_bahnverkehr
SELECT ogc_fid, gml_id, anlass, beginnt, endet, advstandardmodell, sonstigesmodell, 
       zeigtaufexternes_art, zeigtaufexternes_name, zeigtaufexternes_uri, 
       datumderletztenueberpruefung, statement, processstep_ax_li_processstep_mitdatenerhebung_description, 
       processstep_rationale, processstep_datetime, processstep_individualname, 
       processstep_organisationname, processstep_positionname, processstep_phone, 
       processstep_address, processstep_onlineresource, processstep_hoursofservice, 
       processstep_contactinstructions, processstep_role, processstep_ax_datenerhebung, 
       processstep_scaledenominator, processstep_sourcereferencesystem, 
       processstep_sourceextent, processstep_sourcestep, herkunft_source_source_ax_datenerhebung, 
       herkunft_source_source_scaledenominator, herkunft_source_source_sourcereferencesystem, 
       herkunft_source_source_sourceextent, herkunft_source_source_sourcestep, 
       array_to_string(ax.bahnkategorie, ',')::integer as bahnkategorie, bk.beschreibung as bahnkategorie_beschreibung, 
       unverschluesselt, gemeinde, kreis, lage, land, regierungsbezirk, 
       funktion, fu.beschreibung as funktion_beschreibung, nummerderbahnstrecke, zustand, zweitname, 
       istabgeleitetaus, traegtbeizu, hatdirektunten, istteilvon, wkb_geometry
  INTO pt_bahnverkehr
  FROM ax_bahnverkehr ax
  LEFT JOIN ax_funktion_bahnverkehr fu ON ax.funktion = fu.wert
  LEFT JOIN ax_bahnkategorie bk ON array_to_string(ax.bahnkategorie, ',')::integer = bk.wert;

--ax_flugverkehr
SELECT ogc_fid, gml_id, anlass, beginnt, endet, advstandardmodell, sonstigesmodell, 
       zeigtaufexternes_art, zeigtaufexternes_name, zeigtaufexternes_uri, 
       datumderletztenueberpruefung, statement, processstep_ax_li_processstep_mitdatenerhebung_description, 
       processstep_rationale, processstep_datetime, processstep_individualname, 
       processstep_organisationname, processstep_positionname, processstep_phone, 
       processstep_address, processstep_onlineresource, processstep_hoursofservice, 
       processstep_contactinstructions, processstep_role, processstep_ax_datenerhebung, 
       processstep_scaledenominator, processstep_sourcereferencesystem, 
       processstep_sourceextent, processstep_sourcestep, herkunft_source_source_ax_datenerhebung, 
       herkunft_source_source_scaledenominator, herkunft_source_source_sourcereferencesystem, 
       herkunft_source_source_sourceextent, herkunft_source_source_sourcestep, 
       art, art.beschreibung as art_beschreibung, bezeichnung, funktion, fu.beschreibung as funktion_beschreibung, unverschluesselt, gemeinde, kreis, 
       lage, land, regierungsbezirk, nutzung, zustand, zweitname, istabgeleitetaus, 
       traegtbeizu, hatdirektunten, istteilvon, wkb_geometry
  INTO pt_flugverkehr
  FROM ax_flugverkehr ax
  LEFT JOIN ax_funktion_flugverkehr fu ON ax.funktion = fu.wert
  LEFT JOIN ax_art_flugverkehr art ON ax.art = art.wert;

--ax_schiffsverkehr
SELECT ogc_fid, gml_id, anlass, beginnt, endet, advstandardmodell, sonstigesmodell, 
       zeigtaufexternes_art, zeigtaufexternes_name, zeigtaufexternes_uri, 
       datumderletztenueberpruefung, statement, processstep_ax_li_processstep_mitdatenerhebung_description, 
       processstep_rationale, processstep_datetime, processstep_individualname, 
       processstep_organisationname, processstep_positionname, processstep_phone, 
       processstep_address, processstep_onlineresource, processstep_hoursofservice, 
       processstep_contactinstructions, processstep_role, processstep_ax_datenerhebung, 
       processstep_scaledenominator, processstep_sourcereferencesystem, 
       processstep_sourceextent, processstep_sourcestep, herkunft_source_source_ax_datenerhebung, 
       herkunft_source_source_scaledenominator, herkunft_source_source_sourcereferencesystem, 
       herkunft_source_source_sourceextent, herkunft_source_source_sourcestep, 
       funktion, fu.beschreibung as funktion_beschreibung, unverschluesselt, gemeinde, kreis, lage, land, regierungsbezirk, 
       zustand, istabgeleitetaus, traegtbeizu, hatdirektunten, istteilvon, 
       wkb_geometry
  INTO pt_schiffsverkehr
  FROM ax_schiffsverkehr ax
  LEFT JOIN ax_funktion_schiffsverkehr fu ON ax.funktion = fu.wert;

--ax_landwirtschaft
SELECT ogc_fid, gml_id, anlass, beginnt, endet, advstandardmodell, sonstigesmodell, 
       zeigtaufexternes_art, zeigtaufexternes_name, zeigtaufexternes_uri, 
       datumderletztenueberpruefung, statement, processstep_ax_li_processstep_mitdatenerhebung_description, 
       processstep_rationale, processstep_datetime, processstep_individualname, 
       processstep_organisationname, processstep_positionname, processstep_phone, 
       processstep_address, processstep_onlineresource, processstep_hoursofservice, 
       processstep_contactinstructions, processstep_role, processstep_ax_datenerhebung, 
       processstep_scaledenominator, processstep_sourcereferencesystem, 
       processstep_sourceextent, processstep_sourcestep, herkunft_source_source_ax_datenerhebung, 
       herkunft_source_source_scaledenominator, herkunft_source_source_sourcereferencesystem, 
       herkunft_source_source_sourceextent, herkunft_source_source_sourcestep, 
       name, vegetationsmerkmal, vm.beschreibung as vegetationsmerkmal_beschreibung, istabgeleitetaus, traegtbeizu, hatdirektunten, 
       istteilvon, wkb_geometry
  INTO pt_landwirtschaft
  FROM ax_landwirtschaft ax
  LEFT JOIN ax_vegetationsmerkmal_landwirtschaft vm ON ax.vegetationsmerkmal = vm.wert;

--ax_wald
SELECT ogc_fid, gml_id, anlass, beginnt, endet, advstandardmodell, sonstigesmodell, 
       zeigtaufexternes_art, zeigtaufexternes_name, zeigtaufexternes_uri, 
       datumderletztenueberpruefung, statement, processstep_ax_li_processstep_mitdatenerhebung_description, 
       processstep_rationale, processstep_datetime, processstep_individualname, 
       processstep_organisationname, processstep_positionname, processstep_phone, 
       processstep_address, processstep_onlineresource, processstep_hoursofservice, 
       processstep_contactinstructions, processstep_role, processstep_ax_datenerhebung, 
       processstep_scaledenominator, processstep_sourcereferencesystem, 
       processstep_sourceextent, processstep_sourcestep, herkunft_source_source_ax_datenerhebung, 
       herkunft_source_source_scaledenominator, herkunft_source_source_sourcereferencesystem, 
       herkunft_source_source_sourceextent, herkunft_source_source_sourcestep, 
       bezeichnung, name, nutzung, regionalsprache, vegetationsmerkmal, zustand, vm.beschreibung as vegetationsmerkmal_beschreibung, istabgeleitetaus, traegtbeizu, 
       hatdirektunten, istteilvon, wkb_geometry
  INTO pt_wald
  FROM ax_wald ax
  LEFT JOIN ax_vegetationsmerkmal_wald vm ON ax.vegetationsmerkmal = vm.wert;

--ax_unlandvegetationsloseflaeche
SELECT ogc_fid, gml_id, anlass, beginnt, endet, advstandardmodell, sonstigesmodell, 
       zeigtaufexternes_art, zeigtaufexternes_name, zeigtaufexternes_uri, 
       datumderletztenueberpruefung, statement, processstep_ax_li_processstep_mitdatenerhebung_description, 
       processstep_rationale, processstep_datetime, processstep_individualname, 
       processstep_organisationname, processstep_positionname, processstep_phone, 
       processstep_address, processstep_onlineresource, processstep_hoursofservice, 
       processstep_contactinstructions, processstep_role, processstep_ax_datenerhebung, 
       processstep_scaledenominator, processstep_sourcereferencesystem, 
       processstep_sourceextent, processstep_sourcestep, herkunft_source_source_ax_datenerhebung, 
       herkunft_source_source_scaledenominator, herkunft_source_source_sourcereferencesystem, 
       herkunft_source_source_sourceextent, herkunft_source_source_sourcestep, 
       funktion, fu.beschreibung as funktion_beschreibung, name, oberflaechenmaterial, 
       om.beschreibung as oberflaechenmaterial_beschreibung, istabgeleitetaus, traegtbeizu, 
       hatdirektunten, istteilvon, wkb_geometry
  INTO pt_unlandvegetationsloseflaeche
  FROM ax_unlandvegetationsloseflaeche ax
  LEFT JOIN ax_funktion_unlandvegetationsloseflaeche fu ON ax.funktion = fu.wert
  LEFT JOIN ax_oberflaechenmaterial_unlandvegetationsloseflaeche om ON ax.oberflaechenmaterial = om.wert;

--ax_fliessgewaesser
SELECT ogc_fid, gml_id, anlass, beginnt, endet, advstandardmodell, sonstigesmodell, 
       zeigtaufexternes_art, zeigtaufexternes_name, zeigtaufexternes_uri, 
       datumderletztenueberpruefung, statement, processstep_ax_li_processstep_mitdatenerhebung_description, 
       processstep_rationale, processstep_datetime, processstep_individualname, 
       processstep_organisationname, processstep_positionname, processstep_phone, 
       processstep_address, processstep_onlineresource, processstep_hoursofservice, 
       processstep_contactinstructions, processstep_role, processstep_ax_datenerhebung, 
       processstep_scaledenominator, processstep_sourcereferencesystem, 
       processstep_sourceextent, processstep_sourcestep, herkunft_source_source_ax_datenerhebung, 
       herkunft_source_source_scaledenominator, herkunft_source_source_sourcereferencesystem, 
       herkunft_source_source_sourceextent, herkunft_source_source_sourcestep, 
       funktion, hydrologischesmerkmal, fu.beschreibung as funktion_beschreibung, unverschluesselt, gemeinde, 
       kreis, lage, land, regierungsbezirk, zustand, istabgeleitetaus, 
       traegtbeizu, hatdirektunten, istteilvon, wkb_geometry
  INTO pt_fliessgewaesser
  FROM ax_fliessgewaesser ax
  LEFT JOIN ax_funktion_fliessgewaesser fu ON ax.funktion = fu.wert;

--ax_stehendesgewaesser
SELECT ogc_fid, gml_id, anlass, beginnt, endet, advstandardmodell, sonstigesmodell, 
       zeigtaufexternes_art, zeigtaufexternes_name, zeigtaufexternes_uri, 
       datumderletztenueberpruefung, statement, processstep_ax_li_processstep_mitdatenerhebung_description, 
       processstep_rationale, processstep_datetime, processstep_individualname, 
       processstep_organisationname, processstep_positionname, processstep_phone, 
       processstep_address, processstep_onlineresource, processstep_hoursofservice, 
       processstep_contactinstructions, processstep_role, processstep_ax_datenerhebung, 
       processstep_scaledenominator, processstep_sourcereferencesystem, 
       processstep_sourceextent, processstep_sourcestep, herkunft_source_source_ax_datenerhebung, 
       herkunft_source_source_scaledenominator, herkunft_source_source_sourcereferencesystem, 
       herkunft_source_source_sourceextent, herkunft_source_source_sourcestep, 
       bezeichnung, funktion, fu.beschreibung as funktion_beschreibung, hydrologischesmerkmal, unverschluesselt, 
       gemeinde, kreis, lage, land, regierungsbezirk, nutzung, regionalsprache, schifffahrtskategorie, seekennzahl, 
       wasserspiegelhoeheinstehendemgewaesser, widmung, zustand, zweitname, hatdirektunten, 
       istabgeleitetaus, traegtbeizu, istteilvon, wkb_geometry
  INTO pt_stehendesgewaesser
  FROM ax_stehendesgewaesser ax
  LEFT JOIN ax_funktion_stehendesgewaesser fu ON ax.funktion = fu.wert;

--ax_bergbaubetrieb
SELECT ogc_fid, gml_id, anlass, beginnt, endet, advstandardmodell, sonstigesmodell, 
       zeigtaufexternes_art, zeigtaufexternes_name, zeigtaufexternes_uri, 
       datumderletztenueberpruefung, statement, processstep_ax_li_processstep_mitdatenerhebung_description, 
       processstep_rationale, processstep_datetime, processstep_individualname, 
       processstep_organisationname, processstep_positionname, processstep_phone, 
       processstep_address, processstep_onlineresource, processstep_hoursofservice, 
       processstep_contactinstructions, processstep_role, processstep_ax_datenerhebung, 
       processstep_scaledenominator, processstep_sourcereferencesystem, 
       processstep_sourceextent, processstep_sourcestep, herkunft_source_source_ax_datenerhebung, 
       herkunft_source_source_scaledenominator, herkunft_source_source_sourcereferencesystem, 
       herkunft_source_source_sourceextent, herkunft_source_source_sourcestep, 
       abbaugut, ab.beschreibung as abbaugut_beschreibung, bezeichnung, funktion, name, zustand, istabgeleitetaus, traegtbeizu, 
       hatdirektunten, istteilvon, wkb_geometry
  INTO pt_bergbaubetrieb
  FROM ax_bergbaubetrieb ax
  LEFT JOIN ax_abbaugut_bergbaubetrieb ab ON ax.abbaugut = ab.wert;

--ax_tagebaugrubesteinbruch
SELECT ogc_fid, gml_id, anlass, beginnt, endet, advstandardmodell, sonstigesmodell, 
       zeigtaufexternes_art, zeigtaufexternes_name, zeigtaufexternes_uri, 
       datumderletztenueberpruefung, statement, processstep_ax_li_processstep_mitdatenerhebung_description, 
       processstep_rationale, processstep_datetime, processstep_individualname, 
       processstep_organisationname, processstep_positionname, processstep_phone, 
       processstep_address, processstep_onlineresource, processstep_hoursofservice, 
       processstep_contactinstructions, processstep_role, processstep_ax_datenerhebung, 
       processstep_scaledenominator, processstep_sourcereferencesystem, 
       processstep_sourceextent, processstep_sourcestep, herkunft_source_source_ax_datenerhebung, 
       herkunft_source_source_scaledenominator, herkunft_source_source_sourcereferencesystem, 
       herkunft_source_source_sourceextent, herkunft_source_source_sourcestep, 
       abbaugut, ab.beschreibung as abbaugut_beschreibung, bezeichnung, funktion, name, zustand, istabgeleitetaus, traegtbeizu, 
       hatdirektunten, istteilvon, wkb_geometry
  INTO pt_tagebaugrubesteinbruch
  FROM ax_tagebaugrubesteinbruch ax
  LEFT JOIN ax_abbaugut_tagebaugrubesteinbruch ab ON ax.abbaugut = ab.wert;

--ax_platz
SELECT ogc_fid, gml_id, anlass, beginnt, endet, advstandardmodell, sonstigesmodell, 
       zeigtaufexternes_art, zeigtaufexternes_name, zeigtaufexternes_uri, 
       datumderletztenueberpruefung, statement, processstep_ax_li_processstep_mitdatenerhebung_description, 
       processstep_rationale, processstep_datetime, processstep_individualname, 
       processstep_organisationname, processstep_positionname, processstep_phone, 
       processstep_address, processstep_onlineresource, processstep_hoursofservice, 
       processstep_contactinstructions, processstep_role, processstep_ax_datenerhebung, 
       processstep_scaledenominator, processstep_sourcereferencesystem, 
       processstep_sourceextent, processstep_sourcestep, herkunft_source_source_ax_datenerhebung, 
       herkunft_source_source_scaledenominator, herkunft_source_source_sourcereferencesystem, 
       herkunft_source_source_sourceextent, herkunft_source_source_sourcestep, 
       funktion, fu.beschreibung as funktion_beschreibung, unverschluesselt, gemeinde, kreis, lage, land, regierungsbezirk, 
       regionalsprache, strassenschluessel, zweitname, istabgeleitetaus, traegtbeizu, 
       hatdirektunten, istteilvon, wkb_geometry
  INTO pt_platz
  FROM ax_platz ax
  LEFT JOIN ax_funktion_platz fu ON ax.funktion = fu.wert;

--ax_wohnbauflaeche
SELECT ogc_fid, gml_id, anlass, beginnt, endet, advstandardmodell, sonstigesmodell, 
       zeigtaufexternes_art, zeigtaufexternes_name, zeigtaufexternes_uri, 
       datumderletztenueberpruefung, statement, processstep_ax_li_processstep_mitdatenerhebung_description, 
       processstep_rationale, processstep_datetime, processstep_individualname, 
       processstep_organisationname, processstep_positionname, processstep_phone, 
       processstep_address, processstep_onlineresource, processstep_hoursofservice, 
       processstep_contactinstructions, processstep_role, processstep_ax_datenerhebung, 
       processstep_scaledenominator, processstep_sourcereferencesystem, 
       processstep_sourceextent, processstep_sourcestep, herkunft_source_source_ax_datenerhebung, 
       herkunft_source_source_scaledenominator, herkunft_source_source_sourcereferencesystem, 
       herkunft_source_source_sourceextent, herkunft_source_source_sourcestep, 
       artderbebauung, ad.beschreibung as artderbebauung_beschreibung, funktion, name, zustand, 
       zweitname, istabgeleitetaus, traegtbeizu, hatdirektunten, istteilvon, wkb_geometry
  INTO pt_wohnbauflaeche
  FROM ax_wohnbauflaeche ax
  LEFT JOIN ax_artderbebauung_wohnbauflaeche ad ON ax.artderbebauung = ad.wert;

-- Constrains--
ALTER TABLE pt_bahnverkehr ADD CONSTRAINT pt_bahnverkehr_pkey PRIMARY KEY (ogc_fid);
ALTER TABLE pt_bergbaubetrieb ADD CONSTRAINT pt_bergbaubetrieb_pkey PRIMARY KEY (ogc_fid);
ALTER TABLE pt_flaechebesondererfunktionalerpraegung ADD CONSTRAINT pt_flaechebesondererfunktionalerpraegung_pkey PRIMARY KEY (ogc_fid);
ALTER TABLE pt_flaechegemischternutzung ADD CONSTRAINT pt_flaechegemischternutzung_pkey PRIMARY KEY (ogc_fid);
ALTER TABLE pt_fliessgewaesser ADD CONSTRAINT pt_fliessgewaesser_pkey PRIMARY KEY (ogc_fid);
ALTER TABLE pt_flugverkehr ADD CONSTRAINT pt_flugverkehr_pkey PRIMARY KEY (ogc_fid);
ALTER TABLE pt_friedhof ADD CONSTRAINT pt_friedhof_pkey PRIMARY KEY (ogc_fid);
ALTER TABLE pt_industrieundgewerbeflaeche ADD CONSTRAINT pt_industrieundgewerbeflaeche_pkey PRIMARY KEY (ogc_fid);
ALTER TABLE pt_landwirtschaft ADD CONSTRAINT pt_landwirtschaft_pkey PRIMARY KEY (ogc_fid);
ALTER TABLE pt_platz ADD CONSTRAINT pt_platz_pkey PRIMARY KEY (ogc_fid);
ALTER TABLE pt_schiffsverkehr ADD CONSTRAINT pt_schiffsverkehr_pkey PRIMARY KEY (ogc_fid);
ALTER TABLE pt_sportfreizeitunderholungsflaeche ADD CONSTRAINT pt_sportfreizeitunderholungsflaeche_pkey PRIMARY KEY (ogc_fid);
ALTER TABLE pt_stehendesgewaesser ADD CONSTRAINT pt_stehendesgewaesser_pkey PRIMARY KEY (ogc_fid);
ALTER TABLE pt_strassenverkehr ADD CONSTRAINT pt_strassenverkehr_pkey PRIMARY KEY (ogc_fid);
ALTER TABLE pt_tagebaugrubesteinbruch ADD CONSTRAINT pt_tagebaugrubesteinbruch_pkey PRIMARY KEY (ogc_fid);
ALTER TABLE pt_unlandvegetationsloseflaeche ADD CONSTRAINT pt_unlandvegetationsloseflaeche_pkey PRIMARY KEY (ogc_fid);
ALTER TABLE pt_wald ADD CONSTRAINT pt_wald_pkey PRIMARY KEY (ogc_fid);
ALTER TABLE pt_weg ADD CONSTRAINT pt_weg_pkey PRIMARY KEY (ogc_fid);
ALTER TABLE pt_wohnbauflaeche ADD CONSTRAINT pt_wohnbauflaeche_pkey PRIMARY KEY (ogc_fid);

--Index--
CREATE UNIQUE INDEX pt_bahnverkehr_gml ON pt_bahnverkehr USING btree (gml_id COLLATE pg_catalog."default", beginnt COLLATE pg_catalog."default");
CREATE INDEX pt_bahnverkehr_wkb_geometry_idx ON pt_bahnverkehr USING gist (wkb_geometry);
CREATE UNIQUE INDEX pt_bergbaubetrieb_gml ON pt_bergbaubetrieb USING btree (gml_id COLLATE pg_catalog."default", beginnt COLLATE pg_catalog."default");
CREATE INDEX pt_bergbaubetrieb_wkb_geometry_idx ON pt_bergbaubetrieb USING gist (wkb_geometry);
CREATE UNIQUE INDEX pt_flaechebesondererfunktionalerpraegung_gml ON pt_flaechebesondererfunktionalerpraegung USING btree (gml_id COLLATE pg_catalog."default", beginnt COLLATE pg_catalog."default");
CREATE INDEX pt_flaechebesondererfunktionalerpraegung_wkb_geometry_idx ON pt_flaechebesondererfunktionalerpraegung USING gist (wkb_geometry);
CREATE UNIQUE INDEX pt_flaechegemischternutzung_gml ON pt_flaechegemischternutzung USING btree (gml_id COLLATE pg_catalog."default", beginnt COLLATE pg_catalog."default");
CREATE INDEX pt_flaechegemischternutzung_wkb_geometry_idx ON pt_flaechegemischternutzung USING gist (wkb_geometry);
CREATE UNIQUE INDEX fliessgewaesser_gml ON pt_fliessgewaesser USING btree (gml_id COLLATE pg_catalog."default", beginnt COLLATE pg_catalog."default");
CREATE INDEX pt_fliessgewaesser_wkb_geometry_idx ON pt_fliessgewaesser USING gist (wkb_geometry);
CREATE UNIQUE INDEX pt_flugverkehr_gml ON pt_flugverkehr USING btree (gml_id COLLATE pg_catalog."default", beginnt COLLATE pg_catalog."default");
CREATE INDEX pt_flugverkehr_wkb_geometry_idx ON pt_flugverkehr USING gist (wkb_geometry);
CREATE UNIQUE INDEX pt_friedhof_gml ON pt_friedhof USING btree (gml_id COLLATE pg_catalog."default", beginnt COLLATE pg_catalog."default");
CREATE INDEX pt_friedhof_wkb_geometry_idx ON pt_friedhof USING gist (wkb_geometry);
CREATE UNIQUE INDEX pt_industrieundgewerbeflaeche_gml ON pt_industrieundgewerbeflaeche USING btree (gml_id COLLATE pg_catalog."default", beginnt COLLATE pg_catalog."default");
CREATE INDEX pt_industrieundgewerbeflaeche_wkb_geometry_idx ON pt_industrieundgewerbeflaeche USING gist (wkb_geometry);
CREATE UNIQUE INDEX pt_landwirtschaft_gml ON pt_landwirtschaft USING btree (gml_id COLLATE pg_catalog."default", beginnt COLLATE pg_catalog."default");
CREATE INDEX pt_landwirtschaft_wkb_geometry_idx ON pt_landwirtschaft USING gist (wkb_geometry);
CREATE UNIQUE INDEX pt_platz_gml ON pt_platz USING btree (gml_id COLLATE pg_catalog."default", beginnt COLLATE pg_catalog."default");
CREATE INDEX pt_platz_wkb_geometry_idx ON pt_platz USING gist (wkb_geometry);
CREATE UNIQUE INDEX pt_schiffsverkehr_gml ON pt_schiffsverkehr USING btree (gml_id COLLATE pg_catalog."default", beginnt COLLATE pg_catalog."default");
CREATE INDEX pt_schiffsverkehr_wkb_geometry_idx ON pt_schiffsverkehr USING gist (wkb_geometry);
CREATE UNIQUE INDEX pt_sportfreizeitunderholungsflaeche_gml ON pt_sportfreizeitunderholungsflaeche USING btree (gml_id COLLATE pg_catalog."default", beginnt COLLATE pg_catalog."default");
CREATE INDEX pt_sportfreizeitunderholungsflaeche_wkb_geometry_idx ON pt_sportfreizeitunderholungsflaeche USING gist (wkb_geometry);
CREATE UNIQUE INDEX pt_stehendesgewaesser_gml ON pt_stehendesgewaesser USING btree (gml_id COLLATE pg_catalog."default", beginnt COLLATE pg_catalog."default");
CREATE INDEX pt_stehendesgewaesser_wkb_geometry_idx ON pt_stehendesgewaesser USING gist (wkb_geometry);
CREATE UNIQUE INDEX pt_strassenverkehr_gml ON pt_strassenverkehr USING btree (gml_id COLLATE pg_catalog."default", beginnt COLLATE pg_catalog."default");
CREATE INDEX pt_strassenverkehr_wkb_geometry_idx ON pt_strassenverkehr USING gist (wkb_geometry);
CREATE UNIQUE INDEX pt_tagebaugrubesteinbruch_gml ON pt_tagebaugrubesteinbruch USING btree (gml_id COLLATE pg_catalog."default", beginnt COLLATE pg_catalog."default");
CREATE INDEX pt_tagebaugrubesteinbruch_wkb_geometry_idx ON pt_tagebaugrubesteinbruch USING gist (wkb_geometry);
CREATE UNIQUE INDEX pt_unlandvegetationsloseflaeche_gml ON pt_unlandvegetationsloseflaeche USING btree (gml_id COLLATE pg_catalog."default", beginnt COLLATE pg_catalog."default");
CREATE INDEX pt_unlandvegetationsloseflaeche_wkb_geometry_idx ON pt_unlandvegetationsloseflaeche USING gist (wkb_geometry);
CREATE UNIQUE INDEX pt_wald_gml ON pt_wald USING btree (gml_id COLLATE pg_catalog."default", beginnt COLLATE pg_catalog."default");
CREATE INDEX pt_wald_wkb_geometry_idx ON pt_wald USING gist (wkb_geometry);
CREATE UNIQUE INDEX pt_weg_gml ON pt_weg USING btree (gml_id COLLATE pg_catalog."default", beginnt COLLATE pg_catalog."default");
CREATE INDEX pt_weg_wkb_geometry_idx ON pt_weg USING gist (wkb_geometry);
CREATE UNIQUE INDEX pt_wohnbauflaeche_gml ON pt_wohnbauflaeche USING btree (gml_id COLLATE pg_catalog."default", beginnt COLLATE pg_catalog."default");
CREATE INDEX pt_wohnbauflaeche_wkb_geometry_idx ON pt_wohnbauflaeche USING gist (wkb_geometry);