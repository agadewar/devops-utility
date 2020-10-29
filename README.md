**NOTE** : Need Ubuntu app in your windows machine so that it works as a Linux client and you can run the required commands via cli.
Reference link : https://ubuntu.com/tutorials/ubuntu-on-windows#1-overview

**Pre-requisites** : 
- How to install Azure CLI,
*Run command* : 
    
    curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

- How to install Kubectl,
*Run commands* :

    curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
    
    chmod +x ./kubectl
    
    sudo mv ./kubectl /usr/local/bin/kubectl
    
    kubectl version

- How to install jq,
*Run commands* :

    sudo apt-get install jq

    jq --version

- For making the Prometheus-AlertManager up and running from your machine,
*Run command* : 

    ./ps_prometheus_alertmanager.sh

    What will the above script do? - 
It will first get access credentials for the Production AKS.
Then start the Prometheus-AlertManager UI.
And at last will delete the context of Production to avoid any discrepancies.