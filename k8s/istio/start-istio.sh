#!/bin/bash

curl -L https://istio.io/downloadIstio | sh -
export PATH="$PATH:/$PWD/istio-${ISTIO_VERSION}/bin"
istioctl install --set profile=demo -y

# Fixes the "<pending>" state found with this inspection: kubectl get service istio-ingressgateway -n istio-system
INGRESS_HOST=$(hostname -I | awk '{print $1}')

cat <<EOF >>patch.yaml
spec:
  externalIPs: 
    - $INGRESS_HOST
EOF

kubectl patch service -n istio-system istio-ingressgateway --patch "$(cat patch.yaml)"

kubectl get deployments,services -n istio-system

# Install Istio integrations
SEMVER_REGEX='[^0-9]*\([0-9]*\)[.]\([0-9]*\)[.]\([0-9]*\)\([0-9A-Za-z-]*\)'
INTEGRATIONS_VERSION=$(echo $ISTIO_VERSION | sed -e "s#$SEMVER_REGEX#\1#").$(echo $ISTIO_VERSION | sed -e "s#$SEMVER_REGEX#\2#")

# Prometheus and Grafana
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-$INTEGRATIONS_VERSION/samples/addons/prometheus.yaml
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-$INTEGRATIONS_VERSION/samples/addons/grafana.yaml

## Install Jaeger integration
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-$INTEGRATIONS_VERSION/samples/addons/jaeger.yaml

# Workaround kiali known bug, just apply twice
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-$INTEGRATIONS_VERSION/samples/addons/kiali.yaml
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-$INTEGRATIONS_VERSION/samples/addons/kiali.yaml

kubectl apply -f dashboards.yaml