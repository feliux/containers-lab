# KubeFlow

## Deploy

```sh
$ export AWS_CLUSTER_NAME=kubeflow
$ export AWS_REGION=us-west-2
$ export K8S_VERSION=1.18
$ export EC2_INSTANCE_TYPE=m5.large

# Create the cluster
$ ./eksctl create cluster -f cluster.yaml

# Requirements
$ curl -o aws-iam-authenticator https://amazon-eks.s3.us-west-2.amazonaws.com/1.21.2/2021-07-05/bin/linux/amd64/aws-iam-authenticator
$ chmod +x ./aws-iam-authenticator

$ export AWS_CLUSTER_NAME=kubeflow-demo
$ mkdir $AWS_CLUSTER_NAME
$ cd $AWS_CLUSTER_NAME
$ wget https://github.com/kubeflow/kfctl/releases/download/v1.2.0/kfctl_v1.2.0-0-gbc038f9_linux.tar.gz
$ tar -xvf kfctl_v1.2.0_<platform>.tar.gz
$ wget https://raw.githubusercontent.com/kubeflow/manifests/v1.2-branch/kfdef/kfctl_aws.v1.2.0.yaml
```

By default, the username is set to `admin@kubeflow.org` and the password is `12341234`. To secure your Kubeflow deployment, change this configuration.

```sh
$ aws eks update-kubeconfig --name kubeflow-demo --kubeconfig kubeflow/conf_AWS --region us-west-2

$ kfctl apply -V -f kfctl_aws.yaml
$ kubectl -n kubeflow get all
$ kubectl get ingress -n istio-system
```

## References

[KubeFlow AWS](https://www.kubeflow.org/docs/distributions/aws/deploy/install-kubeflow/)

[KubeFlow examples for financial sectos](https://github.com/kubeflow/examples/tree/master/financial_time_series)
