# Flume

Ejemplo configuracion Flume: guardar en `ej_flume.conf`

**Nomenclatura**

~~~
<agent-name>.<component-type>.<component-name>.<configuration-parameter>=<value>
~~~

**Nombre componentes del agente**

~~~
a1.sources=r1
a1.sinks=k1
a1.channels=c1
# Configuracion de fuente
a1.sources.r1.type=netcat
a1.sources.r1.bind=localhost
a1.sources.r1.port=44444
# Configuracion de destino
a1.sinks.k1.type=logger
# Configuracion del canal
a1.channels.c1.type=memory
a1.channels.c1.capacity=1000
a1.channels.c1.transactionCapacity=100
# Conexion de fuente con el destino a traves del canal
a1.sources.r1.channels=c1
a1.sinks.k1.channel=c1
~~~

Ejecutamos Flume con usuario root. Nos conectamos por telnet en otra ventana y tras cerrar la conexión podremos ver los mensajes en `/var/log/flume`

```sh
$ flume-ng agent --conf /usr/hdp/current/flume-server/conf/ --conf-file /home/<user>/ej_flume.conf --name a1

$ telnet 127.0.0.1 44444
Hola Mundo
$ cat /var/log/flume/flume.log | grep -i mundo
```

Para añadir la salida del telnet por consola... 

```sh
$ vi /usr/hdp/current/flume-server/conf/log4j2.xml
```

Y cambiar la linea donde pone

~~~
<Root level="INFO">
    <AppenderRef ref="LogFile" />
</Root>
~~~

por...

~~~
<Root level="INFO">
    <AppenderRef ref="LogFile" />
    <AppenderRef ref="Console"/>
</Root>
~~~
