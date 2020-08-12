# ElasticSearch

### Primeros pasos con ElasticSearch

La existencia de **ElasticSearch** (ES) se debe a que desafortunadamente, la mayoría de las bases de datos son malas opciones para la extracción de "conocimiento/información procesable" (actionable knowledge) de los datos almacenados. Con las bases de datos tradicionales se puede filtrar por fecha y hora o valores exactos, pero no pueden llevar a cabo búsqueda de texto basadas en sinónimos ni ordenar documentos por relevancia, no generan análisis ni permiten trabajar con ingentes cantidades de datos en tiempo real de forma cómoda y rápida.

Elasticsearch está escrito en Java y utiliza **Lucene** internamente para la indexación y procesos de búsqueda, su objetivo es hacer la búsqueda de texto completo y fácil, ocultando las complejidades de Lucene gracias a una API REST sencilla. ElasticSearch es capaz de escalar a cientos de servidores y petabytes de datos estructurados y no estructurados.

Además, utiliza JavaScript Object Notation o JSON, como el formato de serialización de documentos, el cual es apoyado por la mayoría de los lenguajes de programación. JSON se ha convertido en el formato estándar utilizado por el movimiento NoSQL debido a que es simple, conciso y fácil de leer.

Algunos ejemplos de empresas que utilizan ES en la actualidad:

- Wikipedia utiliza Elasticsearch para proporcionar la búsqueda de texto completo y sugerencias.

- The Guardian utiliza Elasticsearch para combinar registros de visitantes con las redes sociales en base a los comentarios de los artículos.

- StackOverflow combina búsqueda de texto completo, geolocalización y encontrar preguntas y respuestas relacionadas.

- GitHub utiliza Elasticsearch para consultar 130 mil millones de líneas de código. 

### Conceptos de arquitectura de datos en ElasticSearch

Analogía Elasticsearch - MySQL

  * Relational DB  ⇒ Databases ⇒ Tables ⇒ Rows      ⇒ Columns
  * Elasticsearch  ⇒ Índices   ⇒ Types  ⇒ Documents ⇒ Fields

#### Índice

Un índice es un espacio de nombres lógico mapeado en uno o más fragmentos primarios los cuales pueden tener ninguna o varias réplica. Es una colección de documentos que tienen características similares. Los índices están identificados por un nombre, el cual usaremos a la hora de indexar, buscar, actualizar y borrar. Indexar un documento es crear un documento para que pueda ser buscado.

El índice es el lugar (lógico) donde Elasticsearch almacena los datos de modo que se pueden dividir a su vez en trozos más pequeños denominados fragmentos. Sería como una tabla en el mundo de las bases de datos. La estructura del índice se prepara para una rápida y eficiente búsqueda de texto completo pero sin almacenar los valores originales. Elasticsearch puede contener muchos índices situados en una máquina o repartidos en varios nodos. Cada índice es construido de uno o más fragmentos (**shards**), y cada fragmento puede tener muchas réplicas (**réplicas**).

#### Documento

Usando la analogía de las bases de datos relacionales, un documento es una tabla, normalmente es un documento Json. Los documentos se dividen a su vez en campos (**fields**), y puede estar varias veces en un mismo documento (**multivalued**). Cada campo tiene un tipo de dato (texto, número, fecha, etc.), los cuales pueden ser también complejos y albergar otros subdocumentos o tablas. 

Afortunadamente la asignación a tipo de dato se puede determinar automáticamente (sin embargo, puede ser recomendable utilizar asignaciones). Un documento en ElasticSearch tiene que tener el mismo tipo de dato para todos los campos comunes. Esto significa, que todos los documentos con un campo "título" debe tener el mismo tipo de dato, por ejemplo, string.

Los documentos no necesitan tener una estructura fija, pudiendo tener un conjunto de campos diferentes. Los campos no tienen por qué que ser conocidos durante el desarrollo de la aplicación. Desde el punto de vista del cliente, un documento es un objeto JSON.

Cada documento está almacenado en un índice y tiene su propio identificador único (que puede ser generado automáticamente por ElasticSearch) y tipo de documento. Un documento debe tener un identificador único en relación con el tipo de documento. Esto significa que en un solo índice, dos documentos pueden tener el mismo identificador único si no son del mismo tipo de documento.

#### Tipo de documento

En Elasticsearch, un índice puede almacenar muchos objetos con diferentes propósitos. El tipo de documento nos permite diferenciar fácilmente entre los objetos en un índice determinado a la vez que facilita la manipulación de datos. 

#### Mapping (Asignaciones)

En cuanto a la preparación de un texto para ser indexado y posteriormente buscado, como se ha dicho anteriormente, cada campo del documento debe ser analizado correctamente en función de su tipo. Por ejemplo, se requieren procesos de análisis diferente para los campos numéricos que para los de texto, los números no pueden ser ordenados alfabéticamente. Elasticsearch almacena la información sobre los campos dentro del mapping.

### Conceptos claves en ElasticSearch

Ya sabemos que Elasticsearch almacena datos en uno o más índices. Cada índice puede contener documentos de varios tipos. También sabemos que cada documento tiene muchos campos y cómo Elasticsearch trata estos campos se define por las asignaciones (mapping). Pero hay más. Desde el principio, Elasticsearch fue creado como una solución distribuida que puede manejar miles de millones de documentos y cientos de solicitudes de búsqueda por segundo. Esto se debe a varios conceptos importantes que vamos a describir con más detalle a continuación.

#### Nodo y Clúster

Elasticsearch puede trabajar de forma autónoma en una sola instancia de servidor. Sin embargo, para procesar grandes conjuntos de datos, lograr tolerancia a fallos y alta disponibilidad, Elasticsearch se pueden ejecutar en muchos servidores y funcionar de forma cooperativa en clúster, denominando a cada servidor de la formación nodo.

#### Shard (Fragmento)

Cuando se tiene un gran número de documentos, se puede llegar a un punto en el que un único nodo puede no ser suficiente, debido a limitaciones de memoria RAM, capacidad de disco duro, potencia de procesamiento o simplemente la incapacidad para responder a las solicitudes de clientes lo suficientemente rápido. En tal caso, los documentos se pueden dividir en partes más pequeñas llamadas fragmentos (donde cada fragmento es un índice de Apache Lucene separado). 

Cada fragmento se puede colocar en un servidor diferente, y por lo tanto, sus datos se puede transmitir entre los nodos del clúster. Cuando se consulta un índice dividido en varios fragmentos, Elasticsearch envía la consulta a cada fragmento relevante y fusiona el resultado acelerando por tanto la indexación, como es de suponer ese proceso es totalmente transparente para el cliente. Durante una indexación es posible especificar cuantos shards y réplicas deben crearse, según la configuración predeterminada son 5 shards y una réplica, es decir 10 incides lucene repartidos por el clúster. Al modificar el documento los 10 shards que lo componen deben también actualizarse.

#### Réplica

Con el fin de aumentar el rendimiento de consulta o lograr una alta disponibilidad, se pueden usar réplicas de fragmento. Una réplica es sólo una copia exacta de un shard, y cada fragmento puede tener cero o más réplicas. Elasticsearch puede tener muchos fragmentos idénticos y uno de ellos es elegido a la hora de tener que realizar cambios sobre el incide. Este fragmento especial se llama un fragmento primario, y los demás se llaman fragmentos de réplica. Cuando se pierde el fragmento primario (por ejemplo, un servidor que contiene el fragmento de datos no está disponible), el clúster cambia el estado de un fragmento de réplica para ser el nuevo fragmento primario.

#### Gateway

Elasticsearch puede manejar muchos nodos cuando se utiliza en modo clúster. De forma predeterminada, cada nodo tiene esta información almacenada localmente, que se sincroniza entre los nodos. El estado del clúster está en manos del Gateway.

**Relación entre réplicas, fragmentos y rendimiento**.

  * Más fragmentos significa que se requieren menos recursos para buscar un documento. Esto se debe a que un menor número de documentos se almacenan en un solo fragmento.

  * Más fragmentos significa más problemas cuando se busca a través del índice debido a que se deben combinar resultados de más fragmentos y por lo tanto la fase de agregación de la consulta puede utilizar más recursos.
 
  * Tener más réplicas en el clúster ofrece tolerancia a fallos, ya que cuando el fragmento original no está disponible, su copia tomará el papel del fragmento inicial. 
 
  * Cuantas más réplicas, mejor será el rendimiento de las consultas. Eso es debido a que la consulta puede utilizar un fragmento o cualquiera de sus copias.

NOTA: En una indexación, las réplicas sólo se utilizan como un lugar adicional para almacenar los datos. Cuando se ejecuta una consulta, de forma predeterminada, Elasticsearch intentará equilibrar
la carga entre el fragmento y sus réplicas de una manera inteligente.

Para más información se puede consultar el [Glosario de términos](https://www.elastic.co/guide/en/elasticsearch/reference/current/glossary.html#glossary-term|Glosario%20de%20terminos%20de%20ElasticSearch).

### Instalación / Directorios del paquete Elasticsearch

Para utilizar Elasticsarch solo es necesario descargarse el paquete/directorio comprimido, descomprimir y ejecutar, así de simple. También hay repositorios oficiales para las distros más importantes.

**Directorios de una instalación de Elasticsearch**.

  * **config** Fichero de configuración elasticsearch.yml (parámetros de configuración) y logging.yml
  * **data** Donde se guardan todos los datos utilizados por ES.
  * **logs** Registros con errores o acontecimientos relevantes.
  * **plugins** Plugins instalados.
  * **work** Directorio temporal de ES.

### Actualizar la Versión de ElasticSearch

Hay muchas manera de actualizar ElasticSearch, el método básico que requiere paralización del servicio por nodo es el siguiente. Se recomienda leer la documentación oficial.

  - Parar el servicio ElasticSearch.
  - Descomprimir la nueva versión y copiar los directorios data, config y plugins de la antigua versión a la nueva.
  - Arrancar la nueva versión de ElasticSearch.

### Configuración de Elasticsearch y recomendaciones

  * **elasticsearch.yml** Parámetros de configuración de Elasticsearch.
  * **loggin.yml**: Define la configuración de los logs.

Vigilar la cantidad el límite de descriptores de fichero que se pueden tener abiertos (> 35000) en /etc/security/limits.conf (Unix).

JVM: Establecer el límite de memoria a 1024 de la maquina virtual de Java y si se desea monitorizar para ajustar.

**Valores a tener en cuenta en elasticsearch.yml**

  * **cluster.name** Todos las instancias arrancadas con el mismo nombre de clúster se unirán como nodos.
  * **cluster.name** Nombre del nodo, puede cambiar en cada ejecución si no es definido.
  * **script.disable_dynamic**: false. Nos permitirá ejecutar ordenes de edición desde el exterior, más tarde se tratarán los temas de seguridad, pero para empezar a aprender sobre ES es recomendable si activación para poder editar documentos desde curl.

**Puertos de ElasticSearch**.

Utiliza dos puertos, el 9200 y 9000, si no está disponible va probando con el siguiente +1 (Se puede ver en los logs del arranque).

  * El puerto 9200 se utiliza para la comunicación con la API REST utilizando el protocolo HTTP,
  * El puerto 9000 utilizado por el módulo de transporte en la comunicación con grupos, clientes nativos y el clúster.

### APIs en ElasticSearch

En ES hay APIs de "documentos", de "búsquedas", de "índices", "cat" y "clúster". Dentro de alguna de ellas, podemos encontrar otras APIs, por ejemplo en la API de documentos tenemos CRUD API y Rest API. En esta guía no se verán todas las API, para ello está la guía oficial.

**CRUD Api**: "Create", "read", "update" y "delete".

Single document APIs

  * Index API
  * Get API
  * Delete API
  * Update API 

Multi-document APIs

  * Multi Get API
  * Bulk API
  * Bulk UDP API
  * Delete By Query API 
    
REST APi: Como todas las APIs Rest, tiene una interfaz web simple que utiliza XML y HTTP, por lo tanto la API CRUD es considerada también REST si interactuamos con ElasticSearch mediante HTTP. En la documentación de ES se mezclan muchos conceptos de API entre si que pueden llegar a confundir al lector.

**API REST de Elasticsearch**

Con la API REST de ElasticSearch podemos gestionar todo mediante HTTP. Índices, cambiar parámetros de la instancia, verificar nodos, estado del clúster, datos del índice, buscar en los datos, recuperar documentos, etc.

Por ahora nos centraremos en el uso de la CRUD (crear, recuperar, actualizar y borrar), como si de una base de datos NoSQL se tratara.

En una arquitectura de REST cada solicitud se dirige a un objeto concreto indicado en la URL. Por ejemplo, si "/libros/" es una referencia a una lista de libros en nuestra biblioteca, "/libros/1" es la referencia al libro con el identificador 1. Estos objetos como es de suponer se pueden anidar,  /libros/1/capítulo/6 referencia al sexto capítulo del primer libro de la biblioteca. El protocolo HTTP nos da una larga lista de tipos que se pueden utilizar como acciones en las llamadas a la API. 

  * GET Obtiene el estado actual de un objeto solicitado, consultas con body no son permitidas con todos los clientes.
  * POST Modificar el estado de un objeto y hacer consultas con body.
  * PUT Crear un objeto.
  * DELETE Elimina un objeto.

Sintaxis

~~~
curl -X<VERB> '<PROTOCOL>://<HOST>/<PATH>?<QUERY_STRING>' -d '<BODY>'
~~~

~~~
# No especificar GET en curl significa utilizarlo por defecto.
curl http://192.168.178.79:9200

{
  "status" : 200,
  "name" : "Diablo",
  "cluster_name" : "elasticsearch",
  "version" : {
    "number" : "1.5.1",
    "build_hash" : "5e38401bc4e4388537a615569ac60925788e1cf4",
    "build_timestamp" : "2015-04-09T13:41:35Z",
    "build_snapshot" : false,
    "lucene_version" : "4.10.4"
  },
  "tagline" : "You Know, for Search"
}
~~~

Comprobar configuración del clúster, sin utilizar "//pretty//" no se muestran saltos de linea.

~~~
curl -XGET http://192.168.178.79:9200/_cluster/health?pretty
{
  "cluster_name" : "escluster",
  "status" : "yellow",
  "timed_out" : false,
  "number_of_nodes" : 1,
  "number_of_data_nodes" : 1,
  "active_primary_shards" : 1,
  "active_shards" : 1,
  "relocating_shards" : 0,
  "initializing_shards" : 0,
  "unassigned_shards" : 1,
  "number_of_pending_tasks" : 0
}
~~~

Si se quiere conocer cuantos shards contiene cada nodo y el espacio que ocupan en disco.

~~~
curl -qs "http://dominio:9200/_cat/allocation?v"

shards disk.used disk.avail disk.total disk.percent    host         ip          node

     0    18.2gb     66.9gb     85.1gb           21    dominio      10.0.201.23 elastic1
  9963     563gb   1550.6gb       11tb           50    dominio      10.0.202.12 elastic2
     0     7.6gb     77.5gb     85.1gb            8    dominio      10.0.203.21 elastic3
     0        0b                                       dominio      10.0.200.36 kibana
  9962   509.2gb   1187.4gb    7696.7gb           73   dominio      10.0.204.71 elastic4
     0     8.9gb    115.4gb     124.3gb            7   dominio      10.0.205.70 elastic5
  9963   528.3gb   1563.7gb         9tb           48   dominio      10.0.206.15 elastic6
~~~

Revisar la configuración de los nodos del clúster, útil para saber en qué directorios del sistema se encuentran los directorios de ES.

~~~ 
curl "localhost:9200/_nodes/settings?pretty=true"
{
  "cluster_name" : "es",
  "nodes" : {
    "09dBkfM6SzC0k7g_q6sLwg" : {
      "name" : "es1",
      "transport_address" : "inet[/192.168.178.115:9300]",
      "host" : "es1",
      "ip" : "127.0.0.1",
      "version" : "1.7.1",
      "build" : "b88f43f",
      "http_address" : "inet[/192.168.178.115:9200]",
      "attributes" : {
        "master" : "false"
      },
      "settings" : {
        "pidfile" : "/var/run/elasticsearch/elasticsearch.pid",
        "path" : {
          "conf" : "/etc/elasticsearch",
          "data" : "/var/lib/elasticsearch",
          "logs" : "/var/log/elasticsearch",
          "work" : "/tmp/elasticsearch",
          "home" : "/usr/share/elasticsearch",
          "repo" : "/mnt/es_backups"
        },
        "cluster" : {
          "name" : "es"
        },
        "node" : {
          "name" : "es1",
          "data" : "true",
          "master" : "false"
        },
        "name" : "es1",
        "index" : {
          "number_of_shards" : "3"
        },
        "client" : {
          "type" : "node"
        },
        "bootstrap" : {
          "mlockall" : "true"
        },
        "config" : {
          "ignore_system_properties" : "true"
        }
      }
    },
    ...
~~~


### Apagar / parar Elasticsearch**

  * Cntrl + c en terminal.
  * Matando el proceso.
  * API REST de Elasticsearch.

~~~
curl -XPOST 'http://localhost:9200/_cluster/nodes/_shutdown'

# Consultar IDs de nodos.
curl -XGET 'http://localhost:9200/_cluster/nodes/'

# Parar nodos por IDs.
curl –XPOST 'http://localhost:9200/_cluster/nodes/XXXX/_shutdown'

# Consultar el número de documentos
curl -XGET 'http://localhost:9200/_count?pretty'

# Consultar el número de documentos, como la anterior pero con body (tienen el mismo efecto).
curl -XGET 'http://localhost:9200/_count?pretty' -d '
{
    "query": { "match_all": {} }
}'
~~~

### Crear / Indexar / Consultar / Actualizar un nuevo Documento

#### Crear documento

Por ejemplo, imaginemos que estamos creando el sistema de categorías de nuestro blog. Una de las entidades (índice) en este blog es artículos y es la que vamos a agregar.

~~~
{
"id": "1",
"title": "New version of Elasticsearch released!",
"content": "Version 1.0 released today!",
"priority": 10,
"tags": ["announce", "elasticsearch", "release"]
}
~~~

Hay tipos de datos numéricos (priority, el id no cuenta como tal), texto (title) y arrays (tags).

#### Indexar / Agregar al índice el documento

Agregar al Índice el documento: 

Índice:blog, Tipo:artículo, Identificador:1

~~~
curl -XPUT http://192.168.178.79:9200/blog/article/1 -d '{"title": "New version of Elasticsearch released!", "content": "Version 1.0 released today!", "tags": ["announce", "elasticsearch", "release"] }'

{"_index":"blog","_type":"article","_id":"1","_version":1,"created":true}
~~~

Si no se especifica un ID, Elasticsearch generará uno único.

~~~
curl -XPOST http://192.168.178.79:9200/blog/article/ -d '{"title": "New version of Elasticsearch released!", "content": "Version 1.0 released today!", "tags": ["announce", "elasticsearch", "release"] }'

{"_index":"blog","_type":"article","_id":"AUy_Oh16FzMRuRcZNvt3","_version":1,"created":true}
~~~

Si se están realizando scripts y se desea por algún motivo crear un documento inicializando un valor que luego irá cambiando por ejemplo con un contador, se puede utilizar **upsert** como muestra el siguiente ejemplo. La primera vez que se ejecute creará / indexará el documento inicializando counter a 0, cada vez que se repita ese mismo comando, counter irá sumando +1 a su valor. El uso de *upsert* y sus valores son ejecutados solo en la creación del documento, después no son utilizados.

~~~
curl -XPOST http://192.168.178.79:9200/blog/article/3/_update -d '{
"script": "ctx._source.counter += 1",
"upsert": {
"counter" : 0
}
}'
~~~

Automáticamente nos ha creado el índice blog, pero si solo queremos crear índice "blog" se debe hacer lo siguiente.

~~~
curl -XPUT http://localhost:9200/blog/
{"acknowledged":true}
~~~

#### Consultar y Borrar un documento

Nota: Utilizar "?pretty" para una salida tabulada

Por cada actualización la versión aumentará en +1. Cuando el valor de "exists" es false quiere decir que no se ha encontrado el documento y no mostrará por tanto ningún campo "_source".

~~~
curl -XGET http://192.168.178.79:9200/blog/article/1?pretty
# Existe.
{
  "_index" : "blog",
  "_type" : "article",
  "_id" : "1",
  "_version" : 3,
  "found" : true,
  "_source":{"title": "New version of Elasticsearch released!", "content": "Version 1.0 released today!", "tags": ["announce", "elasticsearch", "release"] }
}

# Borrar documento con ID: AUy_Oh16FzMRuRcZNvt3
curl -XDELETE http://192.168.178.79:9200/blog/article/AUy_Oh16FzMRuRcZNvt3
{"found":true,"_index":"blog","_type":"article","_id":"AUy_Oh16FzMRuRcZNvt3","_version":2}

curl -XGET http://192.168.178.79:9200/blog/article/AUy_Oh16FzMRuRcZNvt3?pretty
# No existe.
{
  "_index" : "blog",
  "_type" : "article",
  "_id" : "AUy_Oh16FzMRuRcZNvt3",
  "found" : false
}
~~~

#### Actualizar documentos en el índice

Al actualizar documentos en el índice ElasticSearch debe primero buscar internamente el documento, tomar sus datos del campo "_source", retirar el viejo documento, aplicar los cambios en el campo "_source", y luego darlo de alta en el índice como un nuevo documento. La causa es que no se puede actualizar la información una vez que se almacena en un índice invertido Lucene.

~~~
# Modificaremos el campo content y editaremos la versión 1.0 a 10.2.
curl -XPOST http://192.168.178.79:9200/blog/article/1/_update -d '{"script": "ctx._source.content = \"Version 10.2 released today\""}'

{"_index":"blog","_type":"article","_id":"1","_version":4}

# Consultamos el tipo article del documento blog con el id 1.
curl -XGET http://192.168.178.79:9200/blog/article/1/?pretty
{
  "_index" : "blog",
  "_type" : "article",
  "_id" : "1",
  "_version" : 4,
  "found" : true,
  "_source":{"title":"New version of Elasticsearch released!","content":"Version 10.2 released today","tags":["announce","elasticsearch","release"]}
}

# Agregar un nuevo parámetro si no existe 
curl -XPOST http://192.168.178.79:9200/blog/article/3/_update -d '{"script": "ctx._source.Nuevocampo = \"AAAAAAAAAAAA\""}'
~~~

Por motivos de seguridad que se explicarán posteriormente, si no se tiene la directiva "//script.disable_dynamic: false//" se obtendrá un mensaje como el siguiente.
~~~
{"error":"ElasticsearchIllegalArgumentException[failed to execute script]; nested: ScriptException[dynamic scripting for [groovy] disabled]; ","status":400}
~~~

### campo "version" en Elasticsearch

Elasticsearch incrementa la versión del documento cuando este ha sido creado, cambiado o borrado. Puede ser útil para implementar control de concurrencia en el proyecto que se tenga en mente si así se desea/necesita y evitar problemas al hacer actualizaciones en paralelo sobre el mismo documento. Para ello se puede utilizar el campo versión en la solicitud.

~~~
curl -XGET "http://192.168.178.79:9200/blog/article/1/?version=1&pretty"
# La versión actual es 17, pero se intenta borrar dada la versión 1 mostrando el siguiente error.
{
  "error" : "VersionConflictEngineException[[blog][2] [article][1]: version conflict, current [17], provided [1]]",
  "status" : 409
}
~~~

ElasticSearch también se puede basar en el número de versión proporcionado por nosotros, para ello debe ser utilizado "version" y "version_type" como en el siguiente ejemplo

~~~
curl -XPOST "http://192.168.178.79:9200/blog/article/8/_update?version=123454&version_type=external" -d '{...}
~~~

### Generar datos para comenzar a practicar con ElasticSearch (stream2es) + Plugins

[Enlace](https://gist.github.com/clintongormley/8579281) necesario para seguir los ejemplos de la guía oficial.

[Enlace stream2es](https://github.com/elastic/stream2es)

Plugins recomendados para empezar a trabajar con ElasticSearch: Kopf / Marvel (Consola Sense).

~~~.
/bin/plugin -i lmenezes/elasticsearch-kopf/{version}
~~~

Kopf `http://localhost:9200/_plugin/kopf`

Marvel `http://localhost:9200/_plugin/marvel/`

### Búsquedas en Elasticsearch (Querys/Filters

Se pueden buscar y consultar índices, tipos y documentos. Es posible especificar múltiples índices y tipos (Multi-index, Multitype).

~~~
# Buscar documentos en el índice blog.
curl -XGET "http://192.168.178.79:9200/blog/_search"

# Consultar dos índices (blog,blog2).
curl -XGET "http://192.168.178.79:9200/blog,blog2/_search"

# Consultar todos los índices blog y blog2 para mostrar su tipo de documento "artículo".
curl -XGET "http://192.168.178.79:9200/blog*/artículo/_search"

# Consultar todos los índices y filtrar por el tipo de documento "artículo" en todos los índices.
curl -XGET "http://192.168.178.79:9200/_all/artículo/_search"

# Consultar toda la información sobre el cluster de Elasticsearch.
curl -XGET "http://192.168.178.79:9200/blog/_search?pretty&q=title:elasticsearch'
~~~

### Interpretar campos en respuestas Elasticsearch / Filtrar por el valor de campos de documento

Filtrando por el campo título valor "//elastic//" + cualquier otro texto a continuación (*).

~~~
curl -XGET "http://192.168.178.79:9200/blog/_search?pretty&q=title:elasticsear*"
{
  "took" : 2,             # Tiempo en obtener la respuesta en milisegundos.
  "timed_out" : false,    # Si se ha alcanzado el timeout de la consulta. Se puede definir con "timeout"
  "_shards" : {           
    "total" : 5,          # Fragmentos requeridos para la resolver la consulta.
    "successful" : 5,     # Fragmentos de los que se obtuvo una respuesta exitosa.
    "failed" : 0          # Fragmentos que fallaron en la búsqueda (ej. nodos no accesibles).
  },
  "hits" : {
    "total" : 1,               # Total de documentos obtenidos.
    "max_score" : 1.0,         # Puntuación máxima calculada.
    "hits" : [ {           
      "_index" : "blog",       # Índice del documento.
      "_type" : "article",     # Tipo de documento.
      "_id" : "1",             # Identificador.
      "_score" : 1.0,          # Puntuación y a continuación en _source, normalmente el documento Json.
      "_source":{"title":"New version of Elasticsearch released!","content":"Version 10.2 released today","tags":["announce","elasticsearch","release"],"campo":"XXXXXXXX","campo2":"XXXXXXXX","counter":"1","campo3":"XXXXXXXX"}
    }]
  }
}
~~~

Durante la indexación, la biblioteca Lucene subyacente analiza los documentos y los índices de los datos de acuerdo a la configuración Elasticsearch. Por defecto ES indicará a Lucene que indexe y analice tanto los datos basadas en cadenas como en números.

### Query DSL (Solicitudes DSL)

Se basa en la interfaz JSON para comunicarse con ES de una forma más flexible, fácil, y precisa que con la URL. Aunque nos referimos en el título como consulta DSL, en realidad hay dos DSL: consulta DSL y filtro DSL, son similares en naturaleza, pero tienen diferentes propósitos.

Un filtro a diferencia de las querys permite hacer una consulta de sí o no en todos los documentos y se utiliza para campos que contienen valores exactos. El objetivo de filtros es el de reducir el número de documentos que tienen que ser examinado por la consulta.

Los filtros se encargarían por ejemplo de preguntar si el campo "created" tiene una fecha entre 2013 - 2014, si el campo "status" contienen el término "published", etc.

Lógicamente los filtros son más rápidos ya que las consultas tienen que encontrar no sólo documentos coincidentes, sino también calcular la relevancia de cada documento y mostrar su salida ordenada.

Como regla general, se debe utilizar las cláusulas de las querys para la búsqueda de texto completo o para cualquier condición que debe afectar a la puntuación de relevancia. El uso de las cláusulas de filtro se debe utilizar para todo lo demás.


Estructura de una Query DSL

~~~
{
    QUERY_NAME: {
        FIELD_NAME: {
            ARGUMENT: VALUE,
            ARGUMENT: VALUE,...
        }
    }
}
~~~

Preguntando por una frase (literal) en Elasticsearch en el índice wiki.

~~~
POST /wiki/_search
{
    "query": {
        "match_phrase": {
            "text": "idioma castellano"
        }
    }
}
~~~

#### Consultas/filtros más importantes y habituales

**Filtros**

- term y terms: Filtra por valores exactos (números, fechas, booleanos o no analizados)
~~~
{ "term": { "age":    26           }}
{ "term": { "date":   "2014-09-01" }}
{ "term": { "public": true         }}
{ "term": { "tag":    "full_text"  }}
~~~

Con terms podemos especificar multiples valores.

~~~
{ "terms": { "tag": [ "search", "full_text", "nosql" ] }}
~~~

- range: Permite filtrar por rangos de fechas y números. gt (>), gte (= >), lt (<), lte(= <).

~~~
{
    "range": {
        "age": {
            "gte":  20,
            "lt":   30
        }
    }
}
~~~

- exists y missing: Si se encuentra o no en el documento un determinado campo.

~~~
{
    "exists":   {
        "field":    "title"
    }
}
~~~

- bool: Permite unir varios filtros con sus parámetros must (and), must_not (not) y should (or).

~~~
{
    "bool": {
        "must":     { "term": { "folder": "inbox" }},
        "must_not": { "term": { "tag":    "spam"  }},
        "should": [
                    { "term": { "starred": true   }},
                    { "term": { "unread":  true   }}
        ]
    }
}
~~~

**Querys**

- match_all: Busca en todos los documentos, la predeterminada si no se especifica otra. Por norma se usa junto a filtros. Estas dos consultas serían iguales. (match_all es el equivalente a "{}")

~~~
POST /_search
{
    "query": {
        "match_all": {}
    }
}
~~~

~~~
GET /_search{}
POST /_search{}
~~~

- match: Busca un fulltext o exact value (para ello siempre mejor un filtro) en al menos un campo.

~~~
{ "match": { "tweet": "About Search" }}
~~~

Si el campo contiene un valor exacto, tal como un número, una fecha, un booleano, o un campo de cadena not_analyzed, se buscará dicho que el valor exacto.

~~~
{ "match": { "age":    26           }}
{ "match": { "date":   "2014-09-01" }}
{ "match": { "public": true         }}
{ "match": { "tag":    "full_text"  }}
~~~

- multi_match: Permite hacer la misma query en múltiples campos.

~~~
{
    "multi_match": {
        "query":    "full text search",
        "fields":   [ "title", "body" ]
    }
}
~~~

- bool: Al igual que el filtro bool, permite combinar varias cláusulas de consulta.

  * must: Cláusulas que deben coincidir para que el documento se incluya.
  * must_not: Cláusulas que no deben coincidir para que el documento se incluya.
  * should: Si esta cláusulas coincide aumenta el _score; de lo contrario no tiene ningún efecto (se utiliza para refinar la relevancia de los documentos). Si no hay cláusula "must", al menos "should" debe coincidir con algún documento.

~~~
{
    "bool": {
        "must":     { "match": { "title": "how to make millions" }},
        "must_not": { "match": { "tag":   "spam" }},
        "should": [
            { "match": { "tag": "starred" }},
            { "range": { "date": { "gte": "2014-01-01" }}}
        ]
    }
}
~~~

**Combinar filtros y querys**

~~~
POST /wiki/_search
{
  "query": {
    "filtered": {
      "query": {
        "match_phrase": {
          "title": "The Hound of Heaven"
        }
      },
      "filter": {
        "term": {
          "special": false,
          "redirect": false
        }
      }
    }
  }
}
~~~

Consultar mútiples campos en una query DSL (también aplicable a los filtros).

~~~
POST /wiki/_search
{
  "query": {
    "bool": {
      "must": [
        { "match_phrase": { "text": "In paradise, fast by the tree of life" }},
        { "match_phrase": { "title": "Amaranth" }},
        { "match": { "text": "Oscar synonym" }}
      ]
    }
  }
}
~~~

*Explicación:* Debe incluir las cadenas "//In paradise, fast by the tree of life//" y "//Amaranth//" en sus respectivos campos y luego, en el campo text debe encontrarse también o bien "Oscar" o bien "synonym". Recordemos que "must" se comporta como un "AND" y should como "OR".

**Clausulas y sus tipos** (leaf/compound).

  * Leaf clauses: Para comparar unos o varios campos con una query tring (ej. "match").
  * Compound clauses: Sirven para combinar otras cláusulas (bool).


**Analizar las solicitudes**

[Documentación](http://www.elastic.co/guide/en/elasticsearch/reference/current/indices-analyze.html

En este ejemplo se puede ver como Elasticsearch divide el texto en dos términos.

~~~
curl -XGET "http://192.168.178.79:9200/blog/_analyze?field=title&pretty" -d 'Elasticsearch Server'

{
  "tokens" : [ {
    "token" : "elasticsearch",
    "start_offset" : 0,
    "end_offset" : 13,
    "type" : "<ALPHANUM>",
    "position" : 1
  }, {
    "token" : "server",
    "start_offset" : 14,
    "end_offset" : 20,
    "type" : "<ALPHANUM>",
    "position" : 2
  } ]
}
~~~

**Buscar dentro de campos fulltext cadenas de texto literales** (ej. "//caca de vaca//")

  * match_phrase: Se pregunta por la cadena de texto literal, el documento resultante tendrá la cadena "caca de vaca".
  * match: Todos los valores pueden estar o no en el documento, el documento puede contener las cadenas "caca" o "de" o "vaca", o bien todas ellas.

### Parámetros utilizados en las consultas con Elasticsearch

Enumeración y explicación básica de algunos parámetros utilizados en las consultas, no preocuparse si algo no se entiende ya que se verá más tarde en profundidad.

<code curl>
curl -XGET 'localhost:9200/books/_search?pretty&q=published:2013&df=title&explain=true&default_operator=AND'
~~~

- **q** Permite especificar la consulta para buscar algo en los documentos utilizando la sintaxis de consulta de Lucene que se mostrará más adelante.

- **df** Especifica el campo de búsqueda predeterminado cuando no se utiliza ningún indicador de campo en el parámetro q. Por defecto busca en todos los campos haciendo uso del campo "_all", utilizado por Elasticsearch para copiar el contenido de todos los otros campos.

- **analyzer** Permite definir el nombre del analizador a utilizar para analizar la consulta. De forma predeterminada, nuestra pregunta será analizada por el mismo analizador que se utilizó para analizar el contenido de los campos en la etapa de indexación.

- **default_operator**  Especifica el operador booleano "OR" o "AND" predeterminado de la consulta. El predeterminado es "OR" y cualquier término que coincida será suficiente para devolver el documento. Por el contrario "AND" exige que todos los términos especificados en la búsqueda estén en el documento.

- **explain** Si es true se mostrará amplia información sobre la consulta como puede ser el fragmento utilizado para buscar el documento e información detallada sobre el cálculo de puntuación.

NOTA: Es importante utilizar comillas al especificar con curl parámetros en la URL, así se evita que la shell interprete el carácter "&".

Por defecto Elasticsearch devuelve los resultados ordenados por puntuación de forma descendiente. De forma predeterminada, para una consulta dada se devuelven siempre los siguientes parámetros.

  - Nombres del índice.
  - Identificador del documento.
  - Puntuación.
  - Campo "_source".

Para inferir en los resultados devueltos por Elasticsearch se pueden usar los siguientes parámetros.

- **sort** Permite ordenar la salida de otra manera que no sea mediante puntuación, por ejemplo "sort=published:desc" organiza la devolución de documentos en orden descendente basándose en el campo published, con el valor "asc" ascendente.

- **track_scores=true** Si se especifica una clasificación de salida personalizada con sort, Elasticsearch omitirá el cálculo del campo de puntuación (score) para los documentos. Si se desea mantener un seguimiento de las puntuaciones de cada documento al utilizar una ordenación personalizada, se debe añadir "track_scores = true" a la consulta (Hará la consulta más lenta debido a los cálculos).

- **timeout=5s** Por defecto no hay ningún timeout para esperar una respuesta.

- **size: size** y **from** Estos dos parámetros permiten especificar el tamaño de la ventana de resultados. El parámetro "size" especifica número máximo de resultados devueltos (por defecto 10). el parámetro "from" especifica a partir de qué documento se debe empezar a mostrar. Ej. "//size=5&from=10//" devuelve cinco documentos a partir del undécimo.

- **Tipos de búsqueda**: dfs_query_then_fetch , dfs_query_and_fetch , query_then_fetch , query_and_fetch , count , and scan.

- **lowercase_expanded_terms=true** Algunas consultas pueden utilizar expansiones, como por ejemplo prefix (consultas de prefijo). Esta directiva define si esas expansiones deben ser en minúsculas o no.

- **analyze_wildcard=true** Por defecto no se analizan las consultas comodín y las consultas prefijo. Si queremos cambiar este comportamiento se debe poner la directiva a true.

### Search Lite / Sintaxis de búsqueda Lucene

Hay dos formas de usar la api "search": Lite y DSL

- **Lite**: Todos los parámetros son pasados en la URL.

- **DSL**: Tiene su lenguaje propio y espera siempre una solicitud json.

La sintaxis de búsqueda Lucene es utilizada para el parámetro "q" (query) de ElasticSearch. A grandes rasgos, las búsquedas están divididas en términos (individuales y frases) y operadores booleanos (+ / -).

- **Termino individual**: title:book

- **Termino frase**: title:"elasticsearch book" (deben estar ambos términos y en el mismo orden).

- **Operador +**: Ambas partes deben coincidir en el documento. 

- **Operador -**: Es lo opuesto a +, lo que significa que el termino no puede estar presente en el documento. 

Una consulta que indique más de un termino y alguno carezca de "+" o "-" indica que el termino puede estar o no en el documento. Si se desea encontrar un documento con el termino "libro" pero no "gato" se puede especificar lo siguiente "+title:libro -description:gato".

Para dar más **relevancia** a un determinado término se usa "^": title:book^4, esto aumentará la puntuación.

**Paréntesis** para especificar múltiples términos de búsqueda en cualquier orden y somo si fuera un OR: "title:(crime punishment)"

**Wildcards** (No al principio de la consulta): "*" (Cualquier carácter/s) y "?" Un carácter. Si se quieren utilizar al principio de la consulta se puede utilizar: allow_leading_wildcard false (no recomendable por temas de rendimiento). Se pueden especificar wildcards en el nombre del campo si se escapan con "\" (ej. campo): c\*po:(blanco negro).

- **_missing_**:Nuevocampo" Muestra los documentos que carezcan de un determinado campo o bien esté vacío.

- **_exists_**:title"  Muestra documentos con campo "title" no nulo (con contenido).

Se pueden utilizar **patrones con expresiones regulares** si van dentro de "/", ej. "name:/joh?n(ath[oa]n)/"

**Fuzziness**: Buscar palabras parecidas utilizando "~", se puede nivelas incluyendo un numero "~3", por defecto es 2.

Ejemplos como pruebas de concepto

~~~
curl -XGET "http://dominio:9200/blog/_search?pretty&q=+Nuevocampo:(AAAAAAA+BBBB)+counter:(8+3)&default_operator=OR"
{
  "took" : 2,
  "timed_out" : false,
  "_shards" : {
    "total" : 5,
    "successful" : 5,
    "failed" : 0
  },
  "hits" : {
    "total" : 2,
    "max_score" : 0.41285858,
    "hits" : [ {
      "_index" : "blog",
      "_type" : "article",
      "_id" : "3",
      "_score" : 0.41285858,
      "_source":{"counter":3,"cadeba":"CCCCCCCC","Nuevocampo":"AAAAAAA"}
    }, {
      "_index" : "blog",
      "_type" : "article",
      "_id" : "4",
      "_score" : 0.03978186,
      "_source":{"counter":50,"Nuevocampo":"AAAAAAA BBBB"}
    } ]
  }
}

# Para dar más puntuación al segundo resultado, se podría utilizar "^".
curl -XGET "http://dominio:9200/blog/_search?pretty&q=Nuevocampo:(AAAAAAA+BBBB^9)&default_operator=OR"
{
  "took" : 4,
  "timed_out" : false,
  "_shards" : {
    "total" : 5,
    "successful" : 5,
    "failed" : 0
  },
  "hits" : {
    "total" : 2,
    "max_score" : 0.2117889,
    "hits" : [ {
      "_index" : "blog",
      "_type" : "article",
      "_id" : "4",
      "_score" : 0.2117889,
      "_source":{"counter":50,"Nuevocampo":"AAAAAAA BBBB"}
    }, {
      "_index" : "blog",
      "_type" : "article",
      "_id" : "3",
      "_score" : 0.03274158,
      "_source":{"counter":3,"cadeba":"CCCCCCCC","Nuevocampo":"AAAAAAA"}
    } ]
  }
}

# Si se usa el operador AND no se mostraría ningún resultado.
curl -XGET "http://dominio:9200/blog/_search?pretty&q=+Nuevocampo:(AAAAAAA+BBBB)+counter:(8+3)&default_operator=AND"

# Si se especifica que no muestre ningún documento con el valor de counter 50 o 3 tampoco motraría nada.
curl -XGET "http://dominio:9200/blog/_search?pretty&q=+Nuevocampo:(AAAAAAA+BBBB)-counter:(50+3)&default_operator=OR"

# Esta consulta devolvería un resultado si se evita solo un valor de counter y se utiliza AND.
curl -XGET "http://dominio:9200/blog/_search?pretty&q=+Nuevocampo:(AAAAAAA+BBBB)-counter:(3)&default_operator=AND"
{
  "took" : 4,
  "timed_out" : false,
  "_shards" : {
    "total" : 5,
    "successful" : 5,
    "failed" : 0
  },
  "hits" : {
    "total" : 1,
    "max_score" : 0.2712221,
    "hits" : [ {
      "_index" : "blog",
      "_type" : "article",
      "_id" : "4",
      "_score" : 0.2712221,
      "_source":{"counter":50,"Nuevocampo":"AAAAAAA BBBB"}
    } ]
  }
  
# Muestra el documento que tenga esos dos términos y en ese mismo orden.
curl -XGET "http://dominio:9200/blog/_search?pretty&q=Nuevocampo:\"AAAAAAA/**/BBBB\""
{
  "took" : 1,
  "timed_out" : false,
  "_shards" : {
    "total" : 5,
    "successful" : 5,
    "failed" : 0
  },
  "hits" : {
    "total" : 1,
    "max_score" : 0.38356602,
    "hits" : [ {
      "_index" : "blog",
      "_type" : "article",
      "_id" : "4",
      "_score" : 0.38356602,
      "_source":{"counter":50,"Nuevocampo":"AAAAAAA BBBB"}
    } ]
  }
}

# No aparece ningún resultado con el siguiente comando ya que no es el orden correcto
curl -XGET "http://dominio:9200/blog/_search?pretty&q=Nuevocampo:\"BBBB/**/AAAAAAA\""

# Si se usan los paréntesis se mostrará resultados ya que por defecto usa OR y si no encuentra un termino encontrará el otro, igual el orden.
curl -XGET "http://dominio:9200/blog/_search?pretty&q=Nuevocampo:(BBBB/**/AAAAAAA)"
{
  "took" : 2,
  "timed_out" : false,
  "_shards" : {
    "total" : 5,
    "successful" : 5,
    "failed" : 0
  },
  "hits" : {
    "total" : 2,
    "max_score" : 0.15109822,
    "hits" : [ {
      "_index" : "blog",
      "_type" : "article",
      "_id" : "3",
      "_score" : 0.15109822,
      "_source":{"counter":3,"cadeba":"CCCCCCCC","Nuevocampo":"AAAAAAA"}
    }, {
      "_index" : "blog",
      "_type" : "article",
      "_id" : "4",
      "_score" : 0.013555458,
      "_source":{"counter":50,"Nuevocampo":"AAAAAAA BBBB"}
    } ]
  }
}

# Utilizando un comodín el el nombre del campo
curl -XGET "http://dominio:9200/blog/_search?pretty&q=Nuevocampo:\"AAAAAAA/**/BBBB\""
{
  "took" : 1,
  "timed_out" : false,
  "_shards" : {
    "total" : 5,
    "successful" : 5,
    "failed" : 0
  },
  "hits" : {
    "total" : 1,
    "max_score" : 0.38356602,
    "hits" : [ {
      "_index" : "blog",
      "_type" : "article",
      "_id" : "4",
      "_score" : 0.38356602,
      "_source":{"counter":50,"Nuevocampo":"AAAAAAA BBBB"}
    } ]
  }
}

# Muestra los documentos que carezcan de un determinado campo o bien esté vacío, en este caso "Nuevocampo".
curl -XGET "http://dominio:9200/blog/_search?pretty&q=_missing_:Nuevocampo"

# Muestra documentos con campo "title" no nulo (con contenido).
curl -XGET "http://dominio:9200/blog/_search?pretty&q=_exists_:title"

# Buscará palabras que se parezcan a Elasticserach (por ejemplo, elasticsearch).
curl -XGET "http://dominio:9200/blog/_search?pretty&q=title:Elasticserach~"
~~~

### Creación de Índices

La creación de índices de manera automática puede ser un problema si se comete un simple error tipográfico en un envío masivo de datos, lo normal es deshabilitar la opción de creación automática de índices en `elasticsearch.yml`.

~~~
action.auto_create_index: false
~~~

la siguiente definición permite la creación automática únicamente de índices que comienzan con "a", pero no "an".

~~~
action.auto_create_index: -an*,+a*,-*
~~~

El orden juega un papel importante ya que ejecuta la primera coincidencia, de poner +a delante se anularía la restricción "-an".

La creación manual de un índice es necesaria para especificar la cantidad de fragmentos y sus réplicas, para el ejemplo se crearán tres índices lucene (el primario y dos copias).

~~~
curl -XPUT http://localhost:9200/blog/ -d '{
"settings" : {
"number_of_shards" : 1,
"number_of_replicas" : 2
}
}'
~~~

Mostrar todos los índices.

~~~
curl 'localhost:9200/_cat/indices?v'

health status index              pri rep docs.count docs.deleted store.size pri.store.size 
green  open   .marvel-2015.05.13   1   1        596            0      3.1mb          1.5mb 
green  open   .marvel-2015.04.24   1   1       2771            0      8.6mb          4.3mb 
green  open   .marvel-2015.05.14   1   1        634            0      3.2mb          1.6mb 
green  open   blog                 5   1          8            0     45.5kb         22.8kb 
~~~

### Mapping

Aunque Elasticsearch es un motor de búsqueda sin esquemas, se puede averiguar la estructura de datos sobre la marcha, pero se recomienda especificar una estructura al momento de crear el índice.

  * Las cadenas están rodeados de comillas.
  * Los Booleanos se definen utilizando palabras específicas.
  * Los números se definen simplemente como dígitos. 

A veces los valores numéricos se proporcionan dentro de un campo de cadena, para que reciban el tratamiento numérico que merece se puede utilizar la opción //"numeric_detection" : true// al crear la estructura del índice (mapping).

~~~c
url -XPUT http://localhost:9200/blog/?pretty -d '{
"mappings" : {
"article": {
"numeric_detection" : true
}
}
}'
~~~

Otro tipo de dato que puede causar problemas es el de fecha. Elasticsearch intenta adivinar fechas dadas como marcas de tiempo o cadenas que coinciden con el formato de fecha. Podemos definir la lista de formatos de fecha reconocidas utilizando la propiedad "//dynamic_date_formats//" para especificar uno o varios formatos a utilizar. Este comando crea un índice con un único tipo: article.

~~~
curl -XPUT 'http://localhost:9200/blog/' -d '{
"mappings" : {
"article" : {
"dynamic_date_formats" : ["yyyy-MM-dd hh:mm"]
}
}
}'
~~~

Para desactivar la agregación de campos de forma automática se debe establecer la propiedad "dynamic" a false. Cualquier intento de agregación de campos diferentes a los definidos (id, content y author) en el tipo "article" será ignorado.

~~~
curl -XPUT 'http://localhost:9200/blog/' -d '{
"mappings" : {
"article" : {
"dynamic" : "false",
"properties" : {
"id" : { "type" : "string" },
"content" : { "type" : "string" },
"author" : { "type" : "string" }
}
}
}
}'
~~~

Supongamos que queremos crear un índice con las siguiente estructura:

  * Índice Posts: Identificador único / Nombre / Fecha de publicación / Contenido.

Creamos el fichero "posts.json" para no utilizar siempre la linea de comandos al crear el index.

~~~
curl -XPOST 'http://localhost:9200/posts' -d @posts.json
~~~

~~~
{
"mappings": {
"post": {
"properties": {
"id": {"type":"long", "store":"yes","precision_step":"1" },
"name": {"type":"string", "store":"yes","index":"analyzed" },
"published": {"type":"date", "store":"yes","precision_step":"1" },
"contents": {"type":"string", "store":"no","index":"analyzed" }
}
}
}
}
~~~

### Tipos de Datos

Tipos de datos principales (Core Type).

  * String
  * Number
  * Date
  * Boolean
  * Binary

**Core fields: Atributos para todos los tipos de datos** (No para el tipo de dato Binary)

  * index_name: Nombre del campo, si no se define será el del objeto con el que campo es definido.
 
  * index: Valores //analyzed// / //no// / //not_analized//. Si es "analyzed" será indexado y buscable (por defecto) usando para ello diferentes términos (Leer sección de análisis para saber qué tareas se realizan). Con not_analized se indexaría pero no se podría buscar.
 
  * store: Valores //yes// / //no// (por defecto). Especifica si el valor original del campo debe ser indexado y por lo tanto aparece en los resultados de búsqueda.
 
  * boost: Por defecto 1, define qué importante es el campo, cuanto mayor sea el valor, más importante.
 
  * null_value: Especifica el valor que tiene que ser escrito en el índice si el campo no es parte de un documento indexado.
 
  * copy_to: Este atributo especifica qué valores de campos se deben copiar en otros campos.

  * include_in_all: Especifica si un campo debe ser incluido en el campo especial _all (por defecto todos).


**String**: Para las búsquedas de texto, además de tener los atributos principales, tiene otros específicos que no explicaremos aquí.

**Number**: Estos son los tipos de datos numéricos.

  * byte: Valor de bis (1 / 0).
  * short: Valor pequeño (ej. 18).
  * integer: Valor numérico cualquiera (ej. 134).
  * long: Valor numérico grande (ej. 23456789).
  * float: Valor Decimal (12.23).
  * double: Valor Decimal más grande (ej. 123.45).

Ejemplo de definición un campo "number".

~~~
"price" : { "type" : "float", "store" : "yes", "precision_step" : "4"}
~~~

Atributos específicos de los tipos numéricos.

  * precision_step: Número de términos generado para cada valor en un campo, por defecto 4. Cuanto menor sea el valor, mayor es el número de términos generado. A mayor número de términos por valor mayor velocidad en las consultas a costa de aumentar el tamaño del incide. 
  * ignore_malformed: Este atributo puede tomar el valor verdadero o falso (por defecto). Necesita true para no permitir valores con formato erróneo.

**Boolean**

Puede ser true o false.

**Binary**

Se almacenan los ficheros (mp3, pdf, png, exe,...) en Base64. Este campo no permite ser buscado, se debe utilizar index_name.

~~~
"image" : { "type" : "binary" }
~~~

**Date**

Se utilizan para indexar fechas.
~~~
"published" : { "type" : "date", "store" : "yes", "format" :"YYYY-mm-dd" }
~~~


  * format: Este atributo especifica el formato de la fecha, por defecto "dateOptionalTime" ej. 2012-07-14T12:30:00.
  * precision_step: Número de términos generados por cada valor del campo. Por defecto 4.
  * ignore_malformed: true/false (por defecto).

NOTA: Un término se refiere a un valor exacto, no es lo mismo Caca, CACA y CaCa.

**Multicampos**

Se utilizan para tener los mismos valores en varios campos core_types), por ejemplo, uno para la búsqueda y otro para clasificación.

~~~
{
    "tweet" : {
        "properties" : {
            "name" : {
                "type" : "multi_field",
                "fields" : {
                    "name" : {"type" : "string", "index" : "analyzed"},
                    "untouched" : {"type" : "string", "index" : "not_analyzed"}
                }
            }
        }
    }
}
~~~

La definición anterior creará dos campos: nos referiremos a la primera como el nombre de "name" y el segundo "name.facet". No se tiene que especificar dos campos separados durante la indexación, con "name" es suficiente.

**Direcciones IP**

Tiene el atributo precision_step a valor de 4, se recomienda aumentar para búsquedas por rangos.

~~~
"address" : { "type" : "ip", "store" : "yes" }
~~~

**Tipo token_count**

Almacena el token en vez de la cadena en si, se usa con analizadores. Lo mejor para el rendimiento es no usar tokens con analizadores.

### Campos de Valores exactos VS Campos Full text

**Exact value**: Fechas, IDs,... El valor exacto "2014" no es lo mismo que el valor 2014-02-11. Son fáciles de buscar y operar.

**Full text**: Este tipo de campos usa índices invertidos, para crearlos, trocea el texto en palabras (llamadas "terms" o "Tokens") y crea una lista ordenada con  los términos únicos y en qué documentos se encuentran. Así el documento que más palabras de la búsqueda contenga será el elegido. También reduce a minúsculas las términos, conoce sinónimos, reduce las palabras a su raíz (elimina conjugaciones, plurales, etc), etc.

### Análisis y Analizadores

El proceso de análisis consiste en tokenizar (dividir) un texto en términos individuales para ser usados en un índice invertido y después los normaliza. Dicho proceso lo realiza el analizador, encontramos algunos de ellos ya de serie en ES, estos combinan estas tres funciones.

  * **Filtro de caracteres**: El string es pasado por un filtro que por ejemplo cambia & en "and", o quita etiquetas html etc.
  * **Tokenizer**: Divide la cadena en otros términos utilizando espacios en blanco o signos de puntuación.
  * **Token filters**: Pasa a minúsculas, elimina términos como las stopwords (palabras vacías) a, and, the,... o agrega sinónimos. ES tiene para cada lenguaje un listado stopwords definido.

Por estas mismas tres fases deben pasar las búsquedas sobre ese campo full-text para que sea efectivo.

~~~
GET /_search?q=2014              # 12 results Se pregunta al campo _all (full text).
GET /_search?q=2014-09-15        # 12 results Se vuelve a preguntar al campo all, si encuentra el valor 2014 o 09 o 15, por lo que mínimo devuelve 12 resultados.
GET /_search?q=date:2014-09-15   # 1  result Ahora se ha preguntado al campo date, el cual tiene un valor exacto y el resultado es uno porque solo hay un valor 2014-09-15.
GET /_search?q=date:2014         # 0  results Si la anterior petición con 2014-09-15 devolvió un resultado, esta lógicamente debe devolver ninguno.~~~

Por ejemplo, cuando nos dividimos las cadenas de texto palabras con los espacios en blanco y caracteres en minúsculas, no tenemos que preocuparnos por los usuarios que envían palabras en minúsculas o mayúsculas. Los analizadores son muy usados para mostrar sugerencias en campos de búsqueda según se teclea la palabra deseada.

Elasticsearch nos permite utilizar diferentes analizadores en el momento de la indexación y diferentes analizadores en el momento de la consulta. Podemos elegir cómo queremos que nuestros datos sean procesados en cada etapa del proceso de búsqueda. Para utilizar uno de los analizadores, sólo tenemos que especificar su nombre a la propiedad correcta del campo.

Los analizadores en Elasticsearch se componen de:

  * 1 Tokenizer: se encarga de trocear una cadena de texto. Cada trozo obtenido se le denomina token.
  * N TokenFilters: filtros aplicados sobre los tokens generados por el Tokenizer.
  * N CharFilters: aplican un procesamiento a nivel de carácter previo a la ejecución del Tokenizer.

Elasticsearch proporciona una serie de Analyzers, aunque nos permite customizarlos en caso de que no haya alguno que se ajuste a nuestras necesidades. Esta customización consiste en seleccionar la combinación de Tokenizer y TokenFilters.

**Analizadores Out-of-the-box**.

  * standard: Recomendado para la mayoría de lenguajes Europeos.
  * simple: Divide los valores por valores que no contengan letras y además lo pasa todo a minúsculas.
  * whitespace: Divide valores usando espacios en blanco.
  * stop: Como simple analyzer pero filtra además utilizando sets de palabras stop.
  * keyword: Este es un analizador muy simple que utiliza un valor proporcionado. Tiene el mismo efecto que definiendo un campo como "not_analyzed".
  * pattern: Permite establecer separación de texto según expresiones regulares.
  * language: Analizador diseñado para trabajar con un lenguaje en concreto.
  * snowball: Como el analizador standard pero además provee algoritmos de stemming.

NOTA: El Stemming es le proceso de reducir palabras a su forma más básica, como es "coches" - "coche", permitiendo que una búsqueda encuentre "coches" simplemente buscando "coche".

### Valor de los documentos

Define donde se va a encontrar un valor, si en disco o en memoria RAM.

~~~
{
  "mappings" : {
     "post" : {
        "properties" : {
          "id" : { "type" : "long", "store" : "yes", "precision_step" : "0" },
          "name" : { "type" : "string", "store" : "yes", "index" : "analyzed" },
          "contents" : { "type" : "string", "store" : "no", "index" : "analyzed" },
          "votes" : { "type" : "integer","doc_values_format" : "memory" }
        }
      }  
  }
}
~~~

  * default: Este es un formato de valores doc que se utiliza cuando no se especifica ningún formato. Ofrece un buen rendimiento con bajo uso de memoria.
  * disk: Almacena los datos en el disco sin requerir prácticamente memoria. Sin embargo, existe una degradación de rendimiento al utilizar esta estructura de datos para operaciones de parseo o clasificación.
  * memory: Se trata de un formato de valores doc que almacena los datos en la memoria y ofrece el mayor rendimiento. En el ejemplo el campo votes es un buen candidato debido a que se puede utilizar regularmente para clasificaciones.

### Indexación por lotes

En vez de indexar documentos uno por uno se puede realizar por lotes. ElasticSearch permite fusionar muchas peticiones en un solo lote.

  * index: Agregar nuevos datos o remplazar documentos indexados.
  * delete: Borra documentos.
  * create: Crea nuevos documentos solo cuando no hay ninguno previamente indexado, si existe, dará un fallo al intentar ingresarlo.

~~~
"error" : "DocumentAlreadyExistsException[[direccion][1] [contact][5]: document already exists]"
~~~
 
Los ficheros por lotes se deben definir sin tabulaciones, todo en una linea y no más de 100Mb por fichero de lotes, pero se puede adaptar con la directiva http.max_content_length. Cada linea de un fichero por lotes es un objeto JSON con una descripción de la operación a realizar + el objeto JSON en si. Solo cuando se quiere borrar un documento se debe especificar únicamente la operación.

~~~
{ "index": { "_index": "addr", "_type": "contact", "_id": 1 }}
{ "name": "Fyodor Dostoevsky", "country": "RU" }
{ "create": { "_index": "addr", "_type": "contact", "_id": 2 }}
{ "name": "Erich Maria Remarque", "country": "DE" }
{ "create": { "_index": "addr", "_type": "contact", "_id": 2 }}
{ "name": "Joseph Heller", "country": "US" }
{ "delete": { "_index": "addr", "_type": "contact", "_id": 4 }}
{ "delete": { "_index": "addr", "_type": "contact", "_id": 1 }}
~~~


~~~
curl -XPOST 'localhost:9200/_bulk?pretty' --data-binary @test.json
~~~

NOTA: En el indexado por lotes, si se necesita más velocidad, se puede usar User Datagram Protocol (UDP), pero solo en ambientes donde la velocidad prima sobre la pérdida de datos.

###  Campos importantes

En ES hay dos tipos de identificadores internos para los documentos: "_uid" y "_id".

  - **_uid**: Único identificador del documento compuesto de un identificador (_id) y un tipo. Documentos de diferente tipo que están en el mismo índice pueden tener el mismo identificador para que ElasticSearch pueda distinguirlos. 
  - **_id**: Guarda el identificador durante el tiempo de indexado, se pueden definir sus propiedades en el mapping, por ejemplo si solo queremos que se indexe pero no analice y no se almacene en el índice (Cuidado: en este caso los documentos requerirán un _uid único).

~~~
{
"book" : {
  "_id" : {
         "index": "not_analyzed",
         "store" : "no"
        },
  "properties" : {
.
.
.
}
~~~

Si queremos usar un "_id" igual a otro campo del documento indexado es también posible.

~~~
{
"book" : {
"_id" : {
"path": "book_id"
},
"properties" : {
.
.
.
  }
 }
}
~~~


**Campo _type**

Como dijimos antes, cada documento en ES es descrito por su identificador (_id) y tipo. Por defecto los tipos son indexados pero no analizados ni almacenado (No pueden ser buscados ni operar con ellos utilizando expresiones regulares).


Buscar por tipo "contact" en todos los índices.

~~~
curl -XGET 'localhost:9200/_all/contact/_search?q=name:Dav*+country:ES&default_operator=AND&pretty'

# Como el tipo "contact" no es guardado ni analizado esta consulta con expresión regular "conta*" no funcionará.
curl -XGET 'localhost:9200/_all/conta*/_search?q=name:Dav*+country:ES&default_operator=AND&pretty'
~~~

**Campo _all**

Contiene los datos de todos los otros campos para facilitar así las búsquedas. Esto permite hacer búsquedas cuando no se quieren especificar campos y se quiere buscar en todos los índices, por eso esta consulta muestra el mismo resultado que la anterior (no especifica el tipo "contact").

~~~
curl -XGET 'localhost:9200/_all/_search?q=name:Dav*+country:ES&default_operator=AND&pretty'
~~~

Está siempre habilitado y hace que los índices sean algo más grandes pero no en todos los casos será necesario. Para decidir si un campo se debe o no guardar en _all se puede utilizar include_in_all. Si es habilitado tiene las siguientes propiedades configurables: store, term_vector, analyzer, index_analyzer y search_analyzer.

**Campo _source**

Permite guardar el documento JSON enviado durante la indexación y si no se define otro campo, puede ser utilizado también para funcionalidades de resaltado (highlighting). como los demás también puede ser deshabilitado al definir el mapa.

**Campo _index**

Guarda información sobre le índice a los cuales los documentos son indexados, por defecto _index no se indexa, para ello se debe especificar.

**Campo _size**

Por defecto no habilitado, si se habilita especifica el tamaño de _source y es almacenado en el documento. Para activarlo

~~~
{
"book" : {
"_size" : {
"enabled": true,
"store" : "yes"
},
"properties" : {
.
.
.
  }
 }
}
~~~

**Campo _timestamp**

Desactivado por defecto. Especifica cuando el documento fue indexado, es solo indexado pero no guardado ni analizado.

**Campo _ttl**

EL tiempo de vida de un documento, por defecto viene desactivado. Si se activa es indexado y guardado, pero no analizado.

~~~
{
"book" : {
"_ttl" : {
"enabled" : true,
"default" : "30d"
},
"properties" : {
.
.
.
  }
 }
}
~~~

### Validar consultas

Las consultas se pueden validar sintácticamente para averiguar si es correcta una consulta o por qué motivo falla.

Sintaxis

~~~
/_validate/query
~~~
~~~
/_validate/query?explain
~~~

~~~
POST /wiki/page/_validate/query?explain
{
  "query": {
    "bool": {
      "must": [
        { "match_phrase": { "text": "He served as alderman and mayor" }},
        { "match_phrase": { "title": "Andrew Johnson" }},
        { "match": { "text": "Ohios John Sherman" }}
      ]
    }
  }
}
~~~

Repuesta (Validación): (Valida la query y la explica)

~~~
{
   "valid": true,
   "_shards": {
      "total": 1,
      "successful": 1,
      "failed": 0
   },
   "explanations": [
      {
         "index": "wiki",
         "valid": true,
         "explanation": "filtered(+text:\"he served as alderman and mayor\" +title:\"andrew johnson\" +(text:ohios text:john text:sherman))->cache(_type:page)"
      }
   ]
}
~~~

### Ordenar respuestas (Sort)

Cuando se ordena una lista de documentos, no se comprueban las puntuaciones, internamente se ponen todas a 1, los JSON resultantes tienen los campos "max_score" y "_score" a null. Si pese a ordenarlos se quiere mostrar también puntuación, se debe utilizar "track_scores". Los resultados devuelven también un nuevo campo "sort" que contiene el valor por el que fue ordenado, en campos de fechas aparecerá el valor en  milisegundos desde epoch.

NOTA: Unix time = POSIX time = Epoch time (erróneamente nombrado).

Si no se indica orden, solo el campo, son ordenados ascendentemente. El _score por defecto es siempre descendente.

~~~
"sort": { "body": { "order": "asc" }} = "sort":  "body"
~~~

También es posible ordenar de manera multinivel, cuando son ordenados por el primer criterio y uno o dos tienen el mismo valor sort, se puede utilizar otro nivel para reoordenar la salida, por ejemplo por puntuación / relevancia "score".

~~~
GET /blog/_search
{
  "query": {
    "bool": {
      "must": [
        { "match": { "body": "should nonummy" }},
        { "match": { "title": "search lorem"  }}
      ]
    }
  }
  ,
    "sort": 
    [
    { "body": { "order": "desc" }},
    { "_score": { "order": "asc" }}
  ]
}
~~~

Cuando se ordena por campos que tienen varios valores, no hay ningún orden establecido, pero para números y fechas se puede utilizar "min", "max","avg" o "sum".

~~~
"sort": {
    "dates": {
        "order": "asc",
        "mode":  "min"
    }
}
~~~

Cuando se ordena por cadenas, estas deben tener un solo término y se puede usar "min" (por defecto) y "max". Los campos string normalmente son analized y por lo tanto son divididos en varios términos. Para solucionar esto, se puede tener el mismo campo con dos propiedades diferentes, una para ser analizado y otra para ser ordenado. Si se quiere poder tener dentro del mismo documento el mismo campo con dos mappings diferentes se debe usar mapping multifield.

~~~
"tweet": { 
    "type":     "string",
    "analyzer": "english",
    "fields": {
        "raw": { 
            "type":  "string",
            "index": "not_analyzed"
        }
    }
}
~~~

  * tweet: full-text y analyzed
  * tweet.raw: full-text y not_analyzed

Ejemplo de uso

~~~
GET /_search
{
    "query": {
        "match": {
            "tweet": "elasticsearch"
        }
    },
    "sort": "tweet.raw"
}
~~~

### Puntuación/Relevancia de los documentos

La puntuación es representada por un número de coma flotante, cuanto más alto, más puntuación y más relevante. La puntuación es aplicada tanto a filtros como a consultas. Para calcular la puntuación se tiene en cuenta lo siguiente.

  * Se basa en la frecuencia con la que un término aparece en un campo (cuanto más mejor).
  * Frecuencia en la que aparece en el índice (cuanto menos documentos contengan dicho valor en el campo, más relevante).
  * Qué largo es el campo donde aparece el termino, cuanto más corto, más relevante. (ej. título y cuerpo).

Para entender como se ha calculado la puntuación para cada resultado devuelto y para depuración, se utiliza: "/_search?explain" o "_search?explain&format=yaml" (más legible) donde se pueden ver la suma de puntuaciones, la frecuencia de los términos en el campo, en los documentos y las dimensiones del campo.

Para saber por qué un documento es o no devuelto por una query, se puede usar "explain". Por ejemplo, veamos la siguiente consulta directamente el campo "_id".

~~~
GET /us/tweet/12
{
   "_index": "us",
   "_type": "tweet",
   "_id": "12",
   "_version": 5,
   "found": true,
   "_source": {
      "date": "2014-09-22",
      "name": "John Smith",
      "tweet": "Elasticsearch and I have left the honeymoon stage, and I still love her.",
      "user_id": 1
   }
}
~~~

~~~
GET /us/tweet/12/_explain
{
   "query" : {
      "filtered" : {
         "filter" : { "term" :  { "user_id" : 4           }},
         "query" :  { "match" : { "tweet" :   "honeyXXXmoon" }}
      }
   }
}
~~~

Devuelve la siguiente explicación. (No se encontró ni el user_id 4 ni la cadena honeyXXXmoon)

~~~
{
   "_index": "us",
   "_type": "tweet",
   "_id": "12",
   "matched": false,
   "explanation": {
      "value": 0,
      "description": "failure to match filter: cache(user_id:[4 TO 4])",
      "details": [
         {
            "value": 0,
            "description": "no matching term"
         }
      ]
   }
}
~~~

### Resaltado de búsquedas (Highlight)

Resaltará mediante la etiqueta HTML "<em>" la cadena "honeymoon" si se devuelve algún resultado tras la query.

~~~
POST /us/tweet/_search
{
  "query": {
    "match": {
      "tweet": "honeymoon"
    }
  },
  "highlight": {
    "fields": {
      "tweet": {}
    }
  }
}
~~~

### Agrupaciones y medias

Muestra al final cuantos empleados hay en cada campo interest y su media de edad.

~~~
GET /megacorp/employee/_search
{
    "aggs" : {
        "all_interests" : {
            "terms" : { "field" : "interests" },
            "aggs" : {
                "avg_age" : {
                    "avg" : { "field" : "age" }
                }
            }
        }
    }
}
~~~

### Estadísticas/Información sobre clúster, índices y nodos

Todos los plugins y herramientas de terceros que muestran gráficas o valores de monitorización obtienen los datos de estas fuentes de información.

**Documentación oficial de ElasticSearch**

[Estado del clúster](https://www.elastic.co/guide/en/elasticsearch/reference/current/cluster-health.html)

[Estadísticas del clúster](https://www.elastic.co/guide/en/elasticsearch/reference/current/cluster-stats.html)

[Estadísticas de nodos](https://www.elastic.co/guide/en/elasticsearch/reference/current/cluster-nodes-stats.html)

[Estadísticas de índices](https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-stats.html)

[Estadísticas amigables (cat API)](https://www.elastic.co/guide/en/elasticsearch/reference/current/cat.html)

**Cluster health API**

Muestra a grandes rasgos el estado de un índice o del clúster mostrando el nombre del clúster, su estado, número de nodos, de shards (asignados y sin asignar), tareas pendientes, etc. 

~~~
# Consultar estado del cluster = Consultar estado de todos los indices separados por comas.
curl -XGET 'http://localhost:9200/_cluster/health?pretty'

# Consultar estado de los índices logstash-2015.08.23 y logstash-2015.08.28.
curl -XGET 'http://localhost:9200/_cluster/health/logstash-2015.08.23,logstash-2015.08.28?pretty'
~~~

**Cluster Stats API**

 Muestra métricas básicas en los índices (número de fragmentos, espacio que ocupan, uso de memoria) e información sobre los nodos actuales que forman el clúster (número y tipo de nodos, sistema operativo, JVM, memoria RAM, CPU y plugins instalados).

~~~
curl -XGET 'http://localhost:9200/_cluster/stats?human&pretty'
~~~

**Nodes Stats API**

Estadísticas por nodo. Retorna los valores de número de indices, sistema operativo (CPU, memoria RAM, swap, etc), procesos, JVM, transporte, conexiones http, sistema de ficheros, breaker y la pila de hilos.

~~~
# Estadísticas de todos los nodos.
curl -XGET 'http://localhost:9200/_nodes/stats?pretty'

# Especificar nodos en concreto.
curl -XGET 'http://localhost:9200/_nodes/nodeId1,nodeId2/stats?pretty'

# Filtrar información mostrando solo lo relativo a las conexiones http y JVM del nodo "es1".
curl -XGET 'http://localhost:9200/_nodes/es1/stats/http,jvm/?pretty'
~~~

**Estadísticas de índices**

Proporciona estadísticas sobre diferentes operaciones realizadas sobre índices.

~~~
# Estadísticas de todos los índices del clúster.
curl -XGET 'http://localhost:9200/_stats?pretty'

# Estadísticas de determinados índices.
curl http://localhost:9200/index1,index2/_stats
~~~

**API cat**

Utilizando esta API se muestra una versión compacta, estadística y amigable de los valores mostrados por las anteriores APIs. Es la API ideal a la hora de querer obtener información desde la terminal. 

  * El parámetro "//?v//" muestra el nombre de la columna.
  * El parámetro "//?h//" permite especificar las cabeceras "//?h=ip,port,heapPercent,name//"
  * El parámetro "//?bytes=b//" permite especificar una unidad de medida (Bytes, Megabytes,..).

~~~
curl -qs http://dominio:9200/_cat
=^.^=
/_cat/allocation
/_cat/shards
/_cat/shards/{index}
/_cat/master
/_cat/nodes
/_cat/indices
/_cat/indices/{index}
/_cat/segments
/_cat/segments/{index}
/_cat/count
/_cat/count/{index}
/_cat/recovery
/_cat/recovery/{index}
/_cat/health
/_cat/pending_tasks
/_cat/aliases
/_cat/aliases/{alias}
/_cat/thread_pool
/_cat/plugins
/_cat/fielddata
/_cat/fielddata/{fields}
~~~

Ejemplos

~~~
curl -qs "http://localhost:9200/_cat/plugins?v"

name          component version        type url              
elastic1      marvel    1.3.1          j/s  /_plugin/marvel/ 
elastic1      kopf      1.5.7-SNAPSHOT s    /_plugin/kopf/   
elastic2      marvel    1.3.1          j/s  /_plugin/marvel/ 


curl -qs "http://localhost:9200/_cat/shards/logstash-2014.11.13/?v"

index               shard prirep state      docs   store ip            node     
logstash-2014.11.13 4     p      STARTED 1366319   618mb 101.50.201.24 elastic3 
logstash-2014.11.13 2     r      STARTED 1366319   618mb 102.50.201.25 elastic1
logstash-2014.11.13 0     r      STARTED 1365753 613.7mb 103.50.201.26 elastic9

~~~

### Administrar Índices con Curator

Cuando se tienen muchos índices o índices indeseados como pueden ser los del plugin marvel, es posible que se necesiten políticas de borrado que se puedan implementar de una forma simple y programada. Para manejar los índices se puede usar la herramienta curator.

Para instalar curator en CentOS es necesario instalar como dependencia `python-pbr`.

~~~
yum install python-pbr
~~~

Instalar/actualizar `curator`.

~~~
pip2 install elasticsearch-curator
pip install -U elasticsearch-curator
~~~

Error el instalar `curator`

~~~
error: invalid command 'egg_info'
~~~

Solución: dos posibilidades.

~~~
# Opción 1.
pip2 install --upgrade setuptools

#  Opción 2
easy_install -U setuptools
~~~

Sintaxis de `curator`

~~~
curator --help
curator COMMAND --help
curator COMMAND SUBCOMMAND --help
~~~

Las opciones "show" y "dry-run" son únicamente informativas y no tienen riesgo.

Borrar todos los índices que tengan más de 30 días y tengan el patrón '%Y.%m.%d' en el nombre.

~~~
curator --host localhost delete indices --older-than 30 --time-unit days --timestring '%Y.%m.%d'
~~~

NOTA: Los índices Kibana son omitidos por defecto.

Borrar todos los índices ".marvel" con un tiempo de vida superior a un día

~~~
curator --host localhost delete indices --older-than 1 --time-unit days --prefix .marvel --timestring %Y.%m.%d
~~~

Mostrar todos los índices con el patrón '%Y.%m.%d'

~~~
curator --host 10.0.0.2 show indices --timestring '%Y.%m.%d'
~~~

Cerrar/abrir un índice cerrado

~~~
curator --host localhost close indices --index "logstash-2015.06.08"
curator --host localhost open indices --index "logstash-2015.06.08"
~~~

### Error de conexión

  * Comprobar que ElasticSearch está corriendo (y en qué puerto) en el sistema y probarlo desde el navegador/curl, no con telnet. Si no contesta se debe reiniciar el servicio de ElasticSearch.
  * Comprobar si se requiere autenticación y se está especificando correctamente el usuario/password.

**Error**

~~~
Error: Got unexpected extra arguments (...)
~~~

**Solución**: Si se usan wildcards, estas deben estar entrecomilladas

~~~
# Mal
curator delete indices --regex .marvel* --older-than 21 --time-unit days --timestring \%Y.\%m.\%d

# Bien
curator delete indices --regex ".marvel*" --older-than 21 --time-unit days --timestring \%Y.\%m.\%d

# Bien (Mismo efecto que el anterior pero sin usar expresiones regulares, solo indicando el prefijo).
curator  --host localhost delete indices  --prefix ".marvel" --older-than 30 --time-unit days --timestring %Y.%m.%d
~~~

## FIN
