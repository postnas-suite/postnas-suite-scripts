--Topographie / Beschriftungen bt
SELECT
	ogc_fid,
	gml_id,
	TEXT,
	f.umn AS color_umn,
	lower(art) || COALESCE('-' || effekt, '')
		|| CASE
		WHEN stil = 'Kursiv' THEN '-italic'
		WHEN stil = 'Fett' THEN '-bold'
		WHEN stil = 'Fett, Kursiv' THEN '-bold-italic'
		ELSE ''
		END ||
		CASE
		WHEN COALESCE(fontsperrung, 0)= 0 THEN ''
		ELSE '-' ||(fontsperrung / 0.25)::int
	END AS font_umn,
	0.25 / 0.0254 * skalierung * grad_pt AS size_umn,
		CASE COALESCE(l.vertikaleausrichtung, s.vertikaleausrichtung)
		WHEN 'oben' THEN 'L'
		WHEN 'Basis' THEN 'U'
		ELSE 'C'
		END ||
		CASE COALESCE(l.horizontaleausrichtung, s.horizontaleausrichtung)
		WHEN 'linksbündig' THEN 'L'
		WHEN 'rechtsbündig' THEN 'R'
		ELSE 'C'
	END AS position_umn,
	drehwinkel_grad,
	point AS geom
INTO po_labels_bt
FROM po_labels l
JOIN alkis_schriften s ON s.signaturnummer = l.signaturnummer
AND s.katalog = 1
JOIN alkis_farben f ON s.farbe = f.id
WHERE thema = 'Topographie'
AND modell && ARRAY['DLKM','DKKM1000']::varchar[]
AND point IS NOT NULL;

--FriedHöfe / Beschriftungen bh
SELECT
	ogc_fid,
	gml_id,
	TEXT,
	f.umn AS color_umn,
	lower(art) || COALESCE('-' || effekt, '')
		|| CASE
		WHEN stil = 'Kursiv' THEN '-italic'
		WHEN stil = 'Fett' THEN '-bold'
		WHEN stil = 'Fett, Kursiv' THEN '-bold-italic'
		ELSE ''
		END ||
		CASE
		WHEN COALESCE(fontsperrung, 0)= 0 THEN ''
		ELSE '-' ||(fontsperrung / 0.25)::int
	END AS font_umn,
	0.25 / 0.0254 * skalierung * grad_pt AS size_umn,
		CASE COALESCE(l.vertikaleausrichtung, s.vertikaleausrichtung)
		WHEN 'oben' THEN 'L'
		WHEN 'Basis' THEN 'U'
		ELSE 'C'
		END ||
		CASE COALESCE(l.horizontaleausrichtung, s.horizontaleausrichtung)
		WHEN 'linksbündig' THEN 'L'
		WHEN 'rechtsbündig' THEN 'R'
		ELSE 'C'
	END AS position_umn,
	drehwinkel_grad,
	point AS geom
INTO po_labels_bh
FROM po_labels l
JOIN alkis_schriften s ON s.signaturnummer = l.signaturnummer
AND s.katalog = 1
JOIN alkis_farben f ON s.farbe = f.id
WHERE thema = 'Friedhöfe'
AND modell && ARRAY['DLKM','DKKM1000']::varchar[]
AND point IS NOT NULL;

--WohnBauflächen / Beschriftungen bb
SELECT
	ogc_fid,
	gml_id,
	TEXT,
	f.umn AS color_umn,
	lower(art) || COALESCE('-' || effekt, '')
		|| CASE
		WHEN stil = 'Kursiv' THEN '-italic'
		WHEN stil = 'Fett' THEN '-bold'
		WHEN stil = 'Fett, Kursiv' THEN '-bold-italic'
		ELSE ''
		END ||
		CASE
		WHEN COALESCE(fontsperrung, 0)= 0 THEN ''
		ELSE '-' ||(fontsperrung / 0.25)::int
	END AS font_umn,
	0.25 / 0.0254 * skalierung * grad_pt AS size_umn,
		CASE COALESCE(l.vertikaleausrichtung, s.vertikaleausrichtung)
		WHEN 'oben' THEN 'L'
		WHEN 'Basis' THEN 'U'
		ELSE 'C'
		END ||
		CASE COALESCE(l.horizontaleausrichtung, s.horizontaleausrichtung)
		WHEN 'linksbündig' THEN 'R'
		WHEN 'rechtsbündig' THEN 'L'
		ELSE 'C'
	END AS position_umn,
	drehwinkel_grad,
	point AS geom
INTO po_labels_bb
FROM po_labels l
JOIN alkis_schriften s ON s.signaturnummer = l.signaturnummer
AND s.katalog = 1
JOIN alkis_farben f ON s.farbe = f.id
WHERE thema = 'Wohnbauflächen'
AND modell && ARRAY['DLKM','DKKM1000']::varchar[]
AND NOT point IS NULL;

--Vegetation / Beschriftungen be
SELECT
	ogc_fid,
	gml_id,
	TEXT,
	f.umn AS color_umn,
	lower(art) || COALESCE('-' || effekt, '')
		|| CASE
		WHEN stil = 'Kursiv' THEN '-italic'
		WHEN stil = 'Fett' THEN '-bold'
		WHEN stil = 'Fett, Kursiv' THEN '-bold-italic'
		ELSE ''
		END ||
		CASE
		WHEN COALESCE(fontsperrung, 0)= 0 THEN ''
		ELSE '-' ||(fontsperrung / 0.25)::int
	END AS font_umn,
	0.25 / 0.0254 * skalierung * grad_pt AS size_umn,
		CASE COALESCE(l.vertikaleausrichtung, s.vertikaleausrichtung)
		WHEN 'oben' THEN 'L'
		WHEN 'Basis' THEN 'U'
		ELSE 'C'
		END ||
		CASE COALESCE(l.horizontaleausrichtung, s.horizontaleausrichtung)
		WHEN 'linksbündig' THEN 'L'
		WHEN 'rechtsbündig' THEN 'R'
		ELSE 'C'
	END AS position_umn,
	drehwinkel_grad,
	point AS geom
INTO po_labels_be
FROM po_labels l
JOIN alkis_schriften s ON s.signaturnummer = l.signaturnummer
AND s.katalog = 1
JOIN alkis_farben f ON s.farbe = f.id
WHERE thema = 'Vegetation'
AND modell && ARRAY['DLKM','DKKM1000']::varchar[]
AND point IS NOT NULL;

--Sport und Freizeit / Beschriftungen bs
SELECT
	ogc_fid,
	gml_id,
	TEXT,
	f.umn AS color_umn,
	lower(art) || COALESCE('-' || effekt, '')
		|| CASE
		WHEN stil = 'Kursiv' THEN '-italic'
		WHEN stil = 'Fett' THEN '-bold'
		WHEN stil = 'Fett, Kursiv' THEN '-bold-italic'
		ELSE ''
		END ||
		CASE
		WHEN COALESCE(fontsperrung, 0)= 0 THEN ''
		ELSE '-' ||(fontsperrung / 0.25)::int
	END AS font_umn,
	0.25 / 0.0254 * skalierung * grad_pt AS size_umn,
		CASE COALESCE(l.vertikaleausrichtung, s.vertikaleausrichtung)
		WHEN 'oben' THEN 'L'
		WHEN 'Basis' THEN 'U'
		ELSE 'C'
		END ||
		CASE COALESCE(l.horizontaleausrichtung, s.horizontaleausrichtung)
		WHEN 'linksbündig' THEN 'L'
		WHEN 'rechtsbündig' THEN 'R'
		ELSE 'C'
	END AS position_umn,
	drehwinkel_grad,
	point AS geom
INTO po_labels_bs
FROM po_labels l
JOIN alkis_schriften s ON s.signaturnummer = l.signaturnummer
AND s.katalog = 1
JOIN alkis_farben f ON s.farbe = f.id
WHERE thema = 'Sport und Freizeit'
AND modell && ARRAY['DLKM','DKKM1000']::varchar[]
AND point IS NOT NULL;

--Gewässer / Beschriftungen bw
SELECT
	ogc_fid,
	gml_id,
	TEXT,
	f.umn AS color_umn,
	lower(art) || COALESCE('-' || effekt, '')
		|| CASE
		WHEN stil = 'Kursiv' THEN '-italic'
		WHEN stil = 'Fett' THEN '-bold'
		WHEN stil = 'Fett, Kursiv' THEN '-bold-italic'
		ELSE ''
		END ||
		CASE
		WHEN COALESCE(fontsperrung, 0)= 0 THEN ''
		ELSE '-' ||(fontsperrung / 0.25)::int
	END AS font_umn,
	0.25 / 0.0254 * skalierung * grad_pt AS size_umn,
		CASE COALESCE(l.vertikaleausrichtung, s.vertikaleausrichtung)
		WHEN 'oben' THEN 'L'
		WHEN 'Basis' THEN 'U'
		ELSE 'C'
		END ||
		CASE COALESCE(l.horizontaleausrichtung, s.horizontaleausrichtung)
		WHEN 'linksbündig' THEN 'R'
		WHEN 'rechtsbündig' THEN 'L'
		ELSE 'C'
	END AS position_umn,
	drehwinkel_grad,
	point AS geom
INTO po_labels_bw
FROM po_labels l
JOIN alkis_schriften s ON s.signaturnummer = l.signaturnummer
AND s.katalog = 1
JOIN alkis_farben f ON s.farbe = f.id
WHERE thema = 'Gewässer'
AND modell && ARRAY['DLKM','DKKM1000']::varchar[]
AND NOT point IS NULL;

--Gewässer / Beschriftungen (Linien) bwl
SELECT
	ogc_fid,
	gml_id,
	TEXT,
	f.umn AS color_umn,
	lower(art) || COALESCE('-' || effekt, '')
		|| CASE
		WHEN stil = 'Kursiv' THEN '-italic'
		WHEN stil = 'Fett' THEN '-bold'
		WHEN stil = 'Fett, Kursiv' THEN '-bold-italic'
		ELSE ''
		END ||
		CASE
		WHEN COALESCE(fontsperrung, 0)= 0 THEN ''
		ELSE '-' ||(fontsperrung / 0.25)::int
	END AS font_umn,
	0.25 / 0.0254 * skalierung * grad_pt AS size_umn,
	st_offsetcurve(line, 0.125 * skalierung * grad_pt, '') AS geom
INTO po_labels_bwl
FROM po_labels l
JOIN alkis_schriften s ON s.signaturnummer = l.signaturnummer
AND s.katalog = 1
JOIN alkis_farben f ON s.farbe = f.id
WHERE thema = 'Gewässer'
AND modell && ARRAY['DLKM','DKKM1000']::varchar[]
AND line IS NOT NULL;

--Industrie und Gewerbe / Beschriftungen bi
SELECT
	ogc_fid,
	gml_id,
	TEXT,
	f.umn AS color_umn,
	lower(art) || COALESCE('-' || effekt, '')
		|| CASE
		WHEN stil = 'Kursiv' THEN '-italic'
		WHEN stil = 'Fett' THEN '-bold'
		WHEN stil = 'Fett, Kursiv' THEN '-bold-italic'
		ELSE ''
		END ||
		CASE
		WHEN COALESCE(fontsperrung, 0)= 0 THEN ''
		ELSE '-' ||(fontsperrung / 0.25)::int
	END AS font_umn,
	0.25 / 0.0254 * skalierung * grad_pt AS size_umn,
		CASE COALESCE(l.vertikaleausrichtung, s.vertikaleausrichtung)
		WHEN 'oben' THEN 'L'
		WHEN 'Basis' THEN 'U'
		ELSE 'C'
		END ||
		CASE COALESCE(l.horizontaleausrichtung, s.horizontaleausrichtung)
		WHEN 'linksbündig' THEN 'L'
		WHEN 'rechtsbündig' THEN 'R'
		ELSE 'C'
	END AS position_umn,
	drehwinkel_grad,
	point AS geom
INTO po_labels_bi
FROM po_labels l
JOIN alkis_schriften s ON s.signaturnummer = l.signaturnummer
AND s.katalog = 1
JOIN alkis_farben f ON s.farbe = f.id
WHERE thema = 'Industrie und Gewerbe'
AND modell && ARRAY['DLKM','DKKM1000']::varchar[]
AND point IS NOT NULL;

--Verkehr / Beschriftungen bv
SELECT
	ogc_fid,
	gml_id,
	TEXT,
	f.umn AS color_umn,
	lower(art) || COALESCE('-' || effekt, '')
		|| CASE
		WHEN stil = 'Kursiv' THEN '-italic'
		WHEN stil = 'Fett' THEN '-bold'
		WHEN stil = 'Fett, Kursiv' THEN '-bold-italic'
		ELSE ''
		END ||
		CASE
		WHEN COALESCE(fontsperrung, 0)= 0 THEN ''
		ELSE '-' ||(fontsperrung / 0.25)::int
	END AS font_umn,
	0.25 / 0.0254 * skalierung * grad_pt AS size_umn,
		CASE COALESCE(l.vertikaleausrichtung, s.vertikaleausrichtung)
		WHEN 'oben' THEN 'L'
		WHEN 'Basis' THEN 'U'
		ELSE 'C'
		END ||
		CASE COALESCE(l.horizontaleausrichtung, s.horizontaleausrichtung)
		WHEN 'linksbündig' THEN 'R'
		WHEN 'rechtsbündig' THEN 'L'
		ELSE 'C'
	END AS position_umn,
	drehwinkel_grad,
	point AS geom
INTO po_labels_bv
FROM po_labels l
JOIN alkis_schriften s ON s.signaturnummer = l.signaturnummer
AND s.katalog = 1
JOIN alkis_farben f ON s.farbe = f.id
WHERE thema = 'Verkehr'
AND modell && ARRAY['DLKM','DKKM1000']::varchar[]
AND NOT point IS NULL;

--Gebäude / Hausnummer (Hauptgebäude) bgh
SELECT
	ogc_fid,
	gml_id,
	TEXT,
	f.umn AS color_umn,
	lower(art) || COALESCE('-' || effekt, '')
		|| CASE
		WHEN stil = 'Kursiv' THEN '-italic'
		WHEN stil = 'Fett' THEN '-bold'
		WHEN stil = 'Fett, Kursiv' THEN '-bold-italic'
		ELSE ''
		END ||
		CASE
		WHEN COALESCE(fontsperrung, 0)= 0 THEN ''
		ELSE '-' ||(fontsperrung / 0.25)::int
	END AS font_umn,
	0.25 / 0.0254 * skalierung * grad_pt AS size_umn,
		CASE COALESCE(l.vertikaleausrichtung, s.vertikaleausrichtung)
		WHEN 'oben' THEN 'L'
		WHEN 'Basis' THEN 'U'
		ELSE 'C'
		END ||
		CASE COALESCE(l.horizontaleausrichtung, s.horizontaleausrichtung)
		WHEN 'linksbündig' THEN 'L'
		WHEN 'rechtsbündig' THEN 'R'
		ELSE 'C'
	END AS position_umn,
	drehwinkel_grad,
	point AS geom
INTO po_labels_bgh
FROM po_labels l
JOIN alkis_schriften s ON s.signaturnummer = l.signaturnummer
AND s.katalog = 1
JOIN alkis_farben f ON s.farbe = f.id
WHERE thema = 'Gebäude'
AND modell && ARRAY['DLKM','DKKM1000']::varchar[]
AND (layer NOT IN ('ax_lagebezeichnungmitpseudonummer', 'ax_gebaeude_dachform', 'ax_gebaeude_funktion', 'ax_gebaeude_geschosse', 'ax_gebaeude_zustand', 'ax_bauteil_dachform', 'ax_bauteil_funktion', 'ax_bauteil_geschosse', 'ax_turm_funktion'))
AND point IS NOT NULL;

--Gebäude / Nebengebäude lfd. Nr. bgn
SELECT
	ogc_fid,
	gml_id,
	TEXT,
	f.umn AS color_umn,
	lower(art) || COALESCE('-' || effekt, '')
		|| CASE
		WHEN stil = 'Kursiv' THEN '-italic'
		WHEN stil = 'Fett' THEN '-bold'
		WHEN stil = 'Fett, Kursiv' THEN '-bold-italic'
		ELSE ''
		END ||
		CASE
		WHEN COALESCE(fontsperrung, 0)= 0 THEN ''
		ELSE '-' ||(fontsperrung / 0.25)::int
	END AS font_umn,
	0.25 / 0.0254 * skalierung * grad_pt AS size_umn,
		CASE COALESCE(l.vertikaleausrichtung, s.vertikaleausrichtung)
		WHEN 'oben' THEN 'L'
		WHEN 'Basis' THEN 'U'
		ELSE 'C'
		END ||
		CASE COALESCE(l.horizontaleausrichtung, s.horizontaleausrichtung)
		WHEN 'linksbündig' THEN 'L'
		WHEN 'rechtsbündig' THEN 'R'
		ELSE 'C'
	END AS position_umn,
	drehwinkel_grad,
	point AS geom
INTO po_labels_bgn
FROM po_labels l
JOIN alkis_schriften s ON s.signaturnummer = l.signaturnummer
AND s.katalog = 1
JOIN alkis_farben f ON s.farbe = f.id
WHERE thema = 'Gebäude'
AND modell && ARRAY['DLKM','DKKM1000']::varchar[]
AND (layer = 'ax_lagebezeichnungmitpseudonummer')
AND NOT point IS NULL;

--Gebäude / Dachform bgd
SELECT
	ogc_fid,
	gml_id,
	TEXT,
	f.umn AS color_umn,
	lower(art) || COALESCE('-' || effekt, '')
		|| CASE
		WHEN stil = 'Kursiv' THEN '-italic'
		WHEN stil = 'Fett' THEN '-bold'
		WHEN stil = 'Fett, Kursiv' THEN '-bold-italic'
		ELSE ''
		END ||
		CASE
		WHEN COALESCE(fontsperrung, 0)= 0 THEN ''
		ELSE '-' ||(fontsperrung / 0.25)::int
	END AS font_umn,
	0.25 / 0.0254 * skalierung * grad_pt AS size_umn,
		CASE COALESCE(l.vertikaleausrichtung, s.vertikaleausrichtung)
		WHEN 'oben' THEN 'L'
		WHEN 'Basis' THEN 'U'
		ELSE 'C'
		END ||
		CASE COALESCE(l.horizontaleausrichtung, s.horizontaleausrichtung)
		WHEN 'linksbündig' THEN 'L'
		WHEN 'rechtsbündig' THEN 'R'
		ELSE 'C'
	END AS position_umn,
	drehwinkel_grad,
	point AS geom
INTO po_labels_bgd
FROM po_labels l
JOIN alkis_schriften s ON s.signaturnummer = l.signaturnummer
AND s.katalog = 1
JOIN alkis_farben f ON s.farbe = f.id
WHERE thema = 'Gebäude'
AND modell && ARRAY['DLKM','DKKM1000']::varchar[]
AND (layer IN ('ax_gebaeude_dachform', 'ax_bauteil_dachform'))
AND point IS NOT NULL;

--Gebäude / Funktion bgf
SELECT
	ogc_fid,
	gml_id,
	TEXT,
	f.umn AS color_umn,
	lower(art) || COALESCE('-' || effekt, '')
		|| CASE
		WHEN stil = 'Kursiv' THEN '-italic'
		WHEN stil = 'Fett' THEN '-bold'
		WHEN stil = 'Fett, Kursiv' THEN '-bold-italic'
		ELSE ''
		END ||
		CASE
		WHEN COALESCE(fontsperrung, 0)= 0 THEN ''
		ELSE '-' ||(fontsperrung / 0.25)::int
	END AS font_umn,
	0.25 / 0.0254 * skalierung * grad_pt AS size_umn,
		CASE COALESCE(l.vertikaleausrichtung, s.vertikaleausrichtung)
		WHEN 'oben' THEN 'L'
		WHEN 'Basis' THEN 'U'
		ELSE 'C'
		END ||
		CASE COALESCE(l.horizontaleausrichtung, s.horizontaleausrichtung)
		WHEN 'linksbündig' THEN 'L'
		WHEN 'rechtsbündig' THEN 'R'
		ELSE 'C'
	END AS position_umn,
	drehwinkel_grad,
	point AS geom
INTO po_labels_bgf
FROM po_labels l
JOIN alkis_schriften s ON s.signaturnummer = l.signaturnummer
AND s.katalog = 1
JOIN alkis_farben f ON s.farbe = f.id
WHERE thema = 'Gebäude'
AND modell && ARRAY['DLKM','DKKM1000']::varchar[]
AND (layer IN ('ax_gebaeude_funktion', 'ax_bauteil_funktion', 'ax_turm_funktion'))
AND point IS NOT NULL;

--Gebäude / Geschosse bgg
SELECT
	ogc_fid,
	gml_id,
	TEXT,
	f.umn AS color_umn,
	lower(art) || COALESCE('-' || effekt, '')
		|| CASE
		WHEN stil = 'Kursiv' THEN '-italic'
		WHEN stil = 'Fett' THEN '-bold'
		WHEN stil = 'Fett, Kursiv' THEN '-bold-italic'
		ELSE ''
		END ||
		CASE
		WHEN COALESCE(fontsperrung, 0)= 0 THEN ''
		ELSE '-' ||(fontsperrung / 0.25)::int
	END AS font_umn,
	0.25 / 0.0254 * skalierung * grad_pt AS size_umn,
		CASE COALESCE(l.vertikaleausrichtung, s.vertikaleausrichtung)
		WHEN 'oben' THEN 'L'
		WHEN 'Basis' THEN 'U'
		ELSE 'C'
		END ||
		CASE COALESCE(l.horizontaleausrichtung, s.horizontaleausrichtung)
		WHEN 'linksbündig' THEN 'L'
		WHEN 'rechtsbündig' THEN 'R'
		ELSE 'C'
	END AS position_umn,
	drehwinkel_grad,
	point AS geom
INTO po_labels_bgg
FROM po_labels l
JOIN alkis_schriften s ON s.signaturnummer = l.signaturnummer
AND s.katalog = 1
JOIN alkis_farben f ON s.farbe = f.id
WHERE thema = 'Gebäude'
AND modell && ARRAY['DLKM','DKKM1000']::varchar[]
AND (layer IN ('ax_gebaeude_geschosse', 'ax_bauteil_geschosse'))
AND point IS NOT NULL;

--Gebäude / Zustand bgz
SELECT
	ogc_fid,
	gml_id,
	TEXT,
	f.umn AS color_umn,
	lower(art) || COALESCE('-' || effekt, '')
		|| CASE
		WHEN stil = 'Kursiv' THEN '-italic'
		WHEN stil = 'Fett' THEN '-bold'
		WHEN stil = 'Fett, Kursiv' THEN '-bold-italic'
		ELSE ''
		END ||
		CASE
		WHEN COALESCE(fontsperrung, 0)= 0 THEN ''
		ELSE '-' ||(fontsperrung / 0.25)::int
	END AS font_umn,
	0.25 / 0.0254 * skalierung * grad_pt AS size_umn,
		CASE COALESCE(l.vertikaleausrichtung, s.vertikaleausrichtung)
		WHEN 'oben' THEN 'L'
		WHEN 'Basis' THEN 'U'
		ELSE 'C'
		END ||
		CASE COALESCE(l.horizontaleausrichtung, s.horizontaleausrichtung)
		WHEN 'linksbündig' THEN 'L'
		WHEN 'rechtsbündig' THEN 'R'
		ELSE 'C'
	END AS position_umn,
	drehwinkel_grad,
	point AS geom
INTO po_labels_bgz
FROM po_labels l
JOIN alkis_schriften s ON s.signaturnummer = l.signaturnummer
AND s.katalog = 1
JOIN alkis_farben f ON s.farbe = f.id
WHERE thema = 'Gebäude'
AND modell && ARRAY['DLKM','DKKM1000']::varchar[]
AND (layer = 'ax_gebaeude_zustand')
AND point IS NOT NULL;

--Rechtliche Festlegungen / Beschriftungen br
SELECT
	ogc_fid,
	gml_id,
	TEXT,
	f.umn AS color_umn,
	lower(art) || COALESCE('-' || effekt, '')
		|| CASE
		WHEN stil = 'Kursiv' THEN '-italic'
		WHEN stil = 'Fett' THEN '-bold'
		WHEN stil = 'Fett, Kursiv' THEN '-bold-italic'
		ELSE ''
		END ||
		CASE
		WHEN COALESCE(fontsperrung, 0)= 0 THEN ''
		ELSE '-' ||(fontsperrung / 0.25)::int
	END AS font_umn,
	0.25 / 0.0254 * skalierung * grad_pt AS size_umn,
		CASE COALESCE(l.vertikaleausrichtung, s.vertikaleausrichtung)
		WHEN 'oben' THEN 'L'
		WHEN 'Basis' THEN 'U'
		ELSE 'C'
		END ||
		CASE COALESCE(l.horizontaleausrichtung, s.horizontaleausrichtung)
		WHEN 'linksbündig' THEN 'L'
		WHEN 'rechtsbündig' THEN 'R'
		ELSE 'C'
	END AS position_umn,
	drehwinkel_grad,
	point AS geom
INTO po_labels_br
FROM po_labels l
JOIN alkis_schriften s ON s.signaturnummer = l.signaturnummer
AND s.katalog = 1
JOIN alkis_farben f ON s.farbe = f.id
WHERE thema = 'Rechtliche Festlegungen'
AND modell && ARRAY['DLKM','DKKM1000']::varchar[]
AND point IS NOT NULL;

--Bewertung / Beschriftungen bn
SELECT
	ogc_fid,
	gml_id,
	TEXT,
	f.umn AS color_umn,
	lower(art) || COALESCE('-' || effekt, '')
		|| CASE
		WHEN stil = 'Kursiv' THEN '-italic'
		WHEN stil = 'Fett' THEN '-bold'
		WHEN stil = 'Fett, Kursiv' THEN '-bold-italic'
		ELSE ''
		END ||
		CASE
		WHEN COALESCE(fontsperrung, 0)= 0 THEN ''
		ELSE '-' ||(fontsperrung / 0.25)::int
	END AS font_umn,
	0.25 / 0.0254 * skalierung * grad_pt AS size_umn,
		CASE COALESCE(l.vertikaleausrichtung, s.vertikaleausrichtung)
		WHEN 'oben' THEN 'L'
		WHEN 'Basis' THEN 'U'
		ELSE 'C'
		END ||
		CASE COALESCE(l.horizontaleausrichtung, s.horizontaleausrichtung)
		WHEN 'linksbündig' THEN 'L'
		WHEN 'rechtsbündig' THEN 'R'
		ELSE 'C'
	END AS position_umn,
	drehwinkel_grad,
	point AS geom
INTO po_labels_bn
FROM po_labels l
JOIN alkis_schriften s ON s.signaturnummer = l.signaturnummer
AND s.katalog = 1
JOIN alkis_farben f ON s.farbe = f.id
WHERE thema = 'Bewertung'
AND modell && ARRAY['DLKM','DKKM1000']::varchar[]
AND point IS NOT NULL;

--Lagebezeichnungen / Beschriftungen bl
SELECT
	ogc_fid,
	gml_id,
	TEXT,
	f.umn AS color_umn,
	lower(art) || COALESCE('-' || effekt, '')
		|| CASE
		WHEN stil = 'Kursiv' THEN '-italic'
		WHEN stil = 'Fett' THEN '-bold'
		WHEN stil = 'Fett, Kursiv' THEN '-bold-italic'
		ELSE ''
		END ||
		CASE
		WHEN COALESCE(fontsperrung, 0)= 0 THEN ''
		ELSE '-' ||(fontsperrung / 0.25)::int
	END AS font_umn,
	0.25 / 0.0254 * skalierung * grad_pt AS size_umn,
		CASE COALESCE(l.vertikaleausrichtung, s.vertikaleausrichtung)
		WHEN 'oben' THEN 'L'
		WHEN 'Basis' THEN 'U'
		ELSE 'C'
		END ||
		CASE COALESCE(l.horizontaleausrichtung, s.horizontaleausrichtung)
		WHEN 'linksbündig' THEN 'R'
		WHEN 'rechtsbündig' THEN 'L'
		ELSE 'C'
	END AS position_umn,
	drehwinkel_grad,
	point AS geom
INTO po_labels_bl
FROM po_labels l
JOIN alkis_schriften s ON s.signaturnummer = l.signaturnummer
AND s.katalog = 1
JOIN alkis_farben f ON s.farbe = f.id
WHERE thema = 'Lagebezeichnungen'
AND modell && ARRAY['DLKM','DKKM1000']::varchar[]
AND NOT point IS NULL;

--Lagebezeichnungen / Beschriftungen (Linien) bll
SELECT
	ogc_fid,
	gml_id,
	TEXT,
	f.umn AS color_umn,
	lower(art) || COALESCE('-' || effekt, '')
		|| CASE
		WHEN stil = 'Kursiv' THEN '-italic'
		WHEN stil = 'Fett' THEN '-bold'
		WHEN stil = 'Fett, Kursiv' THEN '-bold-italic'
		ELSE ''
		END ||
		CASE
		WHEN COALESCE(fontsperrung, 0)= 0 THEN ''
		ELSE '-' ||(fontsperrung / 0.25)::int
	END AS font_umn,
	0.25 / 0.0254 * skalierung * grad_pt AS size_umn,
	st_offsetcurve(line, 0.125 * skalierung * grad_pt, '') AS geom
