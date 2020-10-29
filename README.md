Pre-requisites : 
- How to install Azure CLI
Run command : 

curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

- How to install Kubectl
Run commands :

curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl

chmod +x ./kubectl

sudo mv ./kubectl /usr/local/bin/kubectl

kubectl version

- For making the Prometheus-AlertManager up and running from your machine.
Run command : 

./ps_prometheus_alertmanager.sh

NOTE : It will first get access credentials for the Production AKS.
Then start the Prometheus-AlertManager UI.
And at last will delete the context of Production to avoid any discrepancies.