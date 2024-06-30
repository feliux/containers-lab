# K3s

Execute a k3s cluster.

```sh
# Installing with script
$ curl -sfL https://get.k3s.io | sh -
# All the K3s libraries are found in the lib directory
$ tree -L 2 /var/lib/rancher/k3s
# The script configure systemd for controling k3s
$ systemctl status k3s --no-pager

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

**New nodes**

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
