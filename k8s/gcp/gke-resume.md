# GKE

1. Create the cluster

```sh
$ export my_zone=us-central1-a
$ export my_cluster=standard-cluster-1

$ gcloud container clusters create $my_cluster --num-nodes 3 --machine-type=e2-medium --enable-ip-alias --zone $my_zone --enable-network-policy
```

2. Connect to the cluster from local machine

```sh
$ docker pull gcr.io/google.com/cloudsdktool/cloud-sdk:345.0.0
$ docker run -ti --name gcloud-config gcr.io/google.com/cloudsdktool/cloud-sdk gcloud auth login
$ docker run --rm --volumes-from gcloud-config gcr.io/google.com/cloudsdktool/cloud-sdk gcloud config set project learning-310712
$ docker run --rm --volumes-from gcloud-config gcr.io/google.com/cloudsdktool/cloud-sdk gcloud container clusters get-credentials standard-cluster-1 --zone us-central1-a
$ docker run --rm --volumes-from gcloud-config gcr.io/google.com/cloudsdktool/cloud-sdk kubectl config view --raw

$ docker run -it --rm --volumes-from gcloud-config gcr.io/google.com/cloudsdktool/cloud-sdk bash
```

3. Next steps:

- Install nginx-controller.
    - Set IP to static.
    - Registry IP to domain name.
- Install argocd.
- Deploy apps
