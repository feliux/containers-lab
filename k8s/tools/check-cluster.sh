
# Check k8s cluster
{ clear && \
    echo -e "\n=== Kubernetes Status ===\n" && \
    kubectl get --raw '/healthz?verbose' && \
    kubectl version --short && \
    kubectl get nodes && \
    kubectl cluster-info; 
} | grep -z 'Ready\| ok\|passed\|running'
