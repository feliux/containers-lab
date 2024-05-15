# Kubernetes

**Certs**

```bash
$ openssl x509 -inform der -in file.txt -out file.crt


$ kubectl create configmap-cacerts -n <namespace> --from-file=cacerts=./cacerts-nueva --dry-run=client -o yaml > configmap-cacerts.yaml

$ kubectl create secret tls <secretName> --key=file.key --cert=file.crt -n <namespace> --dry-run=client -o yaml > secret.yaml
```

```bash
$ kubeadm init phase certs all -h
```
