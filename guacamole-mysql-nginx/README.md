# Guacamole

**Apache Guacamole** is a client (web application in HTML5) that offers remote access to servers from a web browser.

## Configuration

**Guacamole** needs a database to save users, connections, etc. A command is provided from the [official documentation](https://guacamole.apache.org/doc/gug/guacamole-docker.html) in order to create the file `initdb.sql`

- MySQL

`docker run --rm guacamole/guacamole /opt/guacamole/bin/initdb.sh --mysql > conf/initdb.sql`

- PostgreSQL

`docker run --rm guacamole/guacamole /opt/guacamole/bin/initdb.sh --postgres > conf/initdb.sql`

Then we can start Guacamole

`docker-compose up -d`

## Usage

Service available on `http://localhost` (port 80 if using nginx, 8080 else) with default credentials `guacadmin /// guacadmin`. On the User Tab/Settings/Connections we can add new connections.

### Test

We can test our ssh nor xrdp connections with the following commands

**ssh**

`docker-compose -f docker-compose.yml -f docker-compose-test-ssh.yml up -d`

We have to know the Guacamole container IP

`docker inspect test-ssh | grep -i ipaddress`

Then we can access with `ssh guacamole@<ContainerIP>` and password `changeme`. To configure access from Guacamole we must set the following options

- Connection

~~~
Name: test-ssh
Protocol: ssh
~~~

- Network

~~~
Hostname: <ContainerIP>
Port: 22
~~~

- Authentication

~~~
Username: guacamole
Password: changeme
~~~

**xrdp**

`docker-compose -f docker-compose.yml -f docker-compose-test-xrdp.yml up -d`

- Connection

~~~
Name: test-xrdp
Protocol: RDP
~~~

- Network

~~~
Hostname: <ContainerName>
Port: 3389
~~~

- Authentication

~~~
Username: guacamole
Password: changeme
~~~

## References

[Apache Guacamole](https://guacamole.apache.org/)

[Guacamole Docker](https://guacamole.apache.org/doc/gug/guacamole-docker.html)

[Guacamole DockerHub](https://hub.docker.com/r/guacamole/guacamole)