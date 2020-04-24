# rancher-rke-hashitools

This was inspired from a client request, a short review of Rancher documentation, and quite a bit of concepts from
[terraform-vsphere-kubespray](https://github.com/sguyennet/terraform-vsphere-kubespray).

In short, while Rancher is a great tool for managing K8S deployments, and even capable of using native AKS, they actually
recommend making the rancher server itself on classic VMs to ensure Rancher has complete access to the k8s cluster.

WHat's more, an RKE deployment uses 3 nodes with manager and worker nodes combined. So with a little inspiration and
some spare time, I decided to create a Terraform template to perform a complete deployment.

The Terraform plan assumes a custom image has been made, so an extremely simple packer template was created and 
placed in `packer\ubunutu.json` for quick provisioning for testing.

## Requirements

The machine you are running from must be a linux instance (or in WSL2 on Windows) and will need the following installed
in order to function :

- Azure CLI >= 2.4
- Git
- Kubectl
- helm
- rke >= v1.0.7-rc3
- Terraform >= v0.12
- Unzip >= 6.0

Be aware that this was tested on Ubunutu 18.04 LTS which already has Python 3 installed, so to get things running, the below was run:

### Azure CLI

curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

### Git

sudo apt-get install git

### Unzip

sudo apt-get install unzip

### Terraform v0.12

wget https://releases.hashicorp.com/terraform/0.12.24/terraform_0.12.24_linux_amd64.zip
unzip terraform_0.12.24_linux_amd64.zip
sudo mv terraform /usr/local/bin

### kubectl

sudo apt-get update && sudo apt-get install -y apt-transport-https gnupg2
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubectl

### helm

### RKE

wget https://github.com/rancher/rke/releases/download/v1.0.7-rc3/rke_linux-amd64
sudo mv rke_linux-amd64 /usr/local/bin/rke
sudo chmod 755 /usr/local/bin/rke

## Usage

### Create a Kubernetes cluster

$ nano terraform.tfvars (set the desired vars)

$ terraform init

$ terraform plan

$ terraform apply

### Upgrade Kubernetes

Modify the k8s_version:

$ vim terraform.tfvars

Execute the terraform script to upgrade Kubernetes:

$ terraform apply -var 'action=upgrade'
