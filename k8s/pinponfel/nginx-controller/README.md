
```sh
$ wget https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v0.47.0/deploy/static/provider/cloud/deploy.yaml

# Get external IP
$ kubectl get svc -n ingress-nginx

# Set IP to static
$ gcloud compute addresses create nginx-ingress-lb --addresses 35.193.148.207 --region us-central1
```

## References

[Nginx controller. Static IPs](https://kubernetes.github.io/ingress-nginx/examples/static-ip/)
