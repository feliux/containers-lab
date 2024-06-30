# Nginx

This is a demo for demostrating how ingress works. For a production installation follow the official documentation [here](https://docs.nginx.com/nginx-ingress-controller/installation/installing-nic/)

```sh
$ helm upgrade --install ingress-nginx ingress-nginx \
    --repo https://kubernetes.github.io/ingress-nginx \
    --namespace ingress-nginx \
    --create-namespace
$ kubectl get pods -n ingress-nginx

# Create a sample pod
$ kubectl create deploy nginxsvc --image=nginx --port=80
$ kubectl expose deploy nginxsvc
$ kubectl get all --selector app=nginxsvc

# Create the ingress
$ kubectl create ingress nginxsvc --class=nginx --rule=nginxsvc.info/*=nginxsvc:80
$ kubectl get ingressclass -o yaml
# $ kubectl port-forward -n ingress-nginx svc/ingress-nginx-controller 8080:80
$ echo "127.0.0.1 nginxsvc.info" >> /etc/hosts # fake DNS
$ curl nginxsvc.info:8080

# Differents paths can be defined on the same host
$ kubectl create ingress myingress --rule="/path1=mysvc1:80" --rule="/path2=mysvc2:80"
# Different virtual hosts can be defined in the same Ingress
$ kubectl create ingress nginxsvc --class=nginx --rule=nginxsvc.info/*=nginxsvc:80 --rule=otherserver.org/*=otherserversvc:80
```

Set `ingressclass.kubernetes.io/is-default-class: true` as an annotation on the IngressClass to make it the default.
