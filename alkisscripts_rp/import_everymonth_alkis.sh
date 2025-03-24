#!/bin/bash

#################################################################
#								#
# This script imports all xml files from first import           #
# of an ALKIS file into a postgres database                     #
#                                                               #
# Author: OS                                                    #
# Version: 2.0 - 22.08.2019                                     #
#								#
#################################################################

#############################
# Datum mit Argument füllen #
#############################

if [ ! -z $1 ]
then
   importDatum=$1
else
   importDatum=`date +%Y%m%d`
fi


################
# Definitionen #
################

dbname="aaa_alkis"
dbport="5432"
dbuser="geo5import"
dbpassword="Fe5+a%78"
dbtablespace="pgdata"
dbhost="localhost"
product_folder="/daten/import/alkis"
insert_folder="${product_folder}/${importDatum}"
deletedatum=`date +%Y%m%d --date="95 days ago"`

server=das.vermkv.rlp
serverUser=lvermgeo
serverPath=/data/Daten/Geo5-ALKIS/ausgang/

######################################################################################################################################
# Checkt ob Dateien auf DAS/Geo5 vorhanden sind und schreibt in Variable datei das Ergebnis (1 für vorhanden, 0 für nicht vorhanden) #
######################################################################################################################################
datei_das=$(ssh lvermgeo@das.vermkv.rlp "for f in /data/Daten/Geo5-ALKIS/ausgang/*.zip; do [ -e \"\$f\" ] && echo 1 || echo 0; break; done")
datei_geo5=$(for f in $insert_folder/*.zip; do [ -e "$f" ] && echo 1 || echo 0; break; done)
##datei_geo5=0
##datei_das=1

################################################################
#Checkt ob Dateien bereits kopiert und entpackt wurden, Abbruch#
################################################################
if [ $datei_geo5 -eq 1 ]; then
   echo -e "Es wurden Dateien in $insert_folder gefunden, daher kein erneutes Kopieren und Importieren. Fuer erneuten Import datei_geo5=0 setzen!" | mail -s "GEO5 - Importfehler: ALKIS" oliver.schmidt@vermkv.rlp.de patrick.noll@vermkv.rlp.de
fi

##########################################################
# Beginn der Verarbeitung, wenn Dateien auf DAS vorhanden#
##########################################################
if [ $datei_das -eq 1 ]; then
   echo -e "Es wurden Dateien in $serverPath gefunden, Kopieren und Importieren wird gestartet." | mail -s "GEO5 - Import: ALKIS" oliver.schmidt@vermkv.rlp.de patrick.noll@vermkv.rlp.de
   
if [ ! -d $insert_folder ]; then
  mkdir $insert_folder
fi

if [ -d "$insert_folder/log" ]; then
  rm -R $insert_folder/log
fi
mkdir $insert_folder/log


############################
# kopieren des Erstauszugs #
############################

echo "scp $serverUser@$server:$serverPath*.* $insert_folder"
scp $serverUser@$server:$serverPath*.* $insert_folder
ssh $serverUser@$server "rm -rf $serverPath*.*"

##########################################################################################
# Überprüfung der Datei-Integrität und Erstellen der importLST-Datei für norBIT-Importer #
##########################################################################################

cd $insert_folder

##checksum_dhk=$(sed -n 21p *.txt | cut -d" " -f13)
##checksum_geo5=$(sha512sum *.zip | cut -d" " -f1)

importLST=import_$importDatum.lst

##if [ "$checksum_dhk" == "$checksum_geo5" ]; then 
    unzip "*.zip"
    echo -e "PG:dbname=${dbname} user=${dbuser} password=xxx \nclean \ncreate \nlog import.log \noptions -skipfailures -gt 65000" > $insert_folder/$importLST
    ls $insert_folder/*.xml.gz >> $insert_folder/$importLST
##else
##    echo -e "Checksum-Pruefung war nicht erfolgreich." | mail -s "GEO5 - Importfehler: ALKIS" oliver.schmidt@vermkv.rlp.de 
##fi

##################
# Importoptionen #
##################

#cores=$(nproc --all)
#cores=7

# Umgebungsvariable setzen:
#export GML_FIELDTYPES=ALWAYS_STRINGS           # PostNAS behandelt Zahlen wie Strings, PostgreSQL-Treiber macht daraus Zahlen
#export OGR_SETFIELD_NUMERIC_WARNING=ON         # Meldung abgeschnittene Zahlen?

# Mindestlänge für Kreisbogensegmente
#export OGR_ARC_MINLENGTH=0.1

## Verhindern, das der GML-Treiber übernimmt ##
#export OGR_SKIP=GML,SEGY

# Headerkennungen die NAS-Daten identifizieren
#export NAS_INDICATOR="NAS-Operationen;AAA-Fachschema;aaa.xsd;aaa-suite"
#export NAS_GFS_TEMPLATE=$HOME/contrib/products/postnas/fischer/alkis-schema.gfs
#export NAS_NO_RELATION_LAYER=NO

## OGR ##
#export OGR="/opt/gdal/bin/ogr2ogr"
#export EPSG="-a_srs EPSG:25832"
#export DBUSER=$dbuser
#export DBNAME=$dbname


###########################
# DB-Verbindung schließen #
###########################

psql -c "SELECT pg_terminate_backend(pg_stat_activity.pid),pg_stat_activity.usename,pg_stat_activity.application_name,pg_stat_activity.client_addr,pg_stat_activity.client_hostname,pg_stat_activity.client_port  FROM pg_stat_activity WHERE pg_stat_activity.datname = '$dbname' AND pid <> pg_backend_pid();" -d $dbname -p $dbport -U $dbuser

psql -c "SELECT pg_terminate_backend(pg_stat_activity.pid),pg_stat_activity.usename,pg_stat_activity.application_name,pg_stat_activity.client_addr,pg_stat_activity.client_hostname,pg_stat_activity.client_port  FROM pg_stat_activity WHERE pg_stat_activity.datname = '$dbname' AND pid <> pg_backend_pid();" -d $dbname -p $dbport -U $dbuser


###################
# alte DB löschen #
###################

dropdb --if-exists -p $dbport $dbname -U $dbuser


################
# DB erstellen #
################

createdb -E UTF8 -T postgis_template -p $dbport $dbname -D $dbtablespace -U $dbuser
psql -c "ALTER DATABASE $dbname SET search_path TO public, postgis;" -d $dbname -p $dbport -U $dbuser


####################
# Start NAS-Import #
####################

errprot=./log/postnas_err_${DBNAME}.prot

cd /home/geo5import/contrib/products/alkis/alkisimport/
./alkis-import.sh $insert_folder/$importLST

#process_xml()
#{
#     #### Entpacken ####
#     gzdatei=$1
#     echo $gzdatei
#     gunzip -c $gzdatei > $gzdatei.xml
#     # OGR-Import #
#     $OGR -append -f "PostgreSQL" -skipfailures -gt 65000 -ds_transaction --config PG_USE_COPY YES -nlt CONVERT_TO_LINEAR \
#        PG:"dbname=$DBNAME user=$DBUSER" $EPSG ${gzdatei}.xml 
#     #### Dateien löschen ####
#     rm $gzdatei.xml
#     rm $gzdatei.gfs
#}

#export -f process_xml

###########################################################
## Entpacken von *xml.gz und OGR-Import in einem Abwasch ##
###########################################################

#parallel --jobs 7 process_xml ::: *.xml.gz 2>> $errprot
#parallel --jobs $cores process_xml ::: *.xml.gz 2>> $errprot


###############################################################################################
# Daten, die älter X-Tage sind, werden gelöscht, Prüfung erfolgt durch Datum des Ordnernamens #
###############################################################################################

rm $insert_folder/*.xml.gz

cd $product_folder
for datum_dir in `ls | egrep -o "[0-9]*" |sort -n`
do
        if [ $datum_dir -le $deletedatum ]
        then
                rm -R $product_folder/$datum_dir
        fi
done


##################################
## Start der Berechnung vom FAF ##
##################################

cd /home/geo5import/contrib/products/faf/
./create_faf.sh > /home/geo5import/contrib/products/faf/log/cronjob_create_faf.log 2>&1

########################################
## Start der Skripte in alkisproducts ##
########################################

cd /home/geo5import/contrib/products/alkis/
./modification_everymonth_alkis.sh > /home/geo5import/contrib/products/alkis/log/cronjob_modification_alkis.log 2>&1

###########################################################
## Ende der Verarbeitung, wenn Dateien auf DAS vorhanden ##
###########################################################

psql -c "COMMENT ON DATABASE $dbname IS 'IMPORT: "$importDatum"';" -d $dbname -p $dbport -U $dbuser
psql -c "VACUUM FULL" -d $dbname -p $dbport -U $dbuser

# Rechte zur DB BENUTZUNG
psql -c "GRANT USAGE ON SCHEMA public TO kommserv;" -d $dbname -p $dbport -U $dbuser >> /dev/null
psql -c "GRANT USAGE ON SCHEMA postgis TO kommserv;" -d $dbname -p $dbport -U $dbuser >> /dev/null
psql -c "GRANT SELECT ON ALL TABLES IN SCHEMA public TO kommserv;" -d $dbname -p $dbport -U $dbuser  >> /dev/null
psql -c "GRANT SELECT ON ALL TABLES IN SCHEMA postgis TO kommserv;" -d $dbname -p $dbport -U $dbuser  >> /dev/null
psql -c "GRANT SELECT ON ALL SEQUENCES IN SCHEMA public TO kommserv;" -d $dbname -p $dbport -U $dbuser  >> /dev/null
psql -c "GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA postgis TO kommserv;" -d $dbname -p $dbport -U $dbuser  >> /dev/null
psql -c "REVOKE SELECT ON ax_person, ax_personengruppe, ax_anschrift, ax_namensnummer, ax_buchungsblatt, ax_buchungsstelle FROM kommserv;" -d $dbname -p $dbport -U $dbuser  >> /dev/null


#########################################
## ready-Datei für geo5admin erstellen ##
#########################################
endDatum=`date +%Y%m%d`
echo -e "ALKIS-Import und Prozessierung abgeschlossen. Fertiggestellt am `date` " > /home/geo5admin/contrib/products/alkis/ready/ready_${endDatum}.txt
chmod 766 /home/geo5admin/contrib/products/alkis/ready/ready_${endDatum}.txt

#else
#echo -e "Es wurden weder Dateien in $serverPath noch in $insert_folder gefunden! Kopieren und Importieren wird nicht gestartet. Versuche es in einer Stunde noch einmal. Liebe Grüße, dein Geo5." | mail -s "GEO5 - Import: ALKIS" oliver.schmidt@vermkv.rlp.de 
fi
