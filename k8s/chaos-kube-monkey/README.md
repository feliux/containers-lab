# Kube Monkey

Kube Monkey is an implementation of Netflix’s chaos monkey for Kubernetes clusters. It periodically schedules a list of Pod termination events to test the fault tolerance of your highly available system.

```sh
$ git clone https://github.com/asobti/kube-monkey && pushd kube-monkey/helm

$ helm install my-monkey kubemonkey \
    --namespace kube-monkey \
    --create-namespace \
    -f ../../my-monkey-values.yaml

# Return to the default directory
$ popd
# Check the deployment and ensure it starts
$ kubectl -n kube-monkey rollout status deployment my-monkey-kube-monkey

$ kubectl logs -f deployment.apps/my-monkey-kube-monkey -n kube-monkey
```

Start the chaos.

```sh
$ kubectl apply -f nginx.yaml
$ kubectl create namespace more-apps
$ kubectl create --namespace more-apps -f ghost.yaml
# The Deployments and Pods are labeled to mark these Pods as potential victim targets of the Kube Monkey Pod killer
$ watch kubectl get deployments,pods --all-namespaces -l app-purpose=chaos
```

## References

[kube-monkey](https://github.com/asobti/kube-monkey)
