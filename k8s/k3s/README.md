# K3s

Execute a k3s cluster.

**Installing from script**

```sh
# https://docs.k3s.io/installation/configuration#configuration-with-install-script
$ curl -sfL https://get.k3s.io | sh -
# All the K3s libraries are found in the lib directory
$ tree -L 2 /var/lib/rancher/k3s
# The script configure systemd for controling k3s
$ systemctl status k3s --no-pager
```

**Installing from binary**

```sh
# $ sudo ./k3s server -c ./config.yaml
$ sudo K3s_CONFIG_FILE=./config.yaml ./k3s server
# Or
$ sudo ./k3s server \
	--write-kubeconfig-mode "0644" \
	--tls-san "cluster.k3s.local" \
	--node-label "cluster=master" \
	--node-label "server=true" \
	--cluster-init
$ kubectl --kubeconfig /etc/rancher/k3s/k3s.yaml get pods --all-namespaces

$ alias k="kubectl --kubeconfig /etc/rancher/k3s/k3s.yaml"

$ sudo ls -l /var/lib/rancher/k3s
$ sudo ls -l /etc/rancher
```

**Installing with docker-compose**

```sh
$ K3S_TOKEN=${RANDOM}${RANDOM}${RANDOM} K3S_VERSION=v1.30.2-k3s1 docker-compose up
$ kubectl --kubeconfig kubeconfig.yaml get po -A
```

**Commands**

```sh
$ k3s --version
$ k3s check-config
$ k3s kubectl version
$ k3s kubectl get nodes | grep -z 'STATUS\|Ready'
$ kubectl get nodes -o wide
$ kubectl cluster-info

# In the Kubelet, the containerd container runtime engine generates logs
$ tail /var/lib/rancher/k3s/agent/containerd/containerd.log
# This gives you a few K3s and Kubernetes techniques to inspect the status of a cluster
```

**Add nodes**

```sh
$ curl -sfL https://get.k3s.io | INSTALL_K3S_SKIP_ENABLE=true INSTALL_K3S_SKIP_START=true sh -

# Start the server executing this from the controlplane
$ k3s server > /var/log/k3s_server.log 2>&1 &
$ k3s kubectl get nodes | grep -z 'STATUS\|Ready'
# Configure the cluster token in the new node
$ ssh -q node01 "echo \"export K3S_TOKEN=$(cat /var/lib/rancher/k3s/server/node-token)\" >> ~/.bashrc"

# Add node executing this from the terminal node
$ export K3S_URL=https://$(dig <ControlplaneUrl> a +short | tail -n1):6443 && echo $K3S_URL
$ k3s agent --server $K3S_URL --token $K3S_TOKEN > /var/log/k3s_agent.log 2>&1 &
```

## References

[K3s doc](https://docs.k3s.io/)

[K3s github](https://github.com/k3s-io/k3s)

[K3s docker image](https://hub.docker.com/r/rancher/k3s)
