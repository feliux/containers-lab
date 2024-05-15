# Cloudera

Despliegue **Cloudera** Docker.

- Requisitos mínimos

    - 8GB RAM versión *Express*
    - 10GB RAM versión *Enterprise*

### Descarga

Procedemos a descargar la imagen de Cloudera directamente desde sus repositorios

~~~
wget https://downloads.cloudera.com/demo_vm/docker/cloudera-quickstart-vm-5.13.0-0-beta-docker.tar.gz
tar xzf cloudera-quickstart-vm-*-docker.tar.gz
~~~

### Ejecución

Importamos la imagen docker

`docker import cloudera-quickstart-vm-5.13.0-0-beta-docker/cloudera-quickstart-vm-5.13.0-0-beta-docker.tar`

Mediante el comando `docker images` extraemos el identificador de la imagen para luego ponerle un **tag** como nombre

`docker tag <image_id> cloudera/quickstart:5.13.0`

Arrancamos nuestro contenedor mediante el comando `run`

`
docker run -d -it --name cloudera --hostname=quickstart.cloudera --privileged=true --publish-all=true -p 10002:10002 -p 55489:55489 -p 8888:8888 -p 10000:10000 -p 10020:10020 -p 11000:11000 -p 18080:18080 -p 18081:18081 -p 18088:18088 -p 19888:19888 -p 21000:21000 -p 21050:21050 -p 2181:2181 -p 25000:25000 -p 25010:25010 -p 25020:25020 -p 50010:50010 -p 50030:50030 -p 50060:50060 -p 50070:50070 -p 50075:50075 -p 50090:50090 -p 60000:60000 -p 60010:60010 -p 60020:60020 -p 60030:60030 -p 7180:7180 -p 7183:7183 -p 7187:7187 -p 80:80 -p 8020:8020 -p 8032:8032 -p 8042:8042 -p 8088:8088 -p 8983:8983 -p 9083:9083 -p 8889:8889 cloudera/quickstart:5.13.0 /usr/bin/docker-quickstart
`

Finalmente accedemos al contenedor

`docker exec -it cloudera bash`

### Configuración

La mayoría de los archivos de configuración se encuentran en `/etc/hadoop/conf`

~~~
core-site.xml     Configuración principal de hadoop.
hdfs-site.xml     Configuración HDFS (Namenode, Datanodes, etc).
mapred-site.xml   Almacena configuración para ejecutar los procesos Map&Reduce.
yarn-site.xml     Configuración de Yarn.
~~~

Para acceder a los distintos servicios debemos iniciar previamente **Cloudera Manager** (versión gratuita *Express*)

`sudo /home/cloudera/cloudera-manager --express`

Si quisiéramos la versión *Enterprise* con 60 días free-trial debemos ejecutar

`sudo /home/cloudera/cloudera-manager --enterprise`

### Uso

- Comandos Docker

~~~
docker ps -a

docker start cloudera

docker stop cloudera

docker rm cloudera
docker rmi cloudera/quickstart:5.13.0
~~~

- Servicios. Para aquellos que requieren credenciales podemos acceder mediante `cloudera // cloudera` 

    - Cloudera Manager `localhost:7180`
    - HDFS `localhost:50070`
    - Yarn Jobs `localhost:8088`
    - ResourceManager - NodeManager `localhost:8042`
    - Hue `localhost:8888`
    - Solr `localhost:8983`

### Enlaces de interés

[Cloudera Docker](https://docs.cloudera.com/documentation/enterprise/5-13-x/topics/quickstart_docker_container.html)
