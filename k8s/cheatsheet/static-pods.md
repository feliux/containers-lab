# Static Pods

The kubelet systemd process is configured to run static Pods from the `/etc/kubernetes/manifests` directory.

On the control node, static Pods are an essential part of how Kubernetes works: `systemd starts kubelet`, and kubelet starts core Kubernetes services as static Pods.

Administrators can manually add static Pods if so desired, just copy a manifest file into the `/etc/kubernetes/manifests` directory and the kubelet process will pick it up.

To modify the path where Kubelet picks up the static Pods, edit `staticPodPath` in `/var/lib/kubelet/config.yaml` and use `sudo systemctl restart kubelet` to restart. **Never do this on the control node**.