INTO po_labels_bll
FROM po_labels l
JOIN alkis_schriften s ON s.signaturnummer = l.signaturnummer
AND s.katalog = 1
JOIN alkis_farben f ON s.farbe = f.id
WHERE thema = 'Lagebezeichnungen'
AND modell && ARRAY['DLKM','DKKM1000']::varchar[]
AND line IS NOT NULL;

--Flurstücke / Nummern / Beschriftungen bfn
SELECT
	ogc_fid,
	gml_id,
	TEXT,
	f.umn AS color_umn,
	lower(art) || COALESCE('-' || effekt, '')
		|| CASE
		WHEN stil = 'Kursiv' THEN '-italic'
		WHEN stil = 'Fett' THEN '-bold'
		WHEN stil = 'Fett, Kursiv' THEN '-bold-italic'
		ELSE ''
		END ||
		CASE
		WHEN COALESCE(fontsperrung, 0)= 0 THEN ''
		ELSE '-' ||(fontsperrung / 0.25)::int
	END AS font_umn,
	0.25 / 0.0254 * skalierung * grad_pt AS size_umn,
		CASE COALESCE(l.vertikaleausrichtung, s.vertikaleausrichtung)
		WHEN 'oben' THEN 'L'
		WHEN 'Basis' THEN 'U'
		ELSE 'C'
	END || 'C' AS position_umn,
	drehwinkel_grad,
	point AS geom
INTO po_labels_bfn
FROM po_labels l
JOIN alkis_schriften s ON s.signaturnummer = l.signaturnummer
AND s.katalog = 1
JOIN alkis_farben f ON s.farbe = f.id
WHERE thema = 'Flurstücke'
AND modell && ARRAY['DLKM','DKKM1000']::varchar[]
AND (layer IN ('ax_flurstueck_nummer', 'ax_flurstueck_zuordnung', 'ax_flurstueck_zuordnung_pfeil', 'ax_flurstueck_nummer_rpnoart'))
AND point IS NOT NULL;


-- INDEX auf Geometrie --
CREATE INDEX po_labels_bt_geom ON po_labels_bt USING gist (geom) TABLESPACE pgdata;
CREATE INDEX po_labels_bh_geom ON po_labels_bh USING gist (geom) TABLESPACE pgdata;
CREATE INDEX po_labels_bb_geom ON po_labels_bb USING gist (geom) TABLESPACE pgdata;
CREATE INDEX po_labels_be_geom ON po_labels_be USING gist (geom) TABLESPACE pgdata;
CREATE INDEX po_labels_bs_geom ON po_labels_bs USING gist (geom) TABLESPACE pgdata;
CREATE INDEX po_labels_bw_geom ON po_labels_bw USING gist (geom) TABLESPACE pgdata;
CREATE INDEX po_labels_bwl_geom ON po_labels_bwl USING gist (geom) TABLESPACE pgdata;
CREATE INDEX po_labels_bi_geom ON po_labels_bi USING gist (geom) TABLESPACE pgdata;
CREATE INDEX po_labels_bv_geom ON po_labels_bv USING gist (geom) TABLESPACE pgdata;
CREATE INDEX po_labels_bgh_geom ON po_labels_bgh USING gist (geom) TABLESPACE pgdata;
CREATE INDEX po_labels_bgn_geom ON po_labels_bgn USING gist (geom) TABLESPACE pgdata;
CREATE INDEX po_labels_bgd_geom ON po_labels_bgd USING gist (geom) TABLESPACE pgdata;
CREATE INDEX po_labels_bgf_geom ON po_labels_bgf USING gist (geom) TABLESPACE pgdata;
CREATE INDEX po_labels_bgg_geom ON po_labels_bgg USING gist (geom) TABLESPACE pgdata;
CREATE INDEX po_labels_bgz_geom ON po_labels_bgz USING gist (geom) TABLESPACE pgdata;
CREATE INDEX po_labels_bn_geom ON po_labels_bn USING gist (geom) TABLESPACE pgdata;
CREATE INDEX po_labels_br_geom ON po_labels_br USING gist (geom) TABLESPACE pgdata;
CREATE INDEX po_labels_bl_geom ON po_labels_bl USING gist (geom) TABLESPACE pgdata;
CREATE INDEX po_labels_bll_geom ON po_labels_bll USING gist (geom) TABLESPACE pgdata;
CREATE INDEX po_labels_bfn_geom ON po_labels_bfn USING gist (geom) TABLESPACE pgdata;

-- CONSTRAINS --
ALTER TABLE po_labels_bt ADD CONSTRAINT po_labels_bt_pk PRIMARY KEY (ogc_fid);
ALTER TABLE po_labels_bt ADD CONSTRAINT enforce_dims_po_labels_bt_geom CHECK (st_ndims(geom) = 2);
ALTER TABLE po_labels_bt ADD CONSTRAINT enforce_srid_po_labels_bt_geom CHECK (st_srid(geom) = 25832);
ALTER TABLE po_labels_bh ADD CONSTRAINT po_labels_bh_pk PRIMARY KEY (ogc_fid);
ALTER TABLE po_labels_bh ADD CONSTRAINT enforce_dims_po_labels_bh_geom CHECK (st_ndims(geom) = 2);
ALTER TABLE po_labels_bh ADD CONSTRAINT enforce_srid_po_labels_bh_geom CHECK (st_srid(geom) = 25832);
ALTER TABLE po_labels_bb ADD CONSTRAINT po_labels_bb_pk PRIMARY KEY (ogc_fid);
ALTER TABLE po_labels_bb ADD CONSTRAINT enforce_dims_po_labels_bb_geom CHECK (st_ndims(geom) = 2);
ALTER TABLE po_labels_bb ADD CONSTRAINT enforce_srid_po_labels_bb_geom CHECK (st_srid(geom) = 25832);
ALTER TABLE po_labels_be ADD CONSTRAINT po_labels_be_pk PRIMARY KEY (ogc_fid);
ALTER TABLE po_labels_be ADD CONSTRAINT enforce_dims_po_labels_be_geom CHECK (st_ndims(geom) = 2);
ALTER TABLE po_labels_be ADD CONSTRAINT enforce_srid_po_labels_be_geom CHECK (st_srid(geom) = 25832);
ALTER TABLE po_labels_bs ADD CONSTRAINT po_labels_bs_pk PRIMARY KEY (ogc_fid);
ALTER TABLE po_labels_bs ADD CONSTRAINT enforce_dims_po_labels_bs_geom CHECK (st_ndims(geom) = 2);
ALTER TABLE po_labels_bs ADD CONSTRAINT enforce_srid_po_labels_bs_geom CHECK (st_srid(geom) = 25832);
ALTER TABLE po_labels_bw ADD CONSTRAINT po_labels_bw_pk PRIMARY KEY (ogc_fid);
ALTER TABLE po_labels_bw ADD CONSTRAINT enforce_dims_po_labels_bw_geom CHECK (st_ndims(geom) = 2);
ALTER TABLE po_labels_bw ADD CONSTRAINT enforce_srid_po_labels_bw_geom CHECK (st_srid(geom) = 25832);
ALTER TABLE po_labels_bwl ADD CONSTRAINT po_labels_bwl_pk PRIMARY KEY (ogc_fid);
ALTER TABLE po_labels_bwl ADD CONSTRAINT enforce_dims_po_labels_bwl_geom CHECK (st_ndims(geom) = 2);
ALTER TABLE po_labels_bwl ADD CONSTRAINT enforce_srid_po_labels_bwl_geom CHECK (st_srid(geom) = 25832);
ALTER TABLE po_labels_bi ADD CONSTRAINT po_labels_bi_pk PRIMARY KEY (ogc_fid);
ALTER TABLE po_labels_bi ADD CONSTRAINT enforce_dims_po_labels_bi_geom CHECK (st_ndims(geom) = 2);
ALTER TABLE po_labels_bi ADD CONSTRAINT enforce_srid_po_labels_bi_geom CHECK (st_srid(geom) = 25832);
ALTER TABLE po_labels_bv ADD CONSTRAINT po_labels_bv_pk PRIMARY KEY (ogc_fid);
ALTER TABLE po_labels_bv ADD CONSTRAINT enforce_dims_po_labels_bv_geom CHECK (st_ndims(geom) = 2);
ALTER TABLE po_labels_bv ADD CONSTRAINT enforce_srid_po_labels_bv_geom CHECK (st_srid(geom) = 25832);
ALTER TABLE po_labels_bn ADD CONSTRAINT po_labels_bn_pk PRIMARY KEY (ogc_fid);
ALTER TABLE po_labels_bn ADD CONSTRAINT enforce_dims_po_labels_bn_geom CHECK (st_ndims(geom) = 2);
ALTER TABLE po_labels_bn ADD CONSTRAINT enforce_srid_po_labels_bn_geom CHECK (st_srid(geom) = 25832);
ALTER TABLE po_labels_bgh ADD CONSTRAINT po_labels_bgh_pk PRIMARY KEY (ogc_fid);
ALTER TABLE po_labels_bgh ADD CONSTRAINT enforce_dims_po_labels_bgh_geom CHECK (st_ndims(geom) = 2);
ALTER TABLE po_labels_bgh ADD CONSTRAINT enforce_srid_po_labels_bgh_geom CHECK (st_srid(geom) = 25832);
ALTER TABLE po_labels_bgn ADD CONSTRAINT po_labels_bgn_pk PRIMARY KEY (ogc_fid);
ALTER TABLE po_labels_bgn ADD CONSTRAINT enforce_dims_geom CHECK (st_ndims(geom) = 2);
ALTER TABLE po_labels_bgn ADD CONSTRAINT enforce_srid_geom CHECK (st_srid(geom) = 25832);
ALTER TABLE po_labels_bgd ADD CONSTRAINT po_labels_bgd_pk PRIMARY KEY (ogc_fid);
ALTER TABLE po_labels_bgd ADD CONSTRAINT enforce_dims_po_labels_bgd_geom CHECK (st_ndims(geom) = 2);
ALTER TABLE po_labels_bgd ADD CONSTRAINT enforce_srid_po_labels_bgd_geom CHECK (st_srid(geom) = 25832);
ALTER TABLE po_labels_bgf ADD CONSTRAINT po_labels_bgf_pk PRIMARY KEY (ogc_fid);
ALTER TABLE po_labels_bgf ADD CONSTRAINT enforce_dims_po_labels_bgf_geom CHECK (st_ndims(geom) = 2);
ALTER TABLE po_labels_bgf ADD CONSTRAINT enforce_srid_po_labels_bgf_geom CHECK (st_srid(geom) = 25832);
ALTER TABLE po_labels_bgg ADD CONSTRAINT po_labels_bgg_pk PRIMARY KEY (ogc_fid);
ALTER TABLE po_labels_bgg ADD CONSTRAINT enforce_dims_po_labels_bgg_geom CHECK (st_ndims(geom) = 2);
ALTER TABLE po_labels_bgg ADD CONSTRAINT enforce_srid_po_labels_bgg_geom CHECK (st_srid(geom) = 25832);
ALTER TABLE po_labels_bgz ADD CONSTRAINT po_labels_bgz_pk PRIMARY KEY (ogc_fid);
ALTER TABLE po_labels_bgz ADD CONSTRAINT enforce_dims_po_labels_bgz_geom CHECK (st_ndims(geom) = 2);
ALTER TABLE po_labels_bgz ADD CONSTRAINT enforce_srid_po_labels_bgz_geom CHECK (st_srid(geom) = 25832);
ALTER TABLE po_labels_br ADD CONSTRAINT po_labels_br_pk PRIMARY KEY (ogc_fid);
ALTER TABLE po_labels_br ADD CONSTRAINT enforce_dims_po_labels_br_geom CHECK (st_ndims(geom) = 2);
ALTER TABLE po_labels_br ADD CONSTRAINT enforce_srid_po_labels_br_geom CHECK (st_srid(geom) = 25832);
ALTER TABLE po_labels_bl ADD CONSTRAINT po_labels_bl_pk PRIMARY KEY (ogc_fid);
ALTER TABLE po_labels_bl ADD CONSTRAINT enforce_dims_po_labels_bl_geom CHECK (st_ndims(geom) = 2);
ALTER TABLE po_labels_bl ADD CONSTRAINT enforce_srid_po_labels_bl_geom CHECK (st_srid(geom) = 25832);
ALTER TABLE po_labels_bll ADD CONSTRAINT po_labels_bll_pk PRIMARY KEY (ogc_fid);
ALTER TABLE po_labels_bll ADD CONSTRAINT enforce_dims_po_labels_bll_geom CHECK (st_ndims(geom) = 2);
ALTER TABLE po_labels_bll ADD CONSTRAINT enforce_srid_po_labels_bll_geom CHECK (st_srid(geom) = 25832);
ALTER TABLE po_labels_bfn ADD CONSTRAINT po_labels_bfn_pk PRIMARY KEY (ogc_fid);
ALTER TABLE po_labels_bfn ADD CONSTRAINT enforce_dims_po_labels_bfn_geom CHECK (st_ndims(geom) = 2);
ALTER TABLE po_labels_bfn ADD CONSTRAINT enforce_srid_po_labels_bfn_geom CHECK (st_srid(geom) = 25832);

-- INSERT into postgis.geometry_column --
INSERT INTO postgis.geometry_columns(f_table_catalog,f_table_schema, f_table_name, f_geometry_column,coord_dimension, srid, type)
VALUES ('','public', 'po_labels_bt', 'geom', 2, 25832, 'POINT');
INSERT INTO postgis.geometry_columns(f_table_catalog,f_table_schema, f_table_name, f_geometry_column,coord_dimension, srid, type)
VALUES ('','public', 'po_labels_bh', 'geom', 2, 25832, 'POINT');
INSERT INTO postgis.geometry_columns(f_table_catalog,f_table_schema, f_table_name, f_geometry_column,coord_dimension, srid, type)
VALUES ('','public', 'po_labels_bb', 'geom', 2, 25832, 'POINT');
INSERT INTO postgis.geometry_columns(f_table_catalog,f_table_schema, f_table_name, f_geometry_column,coord_dimension, srid, type)
VALUES ('','public', 'po_labels_be', 'geom', 2, 25832, 'POINT');
INSERT INTO postgis.geometry_columns(f_table_catalog,f_table_schema, f_table_name, f_geometry_column,coord_dimension, srid, type)
VALUES ('','public', 'po_labels_bs', 'geom', 2, 25832, 'POINT');
INSERT INTO postgis.geometry_columns(f_table_catalog,f_table_schema, f_table_name, f_geometry_column,coord_dimension, srid, type)
VALUES ('','public', 'po_labels_bw', 'geom', 2, 25832, 'POINT');
INSERT INTO postgis.geometry_columns(f_table_catalog,f_table_schema, f_table_name, f_geometry_column,coord_dimension, srid, type)
VALUES ('','public', 'po_labels_bwl', 'geom', 2, 25832, 'LINESTRING');
INSERT INTO postgis.geometry_columns(f_table_catalog,f_table_schema, f_table_name, f_geometry_column,coord_dimension, srid, type)
VALUES ('','public', 'po_labels_bi', 'geom', 2, 25832, 'POINT');
INSERT INTO postgis.geometry_columns(f_table_catalog,f_table_schema, f_table_name, f_geometry_column,coord_dimension, srid, type)
VALUES ('','public', 'po_labels_bv', 'geom', 2, 25832, 'POINT');
INSERT INTO postgis.geometry_columns(f_table_catalog,f_table_schema, f_table_name, f_geometry_column,coord_dimension, srid, type)
VALUES ('','public', 'po_labels_bn', 'geom', 2, 25832, 'POINT');
INSERT INTO postgis.geometry_columns(f_table_catalog,f_table_schema, f_table_name, f_geometry_column,coord_dimension, srid, type)
VALUES ('','public', 'po_labels_bgh', 'geom', 2, 25832, 'POINT');
INSERT INTO postgis.geometry_columns(f_table_catalog,f_table_schema, f_table_name, f_geometry_column,coord_dimension, srid, type)
VALUES ('','public', 'po_labels_bgn', 'geom', 2, 25832, 'POINT');
INSERT INTO postgis.geometry_columns(f_table_catalog,f_table_schema, f_table_name, f_geometry_column,coord_dimension, srid, type)
VALUES ('','public', 'po_labels_bgd', 'geom', 2, 25832, 'POINT');
INSERT INTO postgis.geometry_columns(f_table_catalog,f_table_schema, f_table_name, f_geometry_column,coord_dimension, srid, type)
VALUES ('','public', 'po_labels_bgf', 'geom', 2, 25832, 'POINT');
INSERT INTO postgis.geometry_columns(f_table_catalog,f_table_schema, f_table_name, f_geometry_column,coord_dimension, srid, type)
VALUES ('','public', 'po_labels_bgg', 'geom', 2, 25832, 'POINT');
INSERT INTO postgis.geometry_columns(f_table_catalog,f_table_schema, f_table_name, f_geometry_column,coord_dimension, srid, type)
VALUES ('','public', 'po_labels_bgz', 'geom', 2, 25832, 'POINT');
INSERT INTO postgis.geometry_columns(f_table_catalog,f_table_schema, f_table_name, f_geometry_column,coord_dimension, srid, type)
VALUES ('','public', 'po_labels_br', 'geom', 2, 25832, 'POINT');
INSERT INTO postgis.geometry_columns(f_table_catalog,f_table_schema, f_table_name, f_geometry_column,coord_dimension, srid, type)
VALUES ('','public', 'po_labels_bl', 'geom', 2, 25832, 'POINT');
INSERT INTO postgis.geometry_columns(f_table_catalog,f_table_schema, f_table_name, f_geometry_column,coord_dimension, srid, type)
VALUES ('','public', 'po_labels_bll', 'geom', 2, 25832, 'LINESTRING');
INSERT INTO postgis.geometry_columns(f_table_catalog,f_table_schema, f_table_name, f_geometry_column,coord_dimension, srid, type)
VALUES ('','public', 'po_labels_bfn', 'geom', 2, 25832, 'POINT');