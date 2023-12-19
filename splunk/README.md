# Splunk Docker

## Usage

Splunk available on `localhost:8000` with following credentials `admin // changeme`

### Extra

```sh
$ docker pull splunk/splunk:latest
$ docker network create --driver bridge splunk-net

$ docker run -d -e "SPLUNK_START_ARGS=--accept-license" -e "SPLUNK_USER=<user>" -e "SPLUNK_PASSWORD=<password>"  -v /home/<user>/<path>:/opt/splunk/var -- network splunk-net -p 8000:8000 --name splunk splunk/splunk:latest
$ docker run -d -e "SPLUNK_START_ARGS=--accept-license" -e "SPLUNK_PASSWORD=<password>"  -v /home/<user>/<path>:/opt/splunk/var -- network splunk-net -p 8000:8000 --name splunk splunk/splunk:latest

$ wget http://localhost:8000
```

## References

[Splunk DockerHub](https://hub.docker.com/r/splunk/splunk)

[Splunk Docker Documentation](https://splunk.github.io/docker-splunk/)

[Splunk Apps](https://splunkbase.splunk.com/)

[Splunk Machine Learning Video Lessons](https://www.youtube.com/playlist?list=PLxkFdMSHYh3Q1jwpgJJ0ZSnRzZIx2c_KM)

[Tutorial](https://medium.com/@mosesnandwa/splunk-clustering-using-docker-60c44b029d56)

[Splunk Dev](https://dev.splunk.com/enterprise/)

[Splunk Docker Custom](https://habr.com/ru/post/447532/)
