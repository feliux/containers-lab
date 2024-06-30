#!/bin/bash
# https://armin.su/generate-eks-static-kubeconfig-files-that-do-not-expire-a6f888a51e79
set -e
set -o pipefail

SERVICE_ACCOUNT_NAME="felix-admin"
NAMESPACE="kube-system"
TARGET_FOLDER="/tmp/kube"
KUBECFG_FILE_NAME="/tmp/kube/kubeconfig-${SERVICE_ACCOUNT_NAME}-${NAMESPACE}.yaml"

test_current_kubeconfig() {
    echo -e -n "\\nTrying to get resources using current Kubeconfig..."
    kubectl get pods --all-namespaces
    printf "done"
}

create_target_folder() {
    echo -n "Creating target directory to hold files in ${TARGET_FOLDER}..."
    mkdir -p ${TARGET_FOLDER}
    printf "done"
}

create_namespace() {
    echo -e "\\nCreating Namespace ${NAMESPACE}"
    kubectl create namespace "${NAMESPACE}"
}

create_service_account() {
    echo -e "\\nCreating a service account in ${NAMESPACE} namespace: ${SERVICE_ACCOUNT_NAME}"
    kubectl create sa "${SERVICE_ACCOUNT_NAME}" --namespace "${NAMESPACE}"
}

create_cluster_role_binding() {
    echo -e "\\nCreating a cluster role binding cluster-admin"
    kubectl create clusterrolebinding ${SERVICE_ACCOUNT_NAME}-admin-cluster-role-binding \
    --clusterrole cluster-admin --user "system:serviceaccount:${NAMESPACE}:${SERVICE_ACCOUNT_NAME}"
}

get_secret_name_from_service_account() {
   echo -e "\\ncreating secret for ${SERVICE_ACCOUNT_NAME} in ${NAMESPACE}"
   rm tmp.file || true
   echo -e "apiVersion: v1\nkind: Secret\ntype: kubernetes.io/service-account-token\nmetadata:\n name: cicd\n annotations:\n kubernetes.io/service-account.name: \"cicd\"" >> tmp.file
   kubectl apply -f tmp.file
   rm tmp.file
   SECRET_NAME=${SERVICE_ACCOUNT_NAME}
}

extract_ca_crt_from_secret() {
    echo -e -n "\\nExtracting ca.crt from secret..."
    kubectl get secret --namespace "${NAMESPACE}" "${SECRET_NAME}" -o json | jq \
    -r '.data["ca.crt"]' | base64 -d > "${TARGET_FOLDER}/ca.crt"
    printf "done"
}

get_user_token_from_secret() {
    echo -e -n "\\nGetting user token from secret..."
    USER_TOKEN=$(kubectl get secret --namespace "${NAMESPACE}" "${SECRET_NAME}" -o json | jq -r '.data["token"]' | base64 -d)
    printf "done"
}

set_kube_config_values() {
    context=$(kubectl config current-context)
    echo -e "\\nSetting current context to: $context"
    CLUSTER_NAME=$(kubectl config get-contexts "$context" | awk '{print $3}' | tail -n 1)
    echo "Cluster name: ${CLUSTER_NAME}"
    ENDPOINT=$(kubectl config view \
    -o jsonpath="{.clusters[?(@.name == \"${CLUSTER_NAME}\")].cluster.server}")
    echo "Endpoint: ${ENDPOINT}"
    # Set up the config
    echo -e "\\nPreparing k8s-${SERVICE_ACCOUNT_NAME}-${NAMESPACE}-conf"
    echo -n "Setting a cluster entry in kubeconfig..."
    kubectl config set-cluster "${CLUSTER_NAME}" \
    --kubeconfig="${KUBECFG_FILE_NAME}" \
    --server="${ENDPOINT}" \
    --certificate-authority="${TARGET_FOLDER}/ca.crt" \
    --embed-certs=true
    echo -n "Setting token credentials entry in kubeconfig..."
    kubectl config set-credentials \
    "${SERVICE_ACCOUNT_NAME}-${NAMESPACE}-${CLUSTER_NAME}" \
    --kubeconfig="${KUBECFG_FILE_NAME}" \
    --token="${USER_TOKEN}"
    echo -n "Setting a context entry in kubeconfig..."
    kubectl config set-context \
    "${SERVICE_ACCOUNT_NAME}-${NAMESPACE}-${CLUSTER_NAME}" \
    --kubeconfig="${KUBECFG_FILE_NAME}" \
    --cluster="${CLUSTER_NAME}" \
    --user="${SERVICE_ACCOUNT_NAME}-${NAMESPACE}-${CLUSTER_NAME}" \
    --namespace="${NAMESPACE}"
    echo -n "Setting the current-context in the kubeconfig file..."
    kubectl config use-context "${SERVICE_ACCOUNT_NAME}-${NAMESPACE}-${CLUSTER_NAME}" \
    --kubeconfig="${KUBECFG_FILE_NAME}"
}

test_generated_kubeconfig() {
    echo -e -n "\\nTrying to get resources using generated Kubeconfig..."
    KUBECONFIG=${KUBECFG_FILE_NAME} kubectl get pods --all-namespaces
    printf "done"
}

copy_generates_kubeconfig() {
    echo -e -n "\\nCopying kubeconfig file to local path...\n"
    cp ${KUBECFG_FILE_NAME} .
    rm -Rf ${TARGET_FOLDER}
    printf "done\n"
}

echo
echo "Generate administrative Kubeconfig file for your cluster"
echo
echo "This script generates a Kubeconfig file that allows full administrative access to your cluster"
echo "Please note that this creates a Kubernetes service account '${SERVICE_ACCOUNT_NAME}' with *CLUSTER-ADMIN* role in the '${NAMESPACE}' namespace."
echo
read -p "Proceed?[Y/n]  " -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]

then
    test_current_kubeconfig
    create_target_folder
    create_namespace || true 
    create_service_account || true
    create_cluster_role_binding || true
    get_secret_name_from_service_account
    extract_ca_crt_from_secret
    get_user_token_from_secret
    set_kube_config_values
    test_generated_kubeconfig
    copy_generates_kubeconfig
fi
