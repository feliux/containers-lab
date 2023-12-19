# Firefox

```sh
$ docker build -t firefox .
$ docker run -d --name firefox -ti -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix -v $(pwd)/Downloads-firefox:/home/firefox/Downloads firefox

$ docker rm $(docker stop firefox)

$ docker run --rm --name firefox_bash -it firefox:latest bash
```

# Chrome

Chrome needs run with `--privileged` tag (Kernel/network reasons)

```sh
$ docker build -t chrome .
$ docker run -d --name chrome -ti -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix -v $(pwd)/Downloads-chrome:/home/chrome/Downloads --privileged chrome

$ docker rm $(docker stop chrome)

$ docker run --rm --name chrome_bash -it chrome:latest bash
```
