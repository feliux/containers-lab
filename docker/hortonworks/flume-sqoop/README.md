# Adquisición y almacenamiento Big Data

El siguiente ejemplo consiste en una guía para insertar datos en las siguientes tecnologías:

* **Hadoop (HDFS)**
* **MySQL**

### HDFS

Tenemos un sistema que deposita datos en un directorio cada día a las 0:00 con un nombre distinto (podemos suponer que una vez que lo hace no se modifican) y queremos enviar los datos al sistema de ficheros distribuido de Hadoop.

Para ello utilizaremos un agente **Flume** sobre una fuente *SpoolDir*, la cual nos permitirá monitorizar en el directorio que deseemos. La configuración del agente se encuentra en el archivo `flume-hdfs.conf`

En primer lugar crearemos el usuario `user1` en local y en el clúster. Para crear usuario en el clúster es necesario que exista a nivel de sistema operativo. Le asignaremos el grupo `hdfs`.

~~~
$ useradd -g hdfs user1
$ passwd user1
$ su hdfs -c "hdfs dfs -mkdir /user/user1"
$ sudo su hdfs -c "hdfs dfs -chown user1:hdfs /user/user1"
$ sudo su hdfs -c "hdfs dfs -chmod 700 user1:hdfs /user/user1"
~~~

Y creamos los directorios de inserción de datos:

~~~
$ mkdir /home/user1/input
$ hdfs dfs -mkdir /user/user1/landing_area
~~~

Guardaremos la configuración del agente en el directorio del usuario y posteriormente ejecutaremos la instancia de Flume:

~~~
$ mv /home/flume-hdfs.conf /home/user1/
$ flume-ng agent --conf /usr/hdp/current/flume-server/conf/ --conf-file /home/user1/flume-hdfs.conf --name m6
~~~

En este momento tenemos el agente monitorizando el directorio local `~/input`, por lo que cualquier archivo de datos guardado en ese directorio automáticamente será almacenado en el clúster HDFS. Podemos ejecutar manualmente la inserción para comprobar su funcionamiento:

~~~
$ cp /home/user1/input.dat /home/user1/input/
~~~

Dando como resultado:

~~~
$ hdfs dfs -ls /user/user1/landing_area/
Found 1 item
-rw-r--r--   1 user1 hdfs        329 2020-02-02 17:44 /user/user1/landing_area/data_.1580665467597.dat

$ ls -la /home/user1/input
total 16
drwxr-xr-x 3 user1 hdfs 4096 Feb  2 17:44 .
drwx------ 3 user1 root 4096 Feb  2 18:15 ..
drwxr-xr-x 2 user1 hdfs 4096 Feb  2 17:44 .flumespool
-rw-r--r-- 1 user1 hdfs  663 Feb  2 17:44 input.dat.COMPLETED
~~~

### MySQL

Tenemos un proceso en Hadoop que deposita los resultados en `./results/` y que se quieren almacenar en una base de datos MySQL. Tenemos un ejemplo de los datos almacenados en el fichero `results.dat`.

En primer lugar crearemos el usuario `user1` a partir del usuario administrador `root // hortonworks1`:

~~~
mysql> create user 'user1' identified by 'hortonworks1'
mysql> grant all on m6.* to user1;
mysql> flush privileges;
mysql> quit
~~~

Salimos para aplicar cambios y comprobar el nuevo usuario. La tabla destino la podemos crear con la siguiente consulta:

~~~
$ mysql -u user1 -p
mysql> use m6;
mysql> create table results (name varchar(50) not null, rate float not null, primary key (name));
mysql> show tables;
+--------------+
| Tables_in_m6 |
+--------------+
| results      |
+--------------+
1 row in set (0.01 sec)

mysql> quit
~~~

Creamos el directorio que contendrá los datos en HDFS y guardamos allí el archivo `results.dat` que se encuentran en local:

~~~
$ hdfs dfs -mkdir /user/user1/results
$ hdfs dfs -put /home/user1/results.dat /user/user1/results/
$ hdfs dfs -ls /user/user1/results/
Found 1 items
-rw-r--r--   1 user1 hdfs        443 2020-02-02 20:03 /user/user1/results/results.dat
~~~

Para hacer el traspaso desde HDFS a MySQL usaremos **Sqoop** por ser una herramienta diseñada especialmente para transferir datos entre la plataforma Hadoop y una base de datos relacional. Mediante el siguiente comando podemos insertar los datos de manera manual:

~~~ 
$ sqoop export \
> --connect jdbc:mysql://localhost/m6 \
> --username user1 \
> --password hortonworks1 \
> --fields-terminated-by '|' \
> --lines-terminated-by '\n' \
> --table results \
> --export-dir /user/user1/results/ \
~~~

Posteriormente comprobamos que la inserción se ha realizado correctamente:

~~~
$ mysql -u user1 -p
mysql> use m6
mysql> select * from results;
+----------------------+-------+
| name                 | rate  |
+----------------------+-------+
| Anneke,Preusig       | 0.906 |
| Berni,Genin          | 0.914 |
| Bezalel,Simmel       | 0.902 |
| Chirstian,Koblick    | 0.904 |
| Cristinel,Bouloucos  | 0.917 |
| Duangkaew,Piveteau   |  0.91 |
| Eberhardt,Terkki     | 0.913 |
| Georgi,Facello       | 0.901 |
| Guoxiang,Nooteboom   | 0.915 |
| Kazuhide,Peha        | 0.918 |
| Kazuhito,Cappelletti | 0.916 |
| Kyoichi,Maliniak     | 0.905 |
| Lillian,Haddadi      | 0.919 |
| Mary,Sluis           | 0.911 |
| Mayuko,Warwick       |  0.92 |
| Parto,Bamford        | 0.903 |
| Patricio,Bridgland   | 0.912 |
| Saniya,Kalloufi      | 0.908 |
| Sumant,Peac          | 0.909 |
| Tzvetan,Zielinski    | 0.907 |
+----------------------+-------+
~~~

#### Automatización

Con intención de automatizar el proceso se propone esribir un script sencillo que será ejecutado por `cron`. **Cron** es el nombre del programa que permite a usuarios Linux/Unix ejecutar automáticamente comandos o scripts a una hora o fecha específica. Para ello escribimos los siguientes scripts:

- `flume-hdfs.sh`

- `mysql-hdfs.sh`

Los scripts siguen una configuración sencilla, simplemente constan del comando a ejecutar llamando a las opciones como variables.

Para la configuración de cron se utilizará el comando `crontab`, el cual permite a cada usuario editar su propio archivo `cron`. Para ello ejecutamos:

~~~
$ su user1
$ crontab -e
~~~

Se nos abrirá un archivo temporal el cual podemos modificar con la configuración `cron` que deseemos. Para este proyecto se propone la siguiente configuración de ejecución:

- `flume-hdfs.sh`: puesto que los datos llegan a las 0.00h se ejecutará este script a las 0.20h de cada día.

- `mysql-hdfs.sh`: dado que no sabemos cuando tiene lugar la recepción de datos se propone ejecutar el script cada 20 minutos.

~~~
# Configuracion Cron

20 0 * * * user1 /home/user1/flume-hdfs.sh
10,30,50 * * * * user1 /home/user1/mysql-hdfs.sh
~~~

El fichero temporal se guardará en `/var/spool/cron/user1`. Para comprobar la configuración ejecutamos:

~~~
$ crontab -l
20 0 * * * user1 /home/user1/flume_hdfs.sh
10,30,50 * * * * user1 /home/user1/hdfs_mysql.sh

$ service crond restart
~~~

Y finalmente reiniciamos el servicio para aplicar los cambios.

## Conclusión

En este proyecto hemos visto como configurar un agente **Flume** para inyectar datos en un clúster **HDFS** así como un ejemplo de inserción de datos en **MySQL** mediante **Sqoop**. Posteriormente hemos escrito un script para automatizar la ejecución mediante un job de **Cron**. En principio se trata de una configuración trivial pero que resulta muy educativa. Posiblemente se pueda llevar a producción en entornos Big Data pero no sin antes mejorar la configuración de las instancias.

En cuanto a la automatización del proceso cabe destacar lo sencillo que resulta la configuración del job cron. Una mejora a este respecto podría ser implementar un job de Jenkins, el cual mediante conexión a la sandbox Hortonworks ejecutaría los scripts que deseemos.
