# AWS EKS

Go to [infra-lab](https://github.com/feliux/infra-lab) repository to checkout for IaC deployments.

## Usage

> Install `awscli`. You can install using `pip`, for example `$ python -m venv .aws-env`.

Go to **AWS IAM** and create an user (with *AdministratorAccess*) and then run...

```sh
$ aws configure
$ aws sts get-caller-identity
```

> Install `eksctl` and create a cluster without nodes

```sh
$ eksctl create cluster \
--name test-cluster \
--without-nodegroup \
--region us-east-1 \
--zones us-east-1a,us-east-1b \
--managed

$ kubectl get nodes

./eksctl delete cluster --name test-cluster
```

Cluster config available on `./kube/config`. Create again this file with the following command...

```sh
$ aws eks --region us-east-1 update-kubeconfig --name test-cluster
$ kubectl cluster-info
$ kubectl get svc
```

Visit **CloudFormation** to see cluster information.

> Add nodes to cluster

```sh
$ eksctl create nodegroup \
  --cluster test-cluster \
  --region us-east-1 \
  --name test-workers \
  --node-type t3.medium \
  --node-ami auto \
  --nodes 1 \
  --nodes-min 1 \
  --nodes-max 3 \
  --asg-access # Add autoscaler policy

$ eksctl delete nodegroup \
  --cluster test-cluster \
  --name test-workers \
  --region us-east-1

  eksctl scale nodegroup --cluster=test-cluster --nodes=2 --name=test-workers --nodes-min=1 --nodes-max=3
```

### AutoScaler

[Cluster Autoscaler](https://docs.aws.amazon.com/eks/latest/userguide/cluster-autoscaler.html)

```sh
$ aws iam create-policy \
    --policy-name AmazonEKSClusterAutoscalerPolicy \
    --policy-document file://cluster-autoscaler/cluster-autoscaler-policy.json

$ eksctl create iamserviceaccount \
  --cluster=test-cluster \
  --namespace=kube-system \
  --name=cluster-autoscaler \
  --attach-policy-arn=arn:aws:iam::197372856450:policy/AmazonEKSClusterAutoscalerPolicy \
  --override-existing-serviceaccounts \
  --approve

# If fails then run
# eksctl utils associate-iam-oidc-provider --region=us-east-1 --cluster=test-cluster --approve

$ kubectl apply -f cluster-autoscaler/cluster-autoscaler-autodiscover.yaml # Look for luster name: test-cluster

$ kubectl annotate serviceaccount cluster-autoscaler \
  -n kube-system \
  eks.amazonaws.com/role-arn=arn:aws:iam::197372856450:role/AWSServiceRoleForAutoScaling

$ kubectl patch deployment cluster-autoscaler \
  -n kube-system \
  -p '{"spec":{"template":{"metadata":{"annotations":{"cluster-autoscaler.kubernetes.io/safe-to-evict": "false"}}}}}'

$ kubectl -n kube-system edit deployment.apps/cluster-autoscaler
```

Add your cluster name and add the following tow lanes

~~~
  - --node-group-auto-discovery=asg:tag=k8s.io/cluster-autoscaler/enabled,k8s.io/cluster-autoscaler/<YOUR CLUSTER NAME> # Look for luster name: test-cluster
  - --balance-similar-node-groups
  - --skip-nodes-with-system-pods=false
~~~

### Load Balancer

[AWS Load Balancer Controller](https://docs.aws.amazon.com/eks/latest/userguide/aws-load-balancer-controller.html)

> Create IAM OIDC provider if not exists

```sh
$ aws eks describe-cluster \
--name test-cluster \
--query "cluster.identity.oidc.issuer" \
--output text

$ aws iam list-open-id-connect-providers

# If empty then
$ eksctl utils associate-iam-oidc-provider --cluster test-cluster --approve
```

> Download and create an IAM policy for the AWS Load Balancer Controller that allows it to make calls to AWS APIs on your behalf. Then create an IAM role and annotate the Kubernetes service account

```sh
$ curl -o alb/iam_policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.1.3/docs/install/iam_policy.json

$ aws iam create-policy \
    --policy-name AWSLoadBalancerControllerIAMPolicy \
    --policy-document file://alb/iam_policy.json

$ eksctl create iamserviceaccount \
  --region=us-east-1 \
  --cluster=test-cluster \
  --namespace=kube-system \
  --name=aws-load-balancer-controller \
  --attach-policy-arn=arn:aws:iam::197372856450:policy/AWSLoadBalancerControllerIAMPolicy \
  --override-existing-serviceaccounts \
  --approve
```

> Install cert-manager to inject certificate configuration into the webhooks

```sh
# https://github.com/jetstack/cert-manager/releases/download/v1.1.1/cert-manager.yaml
$ kubectl apply --validate=false -f alb/cert-manager.yaml
```

> Download the controller specification.

```sh
$ curl -o alb/v2_1_3_full.yaml https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.1.3/docs/install/v2_1_3_full.yaml
```

> Make the following edits to the `v2_1_3_full.yaml` file:

- Delete the `ServiceAccount` section from the specification. Doing so prevents the annotation with the IAM role from being overwritten when the controller is deployed and preserves the service account that you created before.

- Set the `--cluster-name` value to your Amazon EKS cluster name in the `Deployment container args` section.

```sh
$ kubectl apply -f alb/v2_1_3_edited.yaml
$ kubectl get deployment -n kube-system aws-load-balancer-controller
```

> Test simple app

```sh
$ kubectl apply -f k8s/test/2048_full.yaml
$ kubectl get ingress -n game-2048
```

### Storage

[EKS Storage classes](https://docs.aws.amazon.com/eks/latest/userguide/storage-classes.html)

[aws-ebs-csi-driver](https://github.com/kubernetes-sigs/aws-ebs-csi-driver)

```sh
$ kubectl get storageclass

$ curl -o storage/example-iam-policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-ebs-csi-driver/v0.9.0/docs/example-iam-policy.json

$ aws iam create-policy \
  --policy-name AmazonEKS_EBS_CSI_Driver_Policy \
  --policy-document file://storage/example-iam-policy.json

$ aws iam create-role \
  --role-name AmazonEKS_EBS_CSI_DriverRole \
  --assume-role-policy-document file://storage/trust-policy.json

$ aws iam attach-role-policy \
  --policy-arn arn:aws:iam::197372856450:policy/AmazonEKS_EBS_CSI_Driver_Policy \
  --role-name AmazonEKS_EBS_CSI_DriverRole

$ kubectl apply -k "github.com/kubernetes-sigs/aws-ebs-csi-driver/deploy/kubernetes/overlays/stable/?ref=master"

$ kubectl annotate serviceaccount ebs-csi-controller-sa \
  -n kube-system \
  eks.amazonaws.com/role-arn=arn:aws:iam::197372856450:role/AmazonEKS_EBS_CSI_DriverRole

$ kubectl get po -A
```

> Test MySQL database

```sh
$ kubectl apply -f k8s/test/mysql.yaml
$ kubectl exec -it mysql-pod -- mysql -h mysql -pdbpassword11
mysql> show schemas;
```

## References

> EKS

[EKS](https://docs.aws.amazon.com/eks/latest/userguide/getting-started.html)

[Provisioning Kubernetes clusters on AWS with Terraform and EKS](https://learnk8s.io/terraform-eks)

[Secure Access to Kubernetes Deployment Endpoints on Amazon EKS](https://betterprogramming.pub/secure-access-to-kubernetes-deployment-endpoints-on-amazon-eks-4826a8e87c6f)

> AWS CLI

[AWS Command Line Interface](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-welcome.html)

[AWS CLI Github](https://hub.docker.com/r/amazon/aws-cli)

[AWS CLI PyPi](https://pypi.org/project/awscli/)

[eksctl Documentation](https://eksctl.io/introduction/)

[eksctl install](https://docs.aws.amazon.com/eks/latest/userguide/eksctl.html)

[eksctl Github](https://github.com/weaveworks/eksctl)

> SECURITY

[AWS ALB Ingress Controller - Implement HTTP to HTTPS Redirect](https://www.stacksimplify.com/aws-eks/aws-alb-ingress/learn-to-enable-ssl-redirect-in-alb-ingress-service-on-aws-eks/)

[How do I terminate HTTPS traffic on Amazon EKS workloads with ACM?](https://aws.amazon.com/premiumsupport/knowledge-center/terminate-https-traffic-eks-acm/)

[Securing EKS Ingress With Contour And Let’s Encrypt The GitOps Way](https://aws.amazon.com/blogs/containers/securing-eks-ingress-contour-lets-encrypt-gitops/)

> EC2

[Amazon EC2 Instance Types](https://aws.amazon.com/ec2/instance-types/)

[Instance Type Explorer](https://aws.amazon.com/ec2/instance-explorer/?ec2-instances-cards.sort-by=item.additionalFields.category-order&ec2-instances-cards.sort-order=asc&awsf.ec2-instances-filter-category=*all&awsf.ec2-instances-filter-processors=*all&awsf.ec2-instances-filter-accelerators=*all&awsf.ec2-instances-filter-capabilities=*all)
