# TIBCO Spotfire Server

Deploy TIBCO Spotfire Server with PostgreSQL backend.

This version uses TSS:11.2.0 version as you can see on [Dockerfile](Dockerfile). This variable is very important because it defines the paths where following scripts ([assets](assets)) are going to run from.

## Requirements

- Download the corresponding `tss.rpm` and `Spotfire*.sdn` and put them into the assets folder.

## Usage

First you have to replace your environment variables. Services loads environment variables from [environment](environment). Then deploy your services with `$ docker-compose up -d`. Services avaiblable on `localhost:80`

- Build Docker image

The Spotfire Server configuration and setup requires at least 3GB in order to run properly. A production instance of Spotfire Server needs at least 8GB and more like 16-24GB, depending on usage.

```sh
$ docker build -m 3GB -t tss .
```

Following examples for running TIBCO Spotfire depending on backend database (modify according to your needs).

- Run Docker image with PostgreSQL backend

```sh
$ docker run -it -d -p 80:80 --env DB_DRIVER="org.postgresql.Driver" --env DB_URL="jdbc:postgresql://spotfire-psql:5432/spotfire_server" --env SERVERDB_USER="spotfire_user" --env SERVERDB_PASSWORD="spotfire_changeme" --env CONFIG_TOOL_PASSWORD="config_password" --env ADMIN_USER="spotfire_admin" --env ADMIN_PASSWORD="spotfire_changeme" --env SET_AUTO_TRUST=false -m 6GB --cpus=2 --name tss103_linux tsslinux103_env
```

- Run Docker image with SQL-Server backend

```sh
$ docker run -it -d -p 80:80 --env DB_DRIVER="com.microsoft.sqlserver.jdbc.SQLServerDriver" --env DB_URL="jdbc:sqlserver://machine:1433;DatabaseName=spotfire1039_docker" --env SERVERDB_USER="spotfire1039" --env SERVERDB_PASSWORD="spotfire1039" --env CONFIG_TOOL_PASSWORD="spotfire" --env ADMIN_USER="spotfire" --env ADMIN_PASSWORD="spotfire" --env SET_AUTO_TRUST=false -m 6GB --cpus=2 --name tss103_linux tsslinux103_env
```

### Kubernetes Deployment

Script [generate_k8s.sh](generate_k8s.sh) provided for creating k8s deployment. Files generated on [k8s](k8s) folder.

```sh
$ bash generate_k8s.sh
```

### Spotfire env variables

Example variables

```sh
DB_DRIVER="org.postgresql.Driver"
DB_URL="jdbc:postgresql://spotfire-psql:5432/spotfire_server"

SERVERDB_NAME=spotfire_server
SERVERDB_USER=spotfire_user
SERVERDB_PASSWORD=spotfire_changeme

ADMIN_USER=spotfire_admin
ADMIN_PASSWORD=spotfire_changeme
CONFIG_TOOL_PASSWORD=config_password
SET_AUTO_TRUST=true
```

### PostgreSQL env variables

Example variables

```sh
POSTGRES_USER=rootuser
POSTGRES_PASSWORD=changeme
POSTGRES_DB=rootdb

SERVERDB_NAME=spotfire_server
SERVERDB_USER=spotfire_user
SERVERDB_PASSWORD=spotfire_changeme

ACTIONDB_NAME=spotfire_actionlog
ACTIONDB_USER=spotfire_actionlog
ACTIONDB_PASSWORD=log_changeme
```

## References

[TIBCO Spotfire](https://www.tibco.com/es/products/tibco-spotfire)

[TIBCO Spotfire Server Docker Scripts](https://community.tibco.com/wiki/tibco-spotfirer-server-docker-scripts)

[Github TIBCO Spotfire Server Docker](https://github.com/TIBCOSoftware/SpotfireDockerScripts)

[Setting up the Spotfire database (PostgreSQL)](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/setting_up_the_spotfire_database_(postgresql).html)

[Database drivers and database connection URLs](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/database_drivers_and_database_connection_urls.html)
