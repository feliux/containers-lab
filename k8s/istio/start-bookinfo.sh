#!/bin/bash

# Prior to the Bookinfo install, add a namespace label to instruct Istio to 
# automatically inject Envoy sidecar proxies when you deploy the 
# Bookinfo application into the _default_ namespace:
kubectl label namespace default istio-injection=enabled

# Start Bookinfo Application
kubectl apply -f istio-$ISTIO_VERSION/samples/bookinfo/platform/kube/bookinfo.yaml

# Define the ingress gateway for the application:
kubectl apply -f istio-$ISTIO_VERSION/samples/bookinfo/networking/bookinfo-gateway.yaml

kubectl apply -f istio-$ISTIO_VERSION/samples/bookinfo/networking/destination-rule-all.yaml
