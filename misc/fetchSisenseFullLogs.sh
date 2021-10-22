#!/bin/bash
namespace=$1
fluentdspod=$(kubectl get pods -n $namespace --selector='k8s-app=fluentd' --no-headers -o custom-columns=":metadata.name")
#------------------------
echo $fluentdspod
#Create Zip in pod
kubectl -n $namespace exec -t $fluentdspod -- bash -c "echo 'Started Zipping the folder' ; cd /var/log/sisense/ ; tar -zcvf $namespace.tar.gz $namespace"

#Download Created zip from pod to local
echo 'Downloading zip file to local system'
dir=sisense-logs-$(date +"%d-%m-%Y")
if [ -d $dir ]; then
  echo folder exists
  echo 'Cleaning folder'
  cd sisense-logs-$(date +"%d-%m-%Y")
  rm $namespace.tar.gz
else
  echo creating directory
  mkdir sisense-logs-$(date +"%d-%m-%Y")
  cd sisense-logs-$(date +"%d-%m-%Y")
fi
kubectl -n $namespace cp $fluentdspod:/var/log/sisense/$namespace.tar.gz $namespace.tar.gz
echo 'Logs are available at' `pwd`/sisense-logs-$(date +"%d-%m-%Y")

#remove zip file from Pod 
echo 'Removing temp zip file from POD'
kubectl -n $namespace exec -t $fluentdspod -- bash -c "cd /var/log/sisense/ ; rm $namespace.tar.gz"