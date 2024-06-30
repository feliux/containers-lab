# ETCD Control

`etcdctl` is the CLI tool used to interact with ETCD.

`etcdctl` can interact with ETCD Server using two API versions (Version 2 and Version 3). By default its set to use Version 2. Each version has different sets of commands.

```sh
# Install
$ apt install etcd-client

# Version 2 supports the following commands
$ etcdctl backup
$ etcdctl cluster-health
$ etcdctl mk
$ etcdctl mkdir
$ etcdctl set
```


```sh
# Install
$ apt install etcd-client

# Whereas the commands are different in version 3
$ etcdctl snapshot save 
$ etcdctl endpoint health
$ etcdctl get
$ etcdctl put
```

To set the right version of API set the environment variable ETCDCTL_API command

```sh
$ export ETCDCTL_API=3
$ export ETCDCTL_API=3 etcdctl snapshot save
```

When API version is not set, it is assumed to be set to version 2. And version 3 commands listed above don't work. When API version is set to version 3, version 2 commands listed above don't work.

Apart from that, you must also specify path to certificate files so that ETCDCTL can authenticate to the ETCD API Server. The certificate files are available in the etcd-master at the following path. We discuss more about certificates in the security section of this course. So don't worry if this looks complex:

```sh
# --cacert /etc/kubernetes/pki/etcd/ca.crt     
# --cert /etc/kubernetes/pki/etcd/server.crt     
# --key /etc/kubernetes/pki/etcd/server.key

# Certificates can be found with
$ ps aux | grep etcd

# Below is the final form
$ kubectl exec etcd-master -n kube-system -- sh -c "ETCDCTL_API=3 etcdctl get --prefix --keys-only --limit=10 --cacert /etc/kubernetes/pki/etcd/ca.crt --cert /etc/kubernetes/pki/etcd/server.crt  --key /etc/kubernetes/pki/etcd/server.key"

# Get the keys
$ sudo ETCDCTL_AP=3 etcdct --endpoints=localhost:2379 \
    --cacert /etc/kubernetes/pki/etcd/ca.crt \
    --cert /etc/kubernetes/pki/etcd/server.crt \
    --key /etc/kubernetes/pki/etcd/server.key \
    get / --prefix --keys-only

# Backup
$ sudo ETCDCTL_API=3 etcdctl \
    --endpoints=localhost:2379 \
    --cacert /etc/kubernetes/pki/etcd/ca.crt \
    --cert /etc/kubernetes/pki/etcd/server.crt \
    --key /etc/kubernetes/pki/etcd/server.key \
    snapshot save /tmp/etcdbackup.db

# Verify the backup
$ sudo ETCDCTL_API=3 etcdctl \
    --write-out=table snapshot status /tmp/etcdbackup.db

# Restore backup
$ sudo ETCDCTL_API=3 etcdctl \
    snapshot restore /tmp/etcdbackup.db \
    --data-dir /var/lib/etcd-backup

# To start using it, core k8s services must be stopped
$ kubecti delete --all deploy
# To stop core services, temporarily move /etc/kubernetes/manifests/*yaml to /etc/kubernetes/
$ cd /etc/kubernetes/manifests/
$ sudo mv * .. # this will stop all running pods
# As the kubelet process temporarily polls for static Pod files, the etcd process will disappear within a minute
$ crictl ps # to verify that is has been stopped
# Once the etcd Pod has stopped, reconfigure the etcd to use the non-default etcd path
$ sudo ETCDCTL_API=3 etcdctl snapshot restore /tmp/etcdbackup.db --data-dir /var/lib/etcd-backup
$ sudo ls -l /var/lib/etcd-backup/
# In etcd.yaml you'll find a HostPath volume with the name etcd-data, pointing to the location where the Etcd files are found. Change this to the location where the restored files are
$ sudo vim /etc/kubernetes/etcd.yaml # change etcd-data HostPath volume to /var/lib/etcd-backup
# Move back the static Pod files to /etc/kubernetes/manifests/
$ sudo mv ../*.yaml .
$ crictl ps # to verify the Pods have restarted successfully
$ kubectl get all # should show the original Etcd resources
```
