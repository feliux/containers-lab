import argparse
import datetime

from kubernetes import client, config
from kubernetes.client.rest import ApiException


def parse_args():
    parser = argparse.ArgumentParser(description='Rollout a k8s deployment')
    parser.add_argument('-a', '--auth', type=str, required=True, choices=["inside", "outside"],
        help="Specify auth method based on RBAC (inside a pod) or kubeconfig (outside the cluster).")
    parser.add_argument('-ns', '--namespace', type=str, help="K8s namespace.")
    parser.add_argument('-deploy', '--deployment-name', type=str, help="Deployment name to rollout.")
    parser.add_argument('-cc', '--change-cause', type=str, help="Change cause for annotation kubernetes.io/change-cause")
    args = parser.parse_args()
    return args


# https://github.com/kubernetes-client/python/issues/1378
def restart_deployment(v1_apps, namespace: str, deployment: str, change_cause: str):
    now = datetime.datetime.utcnow()
    now = str(now.isoformat("T") + "Z")
    body = {
        "spec": {
            "template":{
                "metadata": {
                    "annotations": {
                        "kubectl.kubernetes.io/restartedAt": now,
                        "kubernetes.io/change-cause": change_cause if change_cause else "cronjob execution"
                    }
                }
            }
        }
    }
    try:
        v1_apps.patch_namespaced_deployment(deployment, namespace, body, pretty="true")
        print(f"Rollout for deployment {deployment} succeeded.\n")
    except ApiException as e:
        print("Exception when calling AppsV1Api -> read_namespaced_deployment_status: %s\n" % e)


def main():
    args = parse_args()
    if args.auth == "inside":
        # create the in-cluster config
        config.load_incluster_config()
    elif args.auth == "outside":
        # create the out-cluster config
        config.load_kube_config()
    v1_apps = client.AppsV1Api()
    restart_deployment(v1_apps, args.namespace, args.deployment_name, args.change_cause)


if __name__ == "__main__":
    main()
