echo "Get access credentials for the Production AKS."
az aks get-credentials --subscription 43e0bf01-5025-40ce-bdaa-c4291177828a --resource-group prod-us --name prod-us

echo "The Prometheus-AlertManager UI can be seen by visiting: http://localhost:9093/#/alerts"
kubectl --kubeconfig .local/kubeconfig port-forward `. get_one_pod_name_by_ns_and_label.sh monitoring app=alertmanager` -n monitoring 9093

echo "Deleting the Production context from kubectl config to avoid any discrepancies"
kubectl config delete-context prod-us