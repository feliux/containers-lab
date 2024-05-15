# Kubernetes Lab

Go to [infra-lab](https://github.com/feliux/infra-lab) repository to checkout for IaC deployments. In this repo you will found some cluster deployment using the CLI.

## Services

- **airflow**. Ready production Airflow deployment.
- **argocd**. Install ArgoCD in your cluster.
- **aws**. Deploy an EKS cluster and some extra features.
- **gcp**. Deploy a GKE cluster and some extra features.
- **golang-js-api**. Minimal webpage using Golang API backend server and a JavaScript frontend.
- **k8s-cron-rollout**. Custom distroless images for rollout a k8s deployments. View on [DockerHub](https://hub.docker.com/r/feliux/k8s-cron)
- **kubeflow**. Deploy Kubeflow on AWS.
- **pinponfel**. Personal app.
- **wordpress**.

## References

> GKE

[Go to provider README file](./gcp/README.md)

> EKS

[Go to provider README file](./aws/README.md)

> HardWay

[kubeadm init](https://kubernetes.io/docs/reference/setup-tools/kubeadm/kubeadm-init/)

> SECURITY

[Certificate Management with kubeadm](https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/kubeadm-certs/)

[PKI certificates and requirements](https://kubernetes.io/docs/setup/best-practices/certificates/)

[Update apiserver certificates for HA k8s cluster](https://serverfault.com/questions/1030307/update-apiserver-certificates-for-ha-k8s-cluster)

[Invalid x509 certificate for kubernetes master](https://stackoverflow.com/questions/46360361/invalid-x509-certificate-for-kubernetes-master)

[kube-goat](https://github.com/ksoclabs/kube-goat)

[CertManager tutorials](https://cert-manager.io/docs/tutorials/)

[Free SSL for Kubernetes with Cert-Manager](https://www.youtube.com/watch?v=hoLUigg4V18)

[How-To: Automatic SSL Certificate Management for your Kubernetes Application Deployment](https://medium.com/contino-engineering/how-to-automatic-ssl-certificate-management-for-your-kubernetes-application-deployment-94b64dfc9114)

> NFS

[Kubernetes NFS](https://www.jorgedelacruz.es/2017/12/26/kubernetes-volumenes-nfs/)

[Cómo instalar un servidor y cliente NFS en Ubuntu Server](https://cduser.com/como-instalar-nfs-server-ubuntu-server/)

> MISC

[Translate a Docker Compose File to Kubernetes Resources](https://kubernetes.io/docs/tasks/configure-pod-container/translate-compose-kubernetes/)

> FROM RASPIFEL

[Running kubernetes on Raspberry Pi](https://viktorvan.github.io/kubernetes/kubernetes-on-raspberry-pi)

[Provision Kubernetes NFS clients on a Raspberry Pi](https://opensource.com/article/20/6/kubernetes-nfs-client-provisioning)

[Install a local kubernetes with microk8s](https://discourse.ubuntu.com/t/install-a-local-kubernetes-with-microk8s/13981)

[Kubernetes Network Policies](https://kubernetes.io/docs/concepts/services-networking/network-policies/)

> APPs

[otomi-core: Self-hosted PaaS for Kubernetes](https://github.com/redkubes/otomi-core)

[InfluxDB v2 on Kubernetes](https://cduser.com/como-desplegar-influxdb-2-x-en-kubernetes/)

> Courses and certifications

[Open Source Curriculum for CNCF Certification Courses](https://github.com/cncf/curriculum)

[CKA KodeCloud](https://github.com/kodekloudhub/certified-kubernetes-administrator-course)
