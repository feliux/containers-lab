# Stack ELK

Configuración Docker para el conjunto **Elastic - Logstash - Kibana**. Incluye también un *compose* para **Filebeat** y **Metricbeat**.

La configuración propuesta monitoriza el directorio Docker. Por un lado, Filebeat recoge los logs de nuestros contenedores, y por otro Metricbeat monitoriza su estado. El flujo de datos sería el siguiente:

~~~
Docker-logs -> Filebeat -> Logstash -> Elastic <-> Kibana

Docker-stasts -> Metricbeat -> Elastic <-> Kibana
~~~

Si se desea dar otro uso entonces habría que añadir/cambiar los archivos de configuración de cada servicio así como el *compose* correspondiente. En el apartado **Enlaces de interés** se aportan enlaces a la guía de Filebeat y Metricbeat donde podemos ver otros inputs, módulos, etc.

## Ejecución

Para arrancar los servicios ELK

`docker-compose up -d`

- **Filebeat**

`docker-compose -f docker-compose-filebeat.yml up -d`

O bien todo a la vez (ELK + Filebeat)

`docker-compose -f docker-compose.yml -f docker-compose-filebeat.yml up -d`

- **Metricbeat**. Necesario esperar al menos 60s para que Kibana esté disponible, de lo contrario no se iniciará. Una posible mejora sería configurar un entrypoint que permita controlar la ejecución. Más info en el siguiente [enlace](https://docs.docker.com/compose/startup-order/)

`docker-compose -f docker-compose-metricbeat.yml up -d`

### Extra. Docker command

```sh
$ docker pull docker.elastic.co/elasticsearch/elasticsearch:7.6.0
$ docker pull docker.elastic.co/kibana/kibana:7.6.0

$ docker network create --driver bridge elastic-net

$ docker run --network=elastic-net -d --name elasticsearch -p 9200:9200 -p 9300:9300 -e "discovery.type=single-node" elasticsearch:7.6.0
$ docker run --link <elastic-container-name-or-ID>:elasticsearch -p 5601:5601 kibana:7.6.0
$ docker run --network=elastic-net -d --name kibana -p 5601:5601 kibana:7.6.0

$ curl -XGET 'http://127.0.0.1:9200/megacorp/employee/1' -H 'Content-Type: application/json' -d '{"query":{"match_all":{}}}'
```

Servicios disponibles es

~~~
http://localhost:5601/app/kibana
http://localhost:9200/
~~~

## Uso

Podemos comprobar los *índices* disponibles con el siguiente comando. Las credenciales de acceso se encuentran en los archivos de configuración. Por defecto hemos puesto `elastic // changeme`

`curl 'localhost:9200/_cat/indices?v' -u elastic:changeme`

---

<img src="./images/index-management.png" width="1100" height="500">

---

## Visualización. Kibana

Kibana estará accesible en `localhost:5601`.

- **Filebeat**. Debemos configurar los *índices* antes de poder visualizarlos en Kibana. Para ello nos dirigimos a *Stack Management* y luego a *Index Patterns*. Seleccionamos la opción *Create index pattern*

---

<img src="./images/index-pattern.png" width="1100" height="500">

<img src="./images/index-pattern-2.png" width="1100" height="500">

---

- **Metricbeat**. La configuración del *índice* es automática una vez arrancado el servicio

---

<img src="./images/index-pattern-metric.png" width="1100" height="500">

---

Podemos seleccionar un *dashboard* pre-configurado para visualizar las estadísticas de nuestros contenedores (activado en la configuración de Metricbeat)

---

<img src="./images/dashboard.png" width="1100" height="350">

<img src="./images/dashboard-2.png" width="1100" height="500">

---

## Enlaces de interés

[Elastic](https://www.elastic.co/guide/en/elasticsearch/reference/current/docker.html)

[Logstash](https://www.elastic.co/guide/en/logstash/current/docker.html)

[Kibana](https://www.elastic.co/guide/en/kibana/current/docker.html)

[Filebeat](https://www.elastic.co/guide/en/beats/filebeat/current/running-on-docker.html)

[Filebeat Inputs](https://www.elastic.co/guide/en/beats/filebeat/current/filebeat-input-docker.html)

[Metricbeat](https://www.elastic.co/guide/en/beats/metricbeat/current/running-on-docker.html)

[Metricbeat Modules](https://www.elastic.co/guide/en/beats/metricbeat/current/metricbeat-modules.html)
