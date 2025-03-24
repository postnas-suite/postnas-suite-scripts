#!/bin/sh


datum=`date +%Y%m%d`

product=alkis

###############
# dekleration #
###############
dbport="5432"
dbuser="geo5import"

################
prefix="aaa_"
dbname=$prefix$product


#################
# delete tables #
#################

psql -c "DROP TABLE pt_umlegung;" -d $dbname -p $dbport -U $dbuser >> /dev/null

###################
# add more tables #
###################

# umlegung
pg_dump -U $dbuser -t umlegung umlegung | psql -U $dbuser $dbname

# hk (ZSHH Hauskoordinaten)
pg_dump -U $dbuser -t hk hk | psql -U $dbuser $dbname

# plz (Postleitzahlengebiete der Deutschen Post)
pg_dump -U $dbuser -t plz plz | psql -U $dbuser $dbname

# flstk_suche (Flurstückskoodinaten)
#pg_dump -U $dbuser -t flstk_suche flstk_suche | psql -U $dbuser $dbname
pg_restore -U $dbuser -d $dbname /daten/import/alkis/flstk_suche.dump

# gemeinde
pg_dump -U $dbuser verwaltungsgrenzen -t gemeinde_rlp | psql -U $dbuser $dbname


echo "Preprocessing"
echo "#########################################################################"
psql -f /home/geo5import/contrib/products/"$product"/alkisproducts/0_preprocessing.sql -p $dbport -d $dbname -U $dbuser >> /dev/null

echo "Erzeuge Flurstücks-WFS flstk_rp"
echo "#########################################################################"
psql -f /home/geo5import/contrib/products/"$product"/alkisproducts/1_axflstk_mod.sql -p $dbport -d $dbname -U $dbuser >> /dev/null

echo "Erzeuge örF-WFS oerf_rp"
echo "#########################################################################"
psql -f /home/geo5import/contrib/products/"$product"/alkisproducts/2_oerf_mod.sql -p $dbport -d $dbname -U $dbuser >> /dev/null

echo "Erzeuge Geocode-WFS geocode_rp"
echo "#########################################################################"
echo "Adresse zu Punkt "
echo "#########################################################################"
psql -f /home/geo5import/contrib/products/"$product"/alkisproducts/3_geocode_adrpunkt_mod.sql -p $dbport -d $dbname -U $dbuser >> /dev/null
echo "Adresse zu Flurstueck mit Geometrie "
echo "#########################################################################"
psql -f /home/geo5import/contrib/products/"$product"/alkisproducts/4_geocode_adrflstk_mod.sql -p $dbport -d $dbname -U $dbuser >> /dev/null
echo "Flurstueckskennzeichen zu Punkt "
echo "#########################################################################"
psql -f /home/geo5import/contrib/products/"$product"/alkisproducts/5_geocode_flstkkennzpunkt_mod.sql -p $dbport -d $dbname -U $dbuser >> /dev/null

echo "Erzeuge Flurstücksdiffenzen-WFS flstk_diff_rp"
echo "#########################################################################"
psql -f /home/geo5import/contrib/products/"$product"/alkisproducts/6_flstk_diff_mod.sql -p $dbport -d $dbname -U $dbuser >> /dev/null

echo "Erzeuge Flurstücksabschnittsverschneider-WFS fav_rp"
echo "#########################################################################"
psql -f /home/geo5import/contrib/products/"$product"/alkisproducts/7_fav_mod.sql -p $dbport -d $dbname -U $dbuser >> /dev/null

echo "Erzeuge Tatsächliche Nutzung-WFS tn_rp"
echo "#########################################################################"
psql -f /home/geo5import/contrib/products/"$product"/alkisproducts/8_tn_mod.sql -p $dbport -d $dbname -U $dbuser >> /dev/null
psql -f /home/geo5import/contrib/products/"$product"/alkisproducts/9_tn_nutzung_mod.sql -p $dbport -d $dbname -U $dbuser >> /dev/null

echo "Ergänze po_polygons für GetFeatureInfo"
echo "#########################################################################"
psql -f /home/geo5import/contrib/products/"$product"/alkisproducts/10_popolygons_mod.sql -p $dbport -d $dbname -U $dbuser >> /dev/null

echo "Erzeuge AdV-Gebaeude-WFS "
echo "#########################################################################"
psql -f /home/geo5import/contrib/products/"$product"/alkisproducts/11_gebaeude_mod.sql -p $dbport -d $dbname -U $dbuser >> /dev/null

echo "Erzeuge Hausumringe "
echo "#########################################################################"
psql -f /home/geo5import/contrib/products/"$product"/alkisproducts/12_hu_mod.sql -p $dbport -d $dbname -U $dbuser >> /dev/null

echo "Erzeuge ALKIS-Punkte "
echo "#########################################################################"
psql -f /home/geo5import/contrib/products/"$product"/alkisproducts/13_geocode_alkispunkt_mod.sql -p $dbport -d $dbname -U $dbuser >> /dev/null

echo "Erzeuge Umlegung "
echo "#########################################################################"
psql -f /home/geo5import/contrib/products/"$product"/alkisproducts/14_umlegung_mod.sql -p $dbport -d $dbname -U $dbuser >> /dev/null

echo "Erzeugen von einzelnen Beschriftungstabellen"
echo "#########################################################################"
psql -f /home/geo5import/contrib/products/"$product"/alkisproducts/98_beschriftungen.sql -p $dbport -d $dbname -U $dbuser >> /dev/null

echo "Postprocessing - Aufräumen"
echo "#########################################################################"
psql -f /home/geo5import/contrib/products/"$product"/alkisproducts/99_postprocessing.sql -p $dbport -d $dbname -U $dbuser >> /dev/null
