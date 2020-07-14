# Guacamole

**Apache Guacamole** es un cliente (aplicación web HTML5) capaz de ofrecer funcionalidades para acceso remoto a servidores y otros equipos desde un navegador web.

### Ejecución

**Guacamole** necesita de una base de datos para guardar los datos de usuario, conexiones, etc. En la [guía oficial](https://guacamole.apache.org/doc/gug/guacamole-docker.html) proveen el siguiente comando para crear el fichero `initdb.sql` que guardamos en el directorio `conf`

- MySQL

`docker run --rm guacamole/guacamole /opt/guacamole/bin/initdb.sh --mysql > initdb.sql`

- PostgreSQL

`docker run --rm guacamole/guacamole /opt/guacamole/bin/initdb.sh --postgres > initdb.sql`

Posteriormente arrancamos los servicios con `docker-compose`

`docker-compose up -d`

### Uso

Accedemos a `http://localhost` con las credenciales por defecto `guacadmin // guacadmin`. En la pestaña de usuario -> Settings -> Connections podemos añadir nuevas conexiones.

#### Test

Podemos testear nuestros servicios accediendo mediante shh a un contenedor de prueba llamado **test-ssh**

`docker-compose -f docker-compose.yml -f docker-compose-test.yml up -d`

Para acceder a nuestro contenedor de prueba través de **Guacamole** tendremos que averiguar su IP

`docker inspect test-ssh | grep -i ipaddress`

Podemos acceder mediante `ssh guacamole@<IP_container>` con la contraseña `password`. Comprobada la IP configuramos la conexión en **Guacamole**.

- Connection

~~~
Name: test-ssh
Protocol: ssh
~~~

- Network

~~~
Hostname: <IP_container>
Port: 22
~~~

- Authentication

~~~
Username: guacamole
Password: password
~~~

#### Enlaces de interés

[Apache Guacamole](https://guacamole.apache.org/)

[Guacamole Docker](https://guacamole.apache.org/doc/gug/guacamole-docker.html)

[Guacamole DockerHub](https://hub.docker.com/r/guacamole/guacamole)
