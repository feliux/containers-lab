# ZAP Scan

Zed Attack Proxy (ZAP) is a free, open-source penetration testing tool being maintained under the umbrella of the Open Web Application Security Project (OWASP). ZAP is designed specifically for testing web applications and is both flexible and extensible.

## Usage

### CLI

~~~
$ docker run -i owasp/zap2docker-stable zap-cli quick-scan --self-contained \
    --start-options '-config api.disablekey=true' http://target
~~~

### UI

~~~
$ docker-compose up -d
~~~

ZAP vailable on `localhost:8080/zap`

## References

[ZAP Docker](https://www.zaproxy.org/docs/docker/about/)

[ZAP Docker UI](https://www.zaproxy.org/docs/docker/webswing/)