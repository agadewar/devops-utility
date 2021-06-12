#!/bin/bash 
az account set --subscription b78a61e7-f2ed-4cb0-8f48-6548408935e9
resourceGroup=$2
action=$1
instances=$(az vm show -d --ids $(az vm list -g load-us --query "[].id" -o tsv) | grep 'computerName' | grep 'psr' | grep -v '001' |awk '{print $2}' | sed -e 's/"//g' | sed -e 's/,//g')

#--------------------------------------------------------------------------------
startInstance() {
    for instanceName in $instances 
    do
    az vm start --name $instanceName --resource-group $resourceGroup 
    az vm list-ip-addresses --name $instanceName --resource-group $resourceGroup | grep ipAddress 
    done
}

stopInstance() {
   for instanceName in $instances 
   do
   echo Stopping $instanceName
   az vm deallocate --name $instanceName --resource-group $resourceGroup 
   done
}

if [[ $action == "start" ]]; then
echo starting $instanceName
echo 'starting all psr instances'
startInstance

elif [[ $action == "stop" ]]; then
echo $instanceName
echo 'stopping all psr instances'
stopInstance

else
echo 'No valid action specified'
fi

#--------------------------------------------------------------------------------