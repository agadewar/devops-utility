#!/bin/bash
echo 'Getting credentials'
az account set --subscription 43e0bf01-5025-40ce-bdaa-c4291177828a
az aks get-credentials --resource-group sisense-prod-us-black --name sisense-prod-us-black

#------------------------
namespace='kube-system'
log=$1
#logspath='/var/log/sisense/sisense-prod/'
fluentdspod=$(kubectl get pods -n $namespace --selector='k8s-app=fluentd' --no-headers -o custom-columns=":metadata.name")
#------------------------
dir=sisense-logs-$(date +"%d-%m-%Y")
if [ -d $dir ]; then
  echo folder exists
else
  echo creating directory
  mkdir sisense-logs-$(date +"%d-%m-%Y")
fi
cd sisense-logs-$(date +"%d-%m-%Y")
echo $fluentdspod
kubectl -n $namespace cp $fluentdspod:/var/log/sisense/sisense-prod/$log $log
echo logs downloaded

#End
