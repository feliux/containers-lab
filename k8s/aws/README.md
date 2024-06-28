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

You can set the kubeconfig as...

```sh
export region_code=eu-west-1
export cluster_name=<clusterName>
export account_id=<accountId>
export role=>awsRole>

$ cluster_endpoint=$(aws eks describe-cluster \
    --region $region_code \
    --name $cluster_name \
    --query "cluster.endpoint" \
    --output text)

$ certificate_data=$(aws eks describe-cluster \
    --region $region_code \
    --name $cluster_name \
    --query "cluster.certificateAuthority.data" \
    --output text)

$ aws --region $region_code eks get-token --cluster-name $cluster_name --role arn:aws:iam::$account_id:role/$role

# extras
# To see the certificate data
$ aws eks describe-cluster --name $cluster_name --query "cluster.certificateAuthority.data" --output text | base64 --decode > eks.crt
$ cat eks.crt
$ openssl x509 -in eks.cert -text -noout
```

- CLI

```sh
#!/bin/bash
read -r -d '' KUBECONFIG <<EOF
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: $certificate_data
    server: $cluster_endpoint
  name: arn:aws:eks:$region_code:$account_id:cluster/$cluster_name
contexts:
- context:
    cluster: arn:aws:eks:$region_code:$account_id:cluster/$cluster_name
    user: arn:aws:eks:$region_code:$account_id:cluster/$cluster_name
  name: arn:aws:eks:$region_code:$account_id:cluster/$cluster_name
current-context: arn:aws:eks:$region_code:$account_id:cluster/$cluster_name
kind: Config
preferences: {}
users:
- name: arn:aws:eks:$region_code:$account_id:cluster/$cluster_name
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1beta1
      command: aws
      args:
        - --region
        - $region_code
        - eks
        - get-token
        - --cluster-name
        - $cluster_name
        # - --role
        # - "arn:aws:iam::$account_id:role/my-role"
      # env:
        # - name: "AWS_PROFILE"
        #   value: "aws-profile"
EOF
echo "${KUBECONFIG}" > ~/.kube/config
```

- aws-iam-authenticator

```sh
#!/bin/bash
read -r -d '' KUBECONFIG <<EOF
apiVersion: v1
clusters:
- cluster:
    server: $cluster_endpoint
    certificate-authority-data: $certificate_data
  name: arn:aws:eks:$region_code:$account_id:cluster/$cluster_name
contexts:
- context:
    cluster: arn:aws:eks:$region_code:$account_id:cluster/$cluster_name
    user: arn:aws:eks:$region_code:$account_id:cluster/$cluster_name
  name: arn:aws:eks:$region_code:$account_id:cluster/$cluster_name
current-context: arn:aws:eks:$region_code:$account_id:cluster/$cluster_name
kind: Config
preferences: {}
users:
- name: arn:aws:eks:$region_code:$account_id:cluster/$cluster_name
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1beta1
      command: aws-iam-authenticator
      args:
        - "token"
        - "-i"
        - "$cluster_name"
        # - "--role"
        # - "arn:aws:iam::$account_id:role/my-role"
      # env:
        # - name: "AWS_PROFILE"
        #   value: "aws-profile"
EOF
echo "${KUBECONFIG}" > ~/.kube/config
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

$ eksctl scale nodegroup --cluster=test-cluster --nodes=2 --name=test-workers --nodes-min=1 --nodes-max=3
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
