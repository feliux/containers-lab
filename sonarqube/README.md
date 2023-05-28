# Sonarqube

## Deployment

Deploy services running the following command 

```sh
$ docker-compose up -d
```

Because SonarQube uses an embedded Elasticsearch, make sure that your Docker host configuration complies with the Elasticsearch production mode requirements and File Descriptors configuration.

For example, on Linux, you can set the recommended values for the current session by running the following commands as root on the host:

```sh
$ sysctl -w vm.max_map_count=524288
$ sysctl -w fs.file-max=131072
$ ulimit -n 131072
$ ulimit -u 8192
```

Service available on `localhost:9000` with user/password `admin /// admin`.

Run scanner with docker

```sh
docker run \
    --rm \
    -e SONAR_HOST_URL="http://sonarqube:9000" \
    -e SONAR_SCANNER_OPTS="-Dsonar.projectKey=WebGoat" \
    -e SONAR_LOGIN=sqp_5104652f4392a8de0e6d7ac6457b8733dc963315 \
    -v "./:/usr/src" \
    --network sonarqube_default \
    sonarsource/sonar-scanner-cli
```

## References

[DockerHub sonarqube](https://hub.docker.com/_/sonarqube)

[Github docker-sonarqube](https://github.com/SonarSource/docker-sonarqube)

[Install the server](https://docs.sonarqube.org/latest/setup-and-upgrade/install-the-server/)

[Environment variables](https://docs.sonarqube.org/latest/setup-and-upgrade/configure-and-operate-a-server/environment-variables/)

[SonarScanner](https://docs.sonarqube.org/9.9/analyzing-source-code/scanners/sonarscanner/)
