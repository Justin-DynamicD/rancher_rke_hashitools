# rancher-rke-hashitools

This was inspired from a client request, a short review of Rancher documentation, and quite a bit of concepts from
[terraform-vsphere-kubespray](https://github.com/sguyennet/terraform-vsphere-kubespray).

In short, while Rancher is a great tool for managing K8S deployments, and even capable of using native AKS, they actually recommend making the rancher server itself on classic VMs to ensure Rancher has complete access to all aspects of the k8s cluster. What's more, an RKE deployment uses 3 nodes with manager and worker nodes combined. So with a little inspiration and some spare time, I decided to create a Terraform template to perform a complete deployment.

The Terraform plan assumes a custom image has been made, so a packer template was created and placed in `packer/ubunutu.json` for quick provisioning of a server with docker installed and kubernetes repos added. Basically all the pre-reqs RKE would require.

The plan itself has the following characteristics:
- At it's core, uses Terraform, Packer and RKE to perform a complete deployment
- by default it deploys across 3 availability zones for maximum resilience.
- it assumes network vnet/subnets already exist, following [Microsoft zonal deployment Recomendations](https://docs.microsoft.com/en-us/azure/virtual-network/nat-overview#regional-or-zone-isolation-with-availability-zones)
- if only 1 subnet/zone is defined, zonal deployment i disabled
- rke configuration files as well as default k8s credentials are stored in `/config`. This directory is cleared on destroy.
- An AzureAD Application Account is created for RKE and granted Owner rights to the subscription to allow it to create more clusters.
- At this time RKE is _not_ bootstrapped. It's trivial enough that it wasn't worth the headache.

## Requirements

The machine you are running from must be a linux instance (or in WSL2 on Windows) and will need the below list installed in order to function. Versions listed are what's been tested, others may be compatible :

- Azure CLI >= 2.4
- Git
- Kubectl
- helm >= v3.2.0
- rke >= v0.2.10
- Terraform >= v0.12
- Unzip >= 6.0

Be aware that this was tested on Ubunutu 18.04 LTS, so to get things running there may be another tool or two out there dependign on distro. Below are the quick-install instructions:

### Azure CLI
```
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
```
### Git
```
sudo apt-get install git
```
### Unzip
```
sudo apt-get install unzip
```
### Terraform v0.12
```
wget https://releases.hashicorp.com/terraform/0.12.24/terraform_0.12.24_linux_amd64.zip
unzip terraform_0.12.24_linux_amd64.zip
sudo mv terraform /usr/local/bin
```
### kubectl
```
sudo apt-get update && sudo apt-get install -y apt-transport-https gnupg2
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubectl
```
### helm
```
wget https://get.helm.sh/helm-v3.2.0-linux-amd64.tar.gz
tar -zxvf helm-v3.2.0-linux-amd64.tar.gz
sudo mv ./linux-amd64/helm /usr/local/bin/
rm linux-amd64 -rf
rm helm-v3.2.0-linux-amd64.tar.gz
helm repo add stable https://kubernetes-charts.storage.googleapis.com/
```
### RKE
```
wget https://github.com/rancher/rke/releases/download/v0.2.10/rke_linux-amd64
sudo mv rke_linux-amd64 /usr/local/bin/rke
sudo chmod 755 /usr/local/bin/rke
```
## Usage

### Create a Kubernetes cluster

Modify the base values:

```
vim terraform.tfvars
```

run terraform:

```
terraform init
terraform plan
terraform apply
```
