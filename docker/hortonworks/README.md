# Hortonworks

Despliegue **Hortonworks** Docker.

- Requisitos mínimos: 10GB RAM
- Para ejecutar Hortonworks en Docker debemos descargar la imagen de la web Cloudera.

## Deploy

```sh
$ cd HDP-<version>
$ ssh docker-deploy-{HDPversion}.sh
```

El script de despliegue no se logra completar debido a que ejecuta el docker con privilegios (`--privileged`). En este punto cierra todas las ventanas y me expulsa de la sesión. Así pues, hay que seguir el script directamente en consola (o dividirlo en dos partes)...

```sh
$ docker exec -t sandbox-hdp sh -c "rm -rf /var/run/postgresql/*; systemctl restart postgresql;"
```

Y nos movemos al directorio del script para seguir ejecutando en consola. En este punto se produce el despliegue del docker sandbox-proxy, el cual gestiona todas las conexiones

```sh
$ cd /to/path/docker-deploy
$ sed 's/sandbox-hdp-security/sandbox-hdp/g' assets/generate-proxy-deploy-script.sh > assets/generate-proxy-deploy-script.sh.new
$ mv -f assets/generate-proxy-deploy-script.sh.new assets/generate-proxy-deploy-script.sh
$ chmod +x assets/generate-proxy-deploy-script.sh
$ assets/generate-proxy-deploy-script.sh 2>/dev/null
```

Hay un apartado que se puede obviar en sistemas linux ya que comprueba si es Windows (cuidado con el if)

```sh
if uname | grep MINGW; then
 sed -i -e 's/\( \/[a-z]\)/\U\1:/g' sandbox/proxy/proxy-deploy.sh
fi

$ chmod +x sandbox/proxy/proxy-deploy.sh 2>/dev/null
$ sandbox/proxy/proxy-deploy.sh 
```

Finalmente conectamos por navegador a Ambari

~~~
http://localhost:8080/

raj_ops /// raj_ops
~~~

La mayoría de los archivos de configuración se encuentran en `/etc/hadoop/conf`

~~~
core-site.xml     Configuración principal de hadoop.
hdfs-site.xml     Configuración HDFS (Namenode, Datanodes, etc).
mapred-site.xml   Almacena configuración para ejecutar los procesos Map&Reduce.
yarn-site.xml     Configuración de Yarn.
capacity-scheduler.xml  Cononfiguración de colas y capacidades.
~~~

El directorio de los principales logs es:

~~~
/var/log/hadoop/hdfs       Namenode y Datanode
/var/log/hadoop-yarn/yarn  ResourceManager y NodeManager
/var/log/hive
~~~

## Usage

```sh
$ hdp-select # Versión Hortonworks
```

- Comandos Docker

```sh
docker ps -a

docker start sandbox-hdp
docker start sandbox-proxy

docker stop sandbox-hdp
docker stop sandbox-proxy

docker rm sandbox-hdp
docker rm sandbox-proxy
docker rmi hortonworks/sandbox-hdp:{release}
```

- Servicios

    - Hortonworks `localhost:8888`
    - Ambari `localhost:8080` con credenciales `raj_ops // raj_ops`
    - HDFS `localhost:50070`
    - Ranger `localhost:6080` con credenciales `admin // admin`
    - Zeppelin `localhost:9995/#/`
    - Jobs `localhost:8088`


Los servicios se levantan automáticamente. Especial atención con los siguientes puntos:

1. Levantar HDFS: Service Actions/Restart All

2. Si el Secondary Namenode no se arranca, habrá que hacerlo directamente: Hosts/sandbox.hortonworks.com/SNameNode/Start

3. Volvemos al Dashboard (dentro de HDFS) y apagamos modo mantenimiento (Turn of maintenance mode). Debería quedar HDFS en verde.

4. Reiniciamos hbase (si no arranca por defecto): Service Actions/Restart All

5. Apagamos modo mantenimiento para hbase.

6. Tarda un poco pero el Hbase master y los Region Servers deben quedar en verde.

7. Se puede acceder por consola a la sandbox (puerto 2222). La primera vez nos pedirá cambio de contraseña.

```sh
$ ssh root@<IP> -p 2222
$ ssh root@localhost -p 2222

root /// hadoop
```

8. Habrá que instalar ant para compilar nutch posteriormente `$ yum install ant`

9. Sigue instalar Apache Nutch... Ver [nutch-crawling.md](./nutch-crawling.md).

## References

[Hortonworks Docker](https://www.cloudera.com/tutorials/sandbox-deployment-and-install-guide/3.html)
