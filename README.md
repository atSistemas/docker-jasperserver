# JasperReports Server CE Edition Docker Container

The Docker Image aims to quickly get up-and-running a JasperReports Server for a development environment.

## Start the Container

### Using Command Line

To start the JasperServer container you'll need to pass in 5 environment variables and link it to either a MySQL or Postgres container.

E.g. `docker run -d --name jasperserver -e DB_TYPE=mysql -e DB_HOST=db -e DB_PORT=3306 -e DB_USER=root -e DB_PASSWORD=mysql --link jasperserver_mysql:db -p 8080:8080 atsistemas/docker-jasperserver-master`

If you prefer to pass a specific configuration file just bind volume to `/jasperserver-conf` containing a file named `default_master.properties`. An example file can be found in the repository

E.g. `docker run -d --name jasperserver --link jasperserver_mysql:db -p 8080:8080 -v jasperconf:/jasperserver-conf atsistemas/docker-jasperserver-master`

If you haven't got an existing MySQL or Postgres container then you can easily create one:
`docker run -d --name jasperserver_mysql -e MYSQL_ROOT_PASSWORD=mysql mysql`

By default in runtime the image download a version of Jasper (JASPERSERVER_VERSION=6.3.0), If you want to use your own Jasper Server distro, download it and pass (mount) the location in

E.g. `docker run -d --name jasperserver -p 8080:8080 -v jasperwar:/jasperserver-war atsistemas/docker-jasperserver-master`

### Using Docker-compose

To start up the JasperServer and a MySQL container:

* Run `docker-compose up` to run in foreground or
* Run `docker-compose up -d` to run as in daemon mode.

To stop the containers run `docker-compose stop` and `docker-compose start` to restart them.

Note: To install Docker-compose see the [releases page](https://github.com/docker/compose/releases).


## Login to JasperReports Web

1. Go to URL http://${dockerHost}:8080/jasperserver/
2. Login using credentials: jasperadmin/jasperadmin

## Requirements
* If you want to use your own jasper artifact It's needed download the zip with the artifact of jasperserver in local directory. Please, renamed it to `jasperserver.zip`
* Example download URL for version 6.3.0: `https://sourceforge.net/projects/jasperserver/files/JasperServer/JasperReports%20Server%20Community%20Edition%206.3.0/jasperreports-server-cp-6.3.0-bin.zip/download `

## Image Features
This image includes:
* IBM DB2 JDBC driver version 4.19.26
* A volume called '/import' that allows automatic importing of export zip files from another JasperReports Server
* Waits for the database to start before connecting to it using [wait-for-it](https://github.com/vishnubob/wait-for-it) as recommended by [docker-compose documentation](https://docs.docker.com/compose/startup-order/).
