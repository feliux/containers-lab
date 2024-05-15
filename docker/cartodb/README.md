# CartoDB

```sh
$ sudo sh -c 'echo 127.0.1.1 cartodb.localhost >> /etc/hosts'

$ docker pull sverhoeven/cartodb
$ docker run -d --name cartodb -h cartodb.localhost -p 80:80 sverhoeven/cartodb:latest
```

Servicio disponible en

~~~
http://cartodb.localhost/
dev /// pass1234
~~~

## References

[CartoDB](https://hub.docker.com/r/sverhoeven/cartodb/)
