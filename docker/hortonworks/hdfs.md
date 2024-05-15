# HDFS

```sh
$ hdfs dfsadmin -report		    # Estado y ocupación global del clúster
$ hdfs dfsadmin -printTopology	# Ver listado de racks y nodos

$ hdfs dfsadmin -safemode <enter|get|leave>	 # Cuando se va a realizar mantenimiento (no se permite escribir datos)

$ hdfs balancer			# Distribuye los datos entre todos los datanodes (recomendable tras añadir/eliminar servidores)
$ hdfs fsck <path>		# Chequeo del fylesystem
```

Para crear usuario en el clúster es necesario que exista a nivel de sistema operativo. Le podemos asignar el grupo hdfs.

```sh
$ useradd -g <group> <user>
$ passwd <user>
$ su hdfs -c "hdfs dfs -mkdir /user/<user>"	# Crear directorio de usuario en hdfs
$ sudo su hdfs -c "hdfs dfs -chown <user>:<group> /user/<user>"
$ sudo su hdfs -c "hdfs dfs -chmod 700 <user>:<group> /user/<user>"
$ hdfs dfs -ls
```

**Comandos típicos**

```sh
$ hdfs dfs				# Ver ayuda
$ hdfs dfs -ls -R <path>			# hdfs dfs -ls /user
$ hdfs dfs -ls hdfs://<namenode>/user	# Ejecutado sobre el <namenode>
$ hdfs dfs -mkdir <path>
$ hdfs dfs -mv
$ hdfs dfs -cp
$ hdfs dfs -cat <path>
$ hdfs dfs -tail <path>
$ hdfs dfs -df -h
$ hdfs dfs -du -sh
```

**Comandos para modificar permisos y grupos**

```sh
$ hdfs dfs -chgrp -R <group> <path>
$ hdfs dfs -chmod -R 740 <path>
$ hdfs dfs -chown -R <user>:<group> <path>
```

**Comandos de copia y movimiento de ficheros**

```sh
$ hdfs dfs -put <file> <path>
$ hdfs dfs -copyFromLocal <file> <path>
$ hdfs dfs -moveFromLocal <file> <path		# Mueve el fichero y lo elimina del origen

$ hdfs dfs -get <path> <file>
$ hdfs dfs -copyToLocal <path> <file>
$ hdfs dfs -getmerge -n1 <path> <file>	# Descarga varios ficheros y concatena en un único fichero (-n1 añade un fin de línea a cada fichero concatenado)
```

Papelera reciclaje de cada usuario en `/user/<username>/.Trash` (almacenados por defecto 6h)

```sh
$ hdfs dfs -expunge		# Vaciar papelera

$ hdfs dfs -rm -f -R -skipTrash
$ hdfs dfs -rmdir
```

**Comandos sobre colas**

```sh
$ mapred queue -list		# Colas existentes
$ mapred queue -showacls		# Consulta permisos de usuario sobre las colas
$ yarn queue -status <queue>	# Estado actual de una cola
```

**Snapshot**

```sh
$ hdfs dfs -ls ./<path>/.snapshot
$ hdfs dfsadmin -allowSnapshot <path>	# Habilita creación de snapshots en directorio
$ hdfs lsSnapshottableDir				# Ver directorios habilitados para snapshots

$ hdfs dfs -createSnapshot <path>
$ hdfs dfs -renameSnapshot <path>
$ hdfs dfs -deleteSnapshot <path>
```
