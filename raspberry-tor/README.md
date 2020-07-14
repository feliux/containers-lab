# Navegación anónima con RaspberryPI

Proxy para navegación anónima usando la red **Tor**, **Docker** y **RaspberryPI**.

### Componentes

- RaspberryPI 3 accesible al puerto 8888.

- Imagen docker compuesta por las siguientes herramientas:

    - **Anonsurf:** usa la red [Tor](https://es.wikipedia.org/wiki/Tor_(red_de_anonimato)) para ocultar la IP real y añadir una capa de cifrado al tráfico. Repositorio github [aquí](https://github.com/Und3rf10w/kali-anonsurf).

    - **Tiny proxy:** proxy ligero para navegación HTTP/HTTPS. Página oficial [aquí](https://tinyproxy.github.io/).

### Ejecución

- Creamos la imagen

`docker build -t myproxy .`

- Arrancamos el contenedor

`docker run -it --rm --name myproxy_container -p 8888:8888 --privileged myproxy`

*NOTA:* no se arranca en background con la opción `-d` porque falla cuando lleva un tiempo arrancado sin uso, por lo que mejor ejecutarlo de forma interactiva cada vez que se vaya a utilizar. Con la opción `--rm` se eliminará el contenedor una vez salgamos de él.

### Uso

Lo probaremos en FireFox con el plugin [FoxyProxy Standard](https://addons.mozilla.org/es/firefox/addon/foxyproxy-standard/) en donde indicaremos nuestra RaspberryPI como servidor proxy para la navegación HTTP/HTTPS.

#### Configuración FoxyProxy

Tras la instalación del plugin en el navegador firefox configuraremos los datos de nuestro proxy. Primero indicamos la dirección IP ejecutando `ifconfig` en nuestra Raspberry. Posteriormente añadimos una nueva conexión (pestaña *add* en *options*) con los datos que solicita.

Finalmente podemos consultar la siguiente [web](http://cualesmiip.com/) para ver nuestra IP pública antes y después de activar nuestro proxy.


#### Enlaces de interés

[Fuente](https://www.elladodelmal.com/2020/04/aplicaciones-practicas-de-docker-en.html)

[Anonsurf](https://www.wifi-libre.com/topic-1253-impedir-su-rastreo-en-la-red-con-anonsurf.html)
