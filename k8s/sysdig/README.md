## Sysdig helm


You can download the official helm with the commands below

```sh
$ helm repo add sysdig https://charts.sysdig.com
$ helm repo update
$ helm pull sysdig/sysdig-deploy
$ tar -xvzf sysdig-deploy-1.52.6.tgz
```

Go to [./README_SYSDIG.md](./README_SYSDIG.md) for reading the official helm documentation.

## Deploy

First, create the following resources.

```bash
# If there is a values file by environment
$ ENV=dev envsubst < myfile.yaml | kubectl apply -f -
```

- [Proxy configMap](./cm-proxy.yaml)
- K8s secrets with sysdig tokens

```yaml
apiVersion: v1
kind: Secret
type: Opaque
metadata:
  name: sysdig-agent-secret
  namespace: sysdig-$ENV
data:
  AUTH_BEARER_TOKEN: changeme
  SECURE_API_TOKEN: changeme
  access-key: changeme
```

## Firewall rules

[Sysdig regions](https://docs.sysdig.com/en/docs/administration/saas-regions-and-ip-ranges/)
