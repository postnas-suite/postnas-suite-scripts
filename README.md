# PostNAS-Suite Skripte

Dieses Repository beinhaltet die Skripte und SQLs, die im Umgang mit AAA-Daten hilfreich sein können.

Fragen zu den Skripten und SQLs können an die PostNAS-Suite Mailing-Liste unter nas (at)lists.osgeo.org gestellt werden.

## ALKIS-Import und -Postprocessing (Rheinland-Pfalz)

### Anpassung des Postprocessings im norBIT ALKIS-Import

Im Ordner `alkisimport_rp/postprocessing.d` befinden sich auf die rheinland-pfälzischen Daten angepasste und erweiterte Postprocessing-Skripte. Es handelt sich um eine Modifikation der Skripte aus dem  Repository: https://github.com/norBIT/alkisimport/tree/gid7i 

Folgende bedeutende Änderungen wurden durchgeführt:

* Aufteilung des Skriptes `1_ableitungsregeln/11001.sql` (Thema Flurstücke) und 6 einzelne Skripte zur Ausnutzung der parallelen Verarbeitung.
* Erstellung der beiden Skripte `1_ableitungsregeln/71004.sql` (AX_AndereFestlegungNachWasserrecht) und `1_ableitungsregeln/71005.sql` (AX_SchutzgebietNachWasserrecht)
* Erstellung und Anpassung des Skriptes `7_bodenschaetzung.sql` an GID 7.1.2 und ALKIS-SK RP

### Eigene ALKIS-Postprocessing-Skripte

Im Ordner `alkisproducts_rp` befinden sich die folgenden Skripte, die für die Realisierung der jeweiligen rheinland-pfälzischen ALKIS-Dienste benötigt werden:

* `0_preprocessing.sql` bereitet die Daten für spätere Skripte vor
* `1_axflstk_mod.sql` erstellt eine Datenbanktabelle für die Flurstücke, die für den WFS "ALKIS vereinfacht" direkt nutzbar ist
* `2_oerf_mod.sql` bereitet AX_SchutzgebietNachWasserrecht für den WFS "Öffentlich-rechtliche und sonstige Festlegungen" auf
* `3_fav_mod.sql` erstellt Tabellen für den WFS "Flurstückabschnittsverschneider (FAV)"
* `4_tn_mod.sql` bereitet alle nötigen Objektarten für den WFS "Tatsächliche Nutzung Einzellayer" auf
* `5_tn_nutzung_mod.sql` sammelt alle Informationen in einer Datenbanktabelle für die tatsächliche Nutzung, die für den WFS "ALKIS vereinfacht" direkt nutzbar ist
* `6_popolygons_mod.sql` erweitert die Tabelle po_polygons um weitere Informationen für ein aussagekräftiges GetFeatureInfo des Layers "Flurstücke" des WMS "Liegenschaften RP"
* `7_gebaeude_mod.sql` sammelt alle Informationen in einer Datenbanktabelle für die Gebäude und Bauwerke, die für den WFS "ALKIS vereinfacht" direkt nutzbar ist 
* `8_hu_mod.sql` leitet aus der vorherigen Tabelle der Gebäude und Bauwerke eine Taeblle zur Abgabe an die ZSHH ab
* `9_alkispunkt_mod.sql` erstellt für alle ALKIS-Punktarten Datenbanktabellen, die für den WFS "ALKIS-Punkte" direkt nutzbar sind - **Work in progress!!!**
* `98_beschriftungen.sql` führt die nötigen Verschneidungen für die Beschriftungen der Liegenschaftskarte durch. Dies entlastet den MapServer bzw. die PostGIS-Datenbank erheblich, da keine Joins zur Laufzeit durchgeführt werden müssen
* `99_postprocessing.sql` räumt nicht mehr benötigte temporäre Tabellen auf

Skripte für lediglich intern genutzte Dienste werden hier nicht aufgeführt, da sie zahlreiche Verschneidungen mit internen Daten haben, die nicht Teil der ALKIS-Datenhaltung sind. Diese Verarbeitungsschritte können ohne diese Daten nicht reproduziert werden, wodurch eine Anwendung mit den OpenData-Daten nicht möglich wäre. 

### ALKIS-Steuerskripte für Import und Verarbeitung

**Folgt in Kürze**

## AFIS-Postprocessing (Rheinland-Pfalz)

**Folgt in Kürze**

## ATKIS BasisDLM-Import und -Postprocessing (Rheinland-Pfalz)

**Folgt in Kürze**


Lizenz: [GNU GPLv2](https://www.gnu.org/licenses/old-licenses/gpl-2.0.en.html)