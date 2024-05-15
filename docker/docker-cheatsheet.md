# Docker

## Installation

```sh
$ pacman -S docker # Arch
```

La ejecución de docker requiere del módulo `loop`. La instalación debería cargar el módulo...

```sh
$ lsmod | grep loop # Verifica que se carga el módulo
```

De lo contrario ejecutar

```sh
$ tee /etc/modules-load.d/loop.conf <<< "loop"
$ modprobe loop
```

```sh
$ systemctl start/status/restart/stop docker.service
$ systemctl enable docker.service
$ systemctl disable docker.service

$ docker info
$ docker system info
$ docker system df
```

Docker solo se ejecuta con root. Para iniciar con otro usuario

```sh
$ cat /etc/group | grep docker
$ groupadd docker
$ sudo usermod -aG docker <user>
$ gpasswd -a <user> docker
```

Las imágenes/contenedores docker por defecto se encuentran en (algo parecido a) /var/lib/docker. Para cambiar el directorio

[guía 1](https://success.docker.com/article/using-systemd-to-control-the-docker-daemon)
[guía 2](https://github.com/IronicBadger/til/blob/master/docker/change-docker-root.md)

```sh
$ systemctl stop docker.service # Necesario antes de cualquier cambio
$ sudo systemctl cat docker | grep ExecStart
$ sudo systemctl edit docker
```

Esto crea el directorio `etc/systemd/system/docker.service.d/(docker-storage.conf)?` y abrirá un editor. Debemos poner lo siguiente... y posteriormente guardar con el nombre por defecto (override.conf)

~~~
[Service]
ExecStart=
ExecStart=/usr/bin/dockerd --data-root=/path/to/new/location/docker -H fd://
# ExecStart=/usr/bin/docker daemon -g /new/path/docker -H fd://
~~~

Finalmente reiniciamos el daemon `$ systemctl restart docker`

A medida que se instalan nuevas imágenes docker se reducirá el espacio en disco. Para cambiar de disco/partición llevamos a cabo el mismo procedimiento `~/(docker.conf)?`

~~~
[Service]
ExecStart=
ExecStart=/usr/bin/dockerd --graph="/mnt/new_volume" --storage-driver=devicemapper
~~~

Nuevamente `$ systemctl restart docker` para aplicar cambios. Donde `devicemapper` es el driver que gestiona las imágenes/contenedores. Para saber el driver actual

```sh
$ docker info
$ docker info | grep -i storage
```

En caso de que nos de un error, deberemos editar el `override.conf` manualmente (el directorio estará creado). Posteriormente...

```sh
$ systemctl daemon-reload			# Solo si obtenemos error en override.conf
$ systemctl restart docker.service
$ ps aux | grep -i docker | grep -v grep	# Confirmamos que corre sobre el nuevo directorio
```

## Usage

```sh
$ docker version
$ docker -v
$ docker info
$ docker volume ls		    # Ver volúmenes del sistema
$ docker volume rm <volume>	# Elimina volumen
$ docker pull <image>		# Descarga imagen
$ docker search <image>		# Busca imagen docker
$ docker images			    # Imágenes disponibles
$ docker rmi <image>		# Borra imagen
$ docker images -f dangling=true	# Lista imágenes colgadas
$ docker images purge		# Borrar imagen colgada

$ docker run <image> <command>	  # Inicia una imagen
$ docker run -d --name <name> -p <host_port>:<container_port> <image>
-d levanta en segundo plano
-p mapea el puerto del host con el del contenedor

$ docker run <containerID>	    # Inicia un contenedor 
$ docker stop <containerID>	    # Parar un contenedor (ID)
$ docker container stop <name>	# Parar un contenedor (nombre)
$ docker rm <containerID>		# Elimina un contenedor
$ docker rm <name>
$ docker stop <ID> && docker rm -v <ID>
$ docker container rm -f $(docker container ls -a -q) 	# Elimina todos los contenedores

$ export CONTAINER_ID = $(docker container ls | grep <name> | awk '{print $1}')
$ docker container stop $CONTAINER_ID

$ docker ps			    # Lista contenedores en ejecución
$ docker ps -a			# Lista todos los contenedores
$ docker ps -f status=exited	# Lista contenedores parados
$ docker container ls		    # Lista contenedores en ejecución
$ docker container ls -a		# Lista todos los contenedores
$ docker stats			    # Para todos los contenedores
$ docker stats <cotainerID>	# Para uno o varios contenedores
$ docker stats --no-steam		# Snapshoot de estadísticas
$ docker stats --all		# Todos los contenedores, incluso parados
$ docker rename <name> <new_name>

$ docker commit -m <comment> -a <autor> <containerID> <image> # Guarda la configuración de un contenedor como nueva imagen

$ docker export <container> > <image>.tar	# Guardar contenedor en fichero
$ docker import <image>.tar <image>	# Importar contenedor/imagen desde fichero

$ docker save -o <image>.tar <image>	# Guardar imagen en un fichero
$ docker load < <image>.tar		# Cargar imagen desde fichero
```

A parte de `stats` tenemos *cAdvisor* (monitoring), *Prometheus* (monitoring and time series database), *Agentless System Crawler* (cloud monitoring)

**Red**

```sh
$ docker network ls
$ docker network inspect <network>				    # Inspecciona una red
$ docker network create --driver bridge <new_network>	   # Crea nueva red donde driver_name=bridge
$ docker network inspect <new_network>
$ docker run --network=<new_network> -itd <container_name> --name=<containerID> <image>	# Inicia una imagen conectada a la red 'new_bridge'

$ docker inspect <container_name> | grep -i addres	# Ver IP

$ docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' <container_name_or_id>  # Ver IP
```

**SSH**: descargar/instalar paquetes necesarios en el contenedor. Una idea mejor es crear un contenedor SSH-server y conectarlo al resto de contenedores. El único requisito es que tenga bash. Ejemplo:

```sh
$ docker run -d -p 2222:22 \
-v /var/run/docker.sock:/var/run/docker.sock \
-e CONTAINER=<my-container> -e AUTH_MECHANISM=noAuth \

$ ssh -p 2222 localhost

$ docker exec -it <my-container> bash # Ejecuta un comando en <my-container>
```

**Compartir datos Docker-Host**

```sh
$ mkdir ~/<path>
$ docker run -d -P --name <container-name> -v /home/<user>/<path>:/data <image>
$ docker attach <containerID> # Datos disponibles en host

$ docker cp <container-name>:/file/to/copy /path/to/copy # Copiar desde contenedor a host
$ docker cp /path/to/copy <container-name>:/file/to/copy # Copiar desde host a contenedor
```

**Dockerfile** 

Ejemplo:

```sh
$ mkdir /home/<user>/my-docker-file
$ cd ~/my-docker-file
$ vim DockerFile

FROM ubuntu:latest
MAINTAINER <my-name>
ENV http_proxy http://user:pass@proxy/
ENV https_proxy http://user:pass@proxy/
RUN apt-get update
RUN apt-get install apache2 -y
RUN echo "<h1>Apache with Docker</h1>" > /var/www/html/index.html
EXPOSE 80
ENTRYPOINT apache2ctl -D FOREGROUND

# FROM: imagen que tomamos como base/plantilla.
# MAINTENER: autor de la imagen.
# ENV: definimos una variable de entorno en la imagen base.
# RUN: ejecuta sobre la imagen base.
# COPY: copia dentro del contenedor
# EXPOSE: exponemos el puerto 80 para que sea mapeado por host anfitrión.
# ENTRYPOINT: que se ejecute dicha línea cada vez que se arranca el contenedor.

# Posteriormente construimos la imagen a partir del Dockerfile que se encuentra en la misma ruta:

$ docker build -t <name>/<image> . # El punto es importante
$ docker run -d --name <name> -p <host_port>:<container_port> <image>
```

## References

[Docker](https://docs.docker.com/engine/reference/run/)

[DockerHub](https://registry.hub.docker.com/)

[Limitar recursos](https://docs.docker.com/config/containers/resource_constraints/)
