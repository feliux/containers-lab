# Container Decomposing

A container image is a TAR file containing other TAR files. Internally, each TAR file is a layer. TAR files are often referred as tarballs. Once all TAR files have been extracted to a local filesystem, you can explore the details of the layers.

```sh
$ docker image pull redis:6.2.6-alpine3.15
# Export the image into a raw TAR format
$ docker image save redis:6.2.6-alpine3.15 > redis.tar
# Create a scratch location to inspect the Redis files
$ mkdir redis && cd redis
# Extract the files from the TAR
$ tar -xvf ../redis.tar
# All of the contents, along with the layer TAR files, are now viewable
$ tree
```

The image includes the `manifest.json` file that defines the metadata about the image, such as version information and tag names. The schema for the `manifest.json` file follows the OCI specification.

```sh
$ cat manifest.json | jq .
# Extracting a layer will reveal the specific files contained for that layer
$ mkdir last-layer && tar -xvf $(cat manifest.json | jq -j '.[].Layers | last') -C last-layer
# Inspect the files in the last layer
$ tree last-layer
last-layer
└── usr
    └── local
        └── bin
            └── docker-entrypoint.sh
```

This single file makes sense because it's the last instruction in the Redis Dockfile that would cause a layer to be created, on the last line here.

**Creating an Empty Image**

A container image is a TAR of TAR files with some metadata. Therefore, an empty image can be created using the combined tar and docker image import commands.

```sh
# cat <archive_name> | docker image import -m <comment or message> - <image_name>
$ tar cv --files-from /dev/null | docker import - empty
sha256:932b1c4e402bdaa7c25bb2b0a251bb5567e4572c52dd9d3c7debe11e410d1a7a
$ docker image ls
REPOSITORY   TAG                IMAGE ID       CREATED          SIZE
empty        latest             932b1c4e402b   12 seconds ago   0B
$ $ docker container run empty
docker: Error response from daemon: No command specified.
```

**Package Image without Dockerfile**

The previous idea of importing a TAR file can be extended to create an entire image from scratch.

Next, we'll use [BusyBox](https://busybox.net/) as the base to create a functional container by just using this `tar` and `import` technique.

```sh
# Running the script will download the main BusyBox binaries and the rootfs for the container image
$ ./busybox-static.sh busybox
$ ls -lha busybox
# Load an additional text file into the BusyBox directory
$ echo "Hello world!" > busybox/blurb.txt
# As before, the directory can be converted into a tarball and imported into Docker as an image
$ tar --directory=busybox --create --dereference . | docker import - busybox
$ docker image ls busybox
$ docker container run busybox cat /blurb.txt
Hello world!

# All the other BusyBox commands are also available
$ docker container run busybox /bin/sh -c "uname -a; env"
$ docker container run busybox /bin/sh -c "busybox --list"
```

## Dive

[Dive](https://github.com/wagoodman/dive) is a tool for exploring a container image, viewing layer contents, and discovering ways to shrink the size of your OCI image.

```sh
$ DIVE_VERSION=0.12.0
$ wget -q https://github.com/wagoodman/dive/releases/download/v${DIVE_VERSION}/dive_${DIVE_VERSION}_linux_amd64.deb
$ apt -qq install ./dive_${DIVE_VERSION}_linux_amd64.deb
$ dive --version
```

Dive runs in two modes: with an interactive text user interface (TUI) in the shell, or as a command-line tool tuned for integration into your continuous integration pipelines.


```sh
$ dive redis
$ dive empty
$ dive busybox
$ dive bitnami/kafka:3.1.0
```

The tool also allows you to select and delete files or directories from the layers. This can help you understand how to trim your containers. Dive can be a handy tool for experimenting, but you should refrain from using this UI as part of your continuous delivery process. The real trimming should happen when you define the containers with infrastructure-as-code.

**Tuning containers**

Let's build two container images with the same Python code to illustrate the process for tuning containers.

```sh
$ docker image build -t fibonacci-a --file Dockerfile-a .
$ docker image build -t fibonacci-b --file Dockerfile-b .
$ docker container run fibonacci-a
$ docker container run fibonacci-b
# The first ten Fibonacci numbers are produced
$ dive fibonacci-a -j dive-report-a.json
$ echo "Container Image a" && \
echo "              Size: $(cat dive-report-a.json | jq .image.sizeBytes) bytes" && \
echo "       Inefficient: $(cat dive-report-a.json | jq .image.inefficientBytes) bytes" && \
echo "Inefficiency score: $(cat dive-report-a.json | jq .image.efficiencyScore)" && \
echo "" && echo "Container Image b" && \
echo "              Size: $(cat dive-report-b.json | jq .image.sizeBytes) bytes" && \
echo "       Inefficient: $(cat dive-report-b.json | jq .image.inefficientBytes) bytes" && \
echo "Inefficiency score: $(cat dive-report-b.json | jq .image.efficiencyScore)"
```

With this tool you can add thresholds to these values. You can be notified or force your pipeline to stop when newly built container image exceed your acceptable limits. This in turn can save you money by not wasting cloud resources (CPU, memory, and I/O) when your containers scale across your cluster. Documentation on Dive's CI Integration is found here.

## References

[Dive](https://github.com/wagoodman/dive)

[Dive CI integration](https://github.com/wagoodman/dive#ci-integration)

[Broken by default: why you should avoid most Dockerfile examples](https://pythonspeed.com/articles/dockerizing-python-is-hard/)
