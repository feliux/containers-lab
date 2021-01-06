# Minio - Docker - Python

Ejemplo de uso de **Minio** para guardar artefactos: *docker images* & *python packages*.

## Ejecución

Para iniciar servicios `docker-compose up -d`

### Minio

Minio estará disponible en `localhost:9000` con credenciales `changeme /// changeme` tomadas del fichero `minio.env`. Para poder guardar nuestros artefactos en Minio debemos antes crear los correspondientes *buckets*, que en nuestro caso serán `docker` para almacenar las imágenes docker y `python` para guardar nuestros paquetes.

### Docker Registry

Una vez creados los buckets podemos guardar los artefactos. Empezaremos por las imágenes docker

~~~
$ docker pull hello-world
$ docker image tag hello-world localhost:5000/hello-world
$ docker push localhost:5000/hello-world
~~~

Finalmente podemos comprobar que la imagen se ha guardado correctamente accediento al portal web de Minio y ejecutando

~~~
$ docker rmi localhost:5000/hello-world
$ docker pull localhost:5000/hello-world
$ docker run localhost:5000/hello-world
~~~

### Python package

En el directorio `./package` se encuentra la estructura típica de un paquete PyPi. Se rata de un módulo `helloworld` instalable mediante `pip`. El paquete se encuentra en el directorio `package/dist` tras ejecutar la siguiente instrucción

~~~
$ cd package
$ python setup.py sdist --formats=gztar
o bien
$ python setup.py sdist bdist_wheel
~~~

Si quisieramos instalar el paquete de prueba

~~~
$ pip install helloworld-0.0.1.tar.gz
$ python -c "from helloworld import SayHello; SayHello()"
~~~

Para almacenar el paquete en Minio tenemos el script `to_minio.py`

~~~
$ python to_minio.py
~~~

## Referencias

[Minio Python Client](https://docs.min.io/docs/python-client-api-reference.html)

[Python Package Distribution](https://docs.python.org/3/distutils/sourcedist.html)

[Build PyPi Package](https://docs.gitlab.com/ee/user/packages/pypi_repository/index.html)

[PyPi dotenv](https://pypi.org/project/python-dotenv/)
