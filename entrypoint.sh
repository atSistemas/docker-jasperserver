#!/bin/bash
set -e

if [ ! -d "$CATALINA_HOME/webapps/jasperserver" ]; then
  if [ ! -e /jasperserver-war/jasperserver.zip ]; then # If you pass your own jasperserver zip
    wget "http://downloads.sourceforge.net/project/jasperserver/JasperServer/JasperReports%20Server%20Community%20Edition%20$JASPERSERVER_VERSION/jasperreports-server-cp-$JASPERSERVER_VERSION-bin.zip" -O /jasperserver-war/jasperserver.zip
  fi
  unzip /jasperserver-war/jasperserver.zip -d /usr/src/
  mv /usr/src/jasperreports-server-cp-*-bin /usr/src/jasperreports-server
  rm -r /usr/src/jasperreports-server/samples
fi

# wait upto 30 seconds for the database to start before connecting
#/wait-for-it.sh $DB_HOST:$DB_PORT -t 30

# check if we need to bootstrap the JasperServer
if [ ! -d "$CATALINA_HOME/webapps/jasperserver" ]; then
    pushd /usr/src/jasperreports-server/buildomatic

    # only works for Postgres or MySQL
    if [ -e "/jasperserver-conf/default_master.properties" ]; then
      cp /jasperserver-conf/default_master.properties default_master.properties
    else
      cp sample_conf/${DB_TYPE}_master.properties default_master.properties
      sed -i -e "s|^appServerDir.*$|appServerDir = $CATALINA_HOME|g; s|^dbHost.*$|dbHost=$DB_HOST|g; s|^dbPort.*$|dbPort=$DB_PORT|g; s|^dbUsername.*$|dbUsername=$DB_USER|g; s|^dbPassword.*$|dbPassword=$DB_PASSWORD|g" default_master.properties
    fi

    # run the minimum bootstrap script to initial the JasperServer
    ./js-ant create-js-db || true #create database and skip it if database already exists
    ./js-ant init-js-db-ce
    ./js-ant import-minimal-ce
    ./js-ant deploy-webapp-ce


    # import any export zip files from another JasperServer

    shopt -s nullglob # handle case if no zip files found

    IMPORT_FILES=/jasperserver-import/*.zip
    for f in $IMPORT_FILES
    do
      echo "Importing $f..."
      ./js-import.sh --input-zip $f
    done


    popd
fi

# run Tomcat to start JasperServer webapp
catalina.sh run
