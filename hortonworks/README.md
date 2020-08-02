# Hortonworks

Despliegue **Hortonworks** Docker.

- Requisitos mínimos: 10GB RAM

### Ejecución

~~~
cd HDP-<version>
sh docker-deploy-<version>,sh
~~~

### Configuración

La mayoría de los archivos de configuración se encuentran en `/etc/hadoop/conf`

~~~
core-site.xml     Configuración principal de hadoop.
hdfs-site.xml     Configuración HDFS (Namenode, Datanodes, etc).
mapred-site.xml   Almacena configuración para ejecutar los procesos Map&Reduce.
yarn-site.xml     Configuración de Yarn.
capacity-scheduler.xml  Cononfiguración de colas y capacidades.
~~~

Directorio de logs

~~~
/var/log/hadoop/hdfs       Namenode y Datanode
/var/log/hadoop-yarn/yarn  ResourceManager y NodeManager
/var/log/hive
~~~

### Uso

- Comandos Docker

~~~
docker ps -a

docker start sandbox-hdp
docker start sandbox-proxy

docker stop sandbox-hdp
docker stop sandbox-proxy

docker rm sandbox-hdp
docker rm sandbox-proxy
docker rmi hortonworks/sandbox-hdp:{release}
~~~

- Servicios

    - Hortonworks `localhost:8888`
    - Ambari `localhost:8080` con credenciales `raj_ops // raj_ops`
    - HDFS `localhost:50070`
    - Ranger `localhost:6080` con credenciales `admin // admin`
    - Zeppelin `localhost:9995/#/`
    - Jobs `localhost:8088`

### Enlaces de interés

[Hortonworks Docker](https://www.cloudera.com/tutorials/sandbox-deployment-and-install-guide/3.html)
