# K8s cronjob

Custom distroless images for rollout k8s deployments.

**View on [DockerHub](https://hub.docker.com/r/feliux/k8s-cron)**

## How to use this image

```bash
$ docker build --no-cache -t feliux/k8s-cron:<version>-golang .
$ docker build --no-cache -t feliux/k8s-cron:<version>-python .

$ docker push feliux/k8s-cron:<version>-golang
$ docker push feliux/k8s-cron:<version>-python

# Change values on sa and cronjob yaml
# create the service account
$ kubectl apply -f sa.yaml
# create the cronjob
$ kubectl apply -f cronjob.yaml

# check the rollout
$ kubectl -n <YOUR NAMESPACE> rollout history deployment/<YOUR DEPLOYMENT NAME>
```

**Others interesting images**

- Rollout deployments

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: restart-deployment
  namespace: <YOUR NAMESPACE>
rules:
  - apiGroups: ["apps", "extensions"]
    resources: ["deployments"]
    resourceNames: ["<YOUR DEPLOYMENT NAME>"]
    verbs: ["get", "patch", "list", "watch"]
---
...
          containers:
            - name: kubectl
              image: bitnami/kubectl 
              command:
                - 'kubectl'
                - 'rollout'
                - 'restart'
                - 'deployment/<YOUR NAMESPACE>'
```

- Rollout deployments waiting for the deployment to roll out, we must change change the command of cronjob

```yaml
          containers:
            - name: kubectl
              image: bitnami/kubectl
              command:
                - bash
                - -c
                - >-
                  kubectl rollout restart deployment/<YOUR DEPLOYMENT NAME> &&
                  kubectl rollout status deployment/<YOUR DEPLOYMENT NAME>
```

- Deleting pods

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: deleting-pods
  namespace: <YOUR NAMESPACE>
rules:
  - apiGroups: [""]
    resources: ["pods"]
    verbs: ["get", "patch", "list", "watch", "delete"]
---
...
          containers:
            - name: kubectl
              image: bitnami/kubectl
              command: [ "/bin/sh", "-c" ]
              args: 
                - 'kubectl delete pod $(kubectl get pod -l app=<your_label> -o jsonpath="{.items[0].metadata.name}")'
```

## References

[K8s client-go](https://github.com/kubernetes/kubernetes)

[K8s client-python](https://github.com/kubernetes-client/python)

[Using RBAC Authorization](https://kubernetes.io/docs/reference/access-authn-authz/rbac/)

[Google distroless images](https://github.com/GoogleContainerTools/distroless)

[K8s Labels/Annotations/Taints](https://kubernetes.io/docs/reference/labels-annotations-taints/)
