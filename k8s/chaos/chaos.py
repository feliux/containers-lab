from kubernetes import client, config
import random

# Access Kubernetes
config.load_incluster_config()
v1 = client.CoreV1Api()

# List Namespaces
all_namespaces = v1.list_namespace()

# Get Pods from namespaces annotated with chaos marker
pod_candidates = []
for namespace in all_namespaces.items:
    if (    namespace.metadata.annotations is not None 
        and namespace.metadata.annotations.get("chaos", None) == 'yes'
       ):
        pods = v1.list_namespaced_pod(namespace.metadata.name)
        pod_candidates.extend(pods.items)

# Determine how many Pods to remove
removal_count = random.randint(0, len(pod_candidates))
if len(pod_candidates) > 0:
    print("Found", len(pod_candidates), "pods and melting", removal_count, "of them.")
else:
    print("No eligible Pods found with annotation chaos=yes.")

# Remove a few Pods
for _ in range(removal_count):
    pod = random.choice(pod_candidates)
    pod_candidates.remove(pod)
    print("Removing pod", pod.metadata.name, "from namespace", pod.metadata.namespace, ".")
    body = client.V1DeleteOptions()
    v1.delete_namespaced_pod(pod.metadata.name, pod.metadata.namespace, body=body)
