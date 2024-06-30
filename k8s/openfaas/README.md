# OpenFaaS

Deploy OpenFaaS on k8s.

```sh
# Create and configure two namespaces, one for the OpenFaaS core services openfaas and a second for the functions openfaas-fn
$ kubectl apply -f https://raw.githubusercontent.com/openfaas/faas-netes/master/namespaces.yml

# Generate and submit a Kubernetes secret for basic authentication for the gateway.
# The secret is named basic-auth and OpenFaaS will use that key when it prompts you for access
$ PASSWORD=$(head -c 12 /dev/urandom | shasum | cut --delimiter=' ' --fields=1 | head -c 4)
# The random password is shortened to just 4 characters for these demonstration purposes.
# Normally head -c 4 would be omitted
$ kubectl -n openfaas create secret generic basic-auth --from-literal=basic-auth-user=admin --from-literal=basic-auth-password=$PASSWORD
```

It's helpful to have a container registry during the build, push, and deploy phases. There is no need to shuttle private images over the internet. Instead, we keep all this pushing and pulling in a local registry

```sh
$ helm repo add twuni https://helm.twun.io && helm repo list
$ helm install registry twuni/docker-registry \
	--version 2.1.0 \
	--namespace kube-system \
	--set service.type=NodePort \
	--set service.nodePort=31500
$ kubectl get service --namespace kube-system
# Assign an environment variable to the common registry location
$ export REGISTRY=<RegistryClusterUrl>
$ kubectl get deployments registry-docker-registry --namespace kube-system
# Once the registry is available, inspect the contents of the empty registry
$ curl $REGISTRY/v2/_catalog | jq -c
```

Now we can install OpenFaaS

```sh
$ helm repo add openfaas https://openfaas.github.io/faas-netes && helm repo list
$ VERSION=10.0.21
# PRO Edition
$ helm install openfaas openfaas/openfaas \
	--version $VERSION \
	--namespace openfaas \
	--set functionNamespace=openfaas-fn \
	--set operator.create=true \
	--set basic_auth=true \
	--set rbac=false \
	--set faasIdler.dryRun=false \
	--set faasIdler.inactivityDuration=10s
# Community Edition
$ helm install openfaas openfaas/openfaas \
	--version $VERSION \
	--namespace openfaas \
	--set functionNamespace=openfaas-fn \
	--set basic_auth=true \
	--set rbac=false \
	--set faasIdler.dryRun=false \
	--set faasIdler.inactivityDuration=10s
$ watch kubectl get deployments --namespace=openfaas

# Openfaas cli
$ curl -SLs cli.openfaas.com | sudo sh
$ faas-cli list
# However, faas-cli cannot work until you login to the gateway. Commands like this will report unauthorized access
```

At this point there is an OpenFaaS gateway providing access to both the portal and REST API to manage the functions and OpenFaaS. Most of the CLI commands require this gateway as a parameter. To reduce the verbosity the gateway here is stored as an environment variable

```sh
$ kubectl get service --namespace openfaas
$ export OPENFAAS_URL=<OpenfaasClusterUrl>
$ PASSWORD=$(kubectl -n openfaas get secret basic-auth -o jsonpath="{.data.basic-auth-password}" | base64 --decode) && echo "OpenFaaS admin password: $PASSWORD"
$ faas-cli login --username admin --password="$PASSWORD"
$ faas-cli list
```

A variety of pre-built functions are available in the OpenFaaS store. The Function Store is a curated index of OpenFaaS functions which have been tested by the community and chosen for their experience. List the functions in the store

```sh
$ faas-cli store list | grep -z 'ASCII Cows'
# Deploy the Cows function and invoke it a few times
$ faas-cli store deploy "ASCII Cows"
$ echo 10 | faas-cli invoke cows
$ kubectl get services,pods --namespace openfaas-fn
$ kubectl get service --namespace openfaas-fn
```

Create the structure and files for a new function

```sh
$ faas-cli new fibonacci --lang python3 --prefix $REGISTRY/fibonacci --gateway $OPENFAAS_URL
$ cp fibonacci.py fibonacci/handler.py
$ faas-cli up -f fibonacci.yml
$ curl $REGISTRY/v2/_catalog | jq
$ echo 5 | faas-cli invoke fibonacci
# If you update the function logic, then redeploy with the --update=false --replace switches
# faas-cli up -f fibonacci.yml --update=false --replace
```

The Helm chart sets up a Prometheus service, but it's not exposed. The Prometheus service can be exposed by changing the service from a ClusterIP type to a NodePort type.

```sh
$ kubectl patch service prometheus --namespace=openfaas --type='json' --patch='[{"op": "replace", "path": "/spec/type","value":"NodePort"}]'
# Then change the NodePort value to a known port above 30000
$ kubectl patch service prometheus --namespace=openfaas --type='json' --patch='[{"op": "replace", "path": "/spec/ports/0/nodePort", "value":31120}]'
```

As above, the Helm chart also sets up an AlertManager service. It is also not exposed. The AlertManager service can be exposed by changing the service from a ClusterIP type to a NodePort type.

```sh
$ kubectl patch service alertmanager --namespace=openfaas --type='json' --patch='[{"op": "replace", "path": "/spec/type","value":"NodePort"}]'
# Then change the NodePort value to a known port above 30000
$ kubectl patch service alertmanager --namespace=openfaas --type='json' --patch='[{"op": "replace", "path": "/spec/ports/0/nodePort", "value":31121}]'
```

There is a helpful Grafana container configured for OpenFaaS that we can install.

```sh
$ kubectl -n openfaas run --image=stefanprodan/faas-grafana:4.6.3 --port=3000 grafana
# Expose the dashboard as a service on a known port
$ kubectl -n openfaas expose pod grafana --type=NodePort --name=grafana
$ kubectl patch service grafana --namespace=openfaas --type='json' --patch='[{"op": "replace", "path": "/spec/ports/0/nodePort", "value":31122}]'
```

## References

[OpenFaaS docs](https://docs.openfaas.com/)

[OpenFaaS github](https://github.com/openfaas/faas)

[OpenFaaS helm](https://artifacthub.io/packages/helm/openfaas/openfaas)

[faas-netes](https://github.com/openfaas/faas-netes)

[faas-cli](https://github.com/openfaas/faas-cli)

[faas-netes vs OpenFaaS Operator](https://github.com/openfaas/faas-netes/tree/master/chart/openfaas#faas-netes-vs-openfaas-operator)
