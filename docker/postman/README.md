# Postman

```sh
$ docker build -t postman .
$ docker run -d --name postman -ti -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix -v $(pwd)/Projects-postman:/home/postman/Projects --privileged postman

# Sincronizar Chrome con Postman
# Abrir Chrome y registrarse. Sincroinzar abrir chrome://apps. Abrir Postman (puede cerrar el contenedor)
$ docker start postman
# Si no está la app de Postman con la cuenta de google
# Icono de usuario en Chrome sobre el Chrome nativo. Administrar usuarios. Añadir perfil. Seleccionar icono y añadir el perfil
```
