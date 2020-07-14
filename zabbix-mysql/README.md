# Monitorización Zabbix

Imagen Docker para arrancar **Zabbix** en un contenedor.

### Ejecución

Para arrancar el servicio

`docker-compose up -d`

Los archivos de configuración `conf/zabbix-server.cof` y `conf/zabbix-conf.conf` contienen las variables de conexión a la base de datos. Dichas variables se definen como variables de entorno en `mysql.env` por lo que tiene que haber una correspondencia entre dichos archivos si queremos cambiar credenciales y nombre de la database de MySQL.

### Uso

Accedemos a `http://localhost/zabbix` con las credenciales `admin // zabbix`

#### Enlaces de interés

[Zabbix](https://es.wikipedia.org/wiki/Zabbix)
