# NFS provisioner

Configure a NFS storage class provisioner.

```sh
# On control node
$ sudo apt install nfs-server -y
# On other nodes
$ sudo apt install nfs-client
# On control node
$ sudo mkdir /nfsexport
$ sudo sh -c 'echo "/nfsexport *(rw,no_root_squash)" > /etc/exports'
$ sudo systemctl restart nfs-server
# On other nodes
$ showmount -e <control_IP>

$ helm repo add nfs-subdir-external-provisioner https://kubernetes-sigs.github.io/nfs-subdir-external-provisioner/
$ helm install nfs-subdir-external-provisioner nfs-subdir-external-provisioner/nfs-subdir-external-provisioner --set nfs.server=<control_IP> --set nfs.path=/nfsexport
$ kubectl get po
$ kubectl get pv # verify no currents pv available
$ kubectl apply -f nfs-provisiones-pvc.yaml
$ kubectl get pv,pvc
```

If we do not specify a default storageClass (see `another-pvc.yaml`)...

```sh
$ kubectl apply -f another-pvc.yaml
$ kubectl get pvc # will show pending: there is no default StorageClass
$ kubectl describe pvc another-nfs-pvc
$ kubectl get storqgeclasses.storage.k8s.io -o yaml
$ kubectl patch storageclass <storageClassName> -p '{"metadata":"annotations": ["storageclass.kubernetes.io/is-default-class":"true"}!'
$ kubectl get pvc # will now work
```
