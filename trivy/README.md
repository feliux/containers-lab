# Scan vulnerabilities with Trivy

Set the Docker image to scan with the option `command: image --ignore-unfixed postgres:13`. In this case Trivy scan a PostgreSQL image donwloaded previously on local machine. Then just run the Trivy image with

~~~
$ docker-compose up
~~~

Follow the reference to see more command options.

## References

[Trivy Documentation](https://aquasecurity.github.io/trivy/v0.16.0/)

[Trivy Github](https://github.com/aquasecurity/trivy)

[Trivy Docker Hub](https://hub.docker.com/r/aquasec/trivy)