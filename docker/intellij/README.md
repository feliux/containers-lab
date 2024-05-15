# Intellij

```sh
# Share Projects-intellij path with intellij home
$ docker run -d --name intellij -ti -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix -v $(pwd)/Projects-intellij:/home/intellij intellij

# Script for running the app
$ sudo bash -c 'cat << EOF > /bin/intellij-docker
#!/bin/bash
docker start intellij
EOF'
```
