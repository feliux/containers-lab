# Apache Nutch

## Hortonworks Installation

```sh
$ ssh root@<IP> -p 2222
$ su hbase
$ cd /home/hbase

# Nutch: 
$ ..runtime/local/bin 

# Solr: http://<IP>:8983/solr/#/
$ cd /home/hbase/solr-4.6.0/example
$ java -jar start.ja
```sh

1. Todas las operaciones con usuario hbase y no como root, ya que root no tiene permisos para algunas operaciones sobre Hadoop.

```sh
$ su hbase
$ cd /home/hbase
$ pwd
```

2. Descargamos e instalamos: nutch 2.3.1

```sh
$ wget http://apache.rediris.es/nutch/2.3.1/apache-nutch-2.3.1-src.tar.gz
$ wget https://archive.apache.org/dist/nutch/2.3.1/apache-nutch-2.3.1-src.tar.gz
$ wget http://apache.rediris.es/nutch/2.4/apache-nutch-2.4-src.tar.gz

$ tar xvfz apache-nutch-2.3.1-src.tar.gz
$ cd apache-nutch-2.3.1
```

3. Tenemos el software pero debemos configurar y compilar. El primer paso es copiar la configuración de hbase del cluster para que nutch haga uso de ella.

```sh
$ cp /etc/hbase/conf/hbase-site.xml conf/
```

4. Habilitamos la dependencia gora-habse en el fichero ivy/ivy.xml donde descomentamos quitando los símbolos `<!-- y -->`

```sh
$ vi ivy/ivy.xml
```

5 Debe quedar así (o similar dependiendo de la versión de nutch)...

~~~
<dependency org="org.apache.gora" name="gora-hbase" rev="0.6.1" conf="*->default" />
<dependency org="org.apache.hbase" name="hbase-common" rev="0.98.8-hadoop2" conf="*->default" />
~~~

6. Editamos el fichero de configuración de gora y definimos como sistema de almacenamiento hbase...

```sh
$ vi conf/gora.properties
```

7. Añadir...

~~~
gora.datastore.default=org.apache.gora.hbase.store.HBaseStore
~~~

8. Editar el fichero `conf/nutch-site.xml` para la configuración de nutch. Para ello añadimos el siguiente bloque dentro de "configuration"

```sh
$ vi conf/nutch-site.xml

<property>
    <name>storage.data.store.class</name>
    <value>org.apache.gora.hbase.store.HBaseStore</value>
</property>
<property>
    <name>http.agent.name</name>
    <value>uemccrawler</value> 
</property>
<property>
    <name>http.robots.agents</name>
    <value>uemccrawler,*</value>
</property>
<property>
    <name>plugin.includes</name>
    <value>protocol-httpclient|urlfilter-regex|parse-(text|tika|js)|index-(basic|anchor)|query-(basic|site|url)|response-(json|xml)|summary-basic|scoring-opic|urlnormalizer-(pass|regex|basic)|indexer-solr</value>
</property>
<property>
    <name>db.ignore.external.links</name>
    <value>true</value> 
</property>
```

En el directorio `/home/hbase/apache-nutch-2.3.1/conf` se encuentran los archivos de configuración de nutch (todo lo que queremos indexar y lo que no).

9. Finalmente solo nos queda compilar el código mediante ant.

```sh
$ ant runtime
```

10. Puede tardar. Si todo ha ido bien se habrá generado el ejecutable en runtime/local/bin dentro de la ruta de nutch.

11. Descarga e instalacion de Solr


## Crawling

1. Creamos fichero de semilla con la url inicial.

```sh
$ mkdir /home/hbase/semillas

$ echo https://elpais.com/internacional/2019/10/08/estados_unidos/1570545272_430170.html > /home/hbase/semillas/elpais.txt
$ echo https://elmundo.es/internacional/2019/10/09/5d9d63af21efa0d0038b459b.html > /home/hbase/semillas/elmundo.txt
```

2. Directorio de Nutch.

```sh
$ cd /home/hbase/apache-nutch-2.3.1/runtime/local/bin/
```

3. Volcamos información a hbase. El comando vuelca una tabla denominada webpage. La opción crawlid permite indicar un prefijo al nombre de la tabla.

```sh
$ ./nutch inject /home/hbase/semillas/elpais.txt -crawlId elpais
$ ./nutch inject /home/hbase/semillas/elmundo.txt -crawlId elmundo
```

4. Si abrimos una shell de hbase podemos hacer la comprobción de la inyección.

```sh
$ hbase shell
list
scan 'elpais_webpage'
exit			# Para salir
```

5. Pasamos a las siguientes etapas (cíclicas)...

**Generación**

Generación de lotes de urls para su procesamiento. Elige una serie de urls de la colección (webpage) y las marca para indicar que son páginas de las que se necesita obtener información

```sh
$ ./nutch generate -topN 100 -crawlId elpais
# -topN indica el tamaño del lote
```

**Recuperación o descarga**

Se encarga de almacenar el contenido del lote clasificado en la fase generación

```sh
$ ./nutch fetch -all -crawlId elpais
```

En vez de `-all` se puede indicar sobre una url con `-batchld` seguido del identificador asignado a la fila en la tabla de la bbdd.

**Análisis**

Se evalúa qué webs no se han analizado aún, y se procede a realizar el proceso para el caso en que no apliquen

```sh
$ ./nutch parse -all -crawlId elpais
```

**Actualización de catálogo**

Reinyecta al sistema los enlaces a urls que se hayan encontrado. A partir de este punto se volvería a repetir el ciclo de crawling profundizando de forma iterativa en la estructura de la web

```sh
$ ./nutch updatedb -all -crawlId elpais
```

Si se hace scan en hbase, se puede ver como el número de filas aumenta.

**Indexación (adicional)**

Se encarga de catalogar el contenido de las webs descargadas. Podríamos tener una aplicación cliente que se conectara para que los usuarios pudieran buscar noticias relacionada con la temática interesada

```sh
$ ./nutch solrindex http://<IP>:8983/solr/ -all -crawlId elpais
$ ./nutch solrindex http://127.0.0.1:8983/solr/ -all -crawlId elpais
$ ./nutch solrindex http://127.0.0.1:8983/solr/collection1 -all -crawlId elpais
$ ./nutch solrindex http://127.0.0.1:8983/solr/elpais -all -crawlId elpais

# http://<IP>:8983/solr/#/
```

Acceder a la `collection1` y dentro a la opción `query`. Tendremos 'n' documentos indexados en función del número de url semilla. Podremos hacer búsquedas como pueden ser palabras clave, keywords extraídas, en el contenido... Ejemplo

~~~
title:impeachment
content:impeachment
~~~

Para borrar el contenido de solr. Cambiar dirección IP y nombre de la colección (`collection1`)

```sh
$ curl -X POST "http://localhost:8983/solr/collection1/update?commit=true" -H "Content-Type: text/xml" --data-binary "<delete><query>*:*</query></delete>"
```

Crear nueva colección copia de `collection1`. Hay que excluir el directorio data. Luego hay que modificar el archivo `core.properties` para cambiar el nombre de la colección.

```sh
$ rsync -avz --exclude data collection1/ collection2
```

## References

[Documentacion](https://cwiki.apache.org/confluence/display/nutch/)

[Tutorial Nutch + MongoDB](https://lobster1234.github.io/2017/08/14/search-with-nutch-mongodb-solr/)

[Tutorial Nutch + hbase + Solr](https://anil.io/blog/apache/nutch/apache-nutch-2-3-hbase-0-94-14-and-solr-5-2-1-tutorial/)

[DeepWeb](https://stackoverflow.com/questions/48699654/nutch-2-3-1-in-crawl-deep-web)

[DeepWeb](https://cwiki.apache.org/confluence/display/nutch/SetupNutchAndTor)

[Más info](https://stackoverflow.com/questions/55241781/how-to-re-index-data-without-deleting-in-solr)

[Más info 2](http://makble.com/how-to-create-new-collection-in-solr)

[Más info 3](https://blog.openalfa.com/como-re-indexar-una-coleccion-solr)

[Más info 4](https://blog.openalfa.com/como-crear-una-coleccion-en-solr)
