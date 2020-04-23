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

- Ansible >= v2.9
- Azure CLI >= 2.4
- Git
- Jinja2 >= 2.11
- Kubectl
- netaddr >= 0.7
- pip3 >= 9.0.1
- python netaddr
- python3 >= 3.6
- Terraform >= v0.12
- Unzip >= 6.0

Be aware that this was tested on Ubunutu 18.04 LTS which already has Python 3 installed, so to get things running, the below was run:

### Azure CLI

curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

### Git

sudo apt-get install git

### Unzip

sudo apt-get install unzip

### Pip3

sudo apt-get install python3-pip

### Jinja2

pip3 install Jinja2

### Ansible

pip3 install ansible

### Python netaddr

pip3 install netaddr

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

### Note on WSL2

if you're using WSL2 to deploy instead of a "true" Linux, there are some permission lines that will fail.
In order to resolve this, create `/etc/wsl.conf` and place the following config within:

```
[automount]
enabled = true
options = "metadata"
mountFsTab = false
```

Then restart your WSL instance (all WSL isntances, a reboot may be nessisary).  This will change how Windows drives
are mounted, so that chmod and other permission commands can run locally.

## Working Linux distributions

While the original VMware example was tested on a number of instances, this has only been thoroughly tested on Ubuntu.

* Ubuntu LTS 16.04 (requirements: open-vm-tools package)
* Ubuntu LTS 18.04 (requirements: VMware tools)
* CentOS 7 (requirements: open-vm-tools package, perl package)
* Debian 9 (requirements: VMware tools, vSphere VM OS configuration set to "Ubuntu Linux (64-bit)", net-tools package)
* RHEL 7 (requirements: open-vm-tools package, perl package)

## Tested Kubernetes network plugins

Some of these are not supported in Azure, despite being available in kubespray.  updating as discovered.

|         |        RHEL 7      |       CentOS 7     |  Ubuntu LTS 18.04  |  Ubuntu LTS 16.04  |       Debian 9     |
|---------|:------------------:|:------------------:|:------------------:|:------------------:|:------------------:|
| Flannel | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: |
| Weave   | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: |
| Calico  | :x: | :x: | :x: | :x: | :x: |
| Cilium  |        :x:         |        :x:         | :heavy_check_mark: |        :x:         | :heavy_check_mark: |
| Canal   | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: |

## Usage

### Create a Kubernetes cluster

$ vim terraform.tfvars (set the desired vars)

$ terraform init

$ terraform plan

$ terraform apply

### Upgrade Kubernetes

Modify the k8s_version and the k8s_kubespray_version variables:

$ vim terraform.tfvars

| Kubernetes version | Kubespray version |
|:------------------:|:-----------------:|
|      v1.16.9       |      v2.12.5      |
|      v1.15.3       |      v2.11.0      |

Execute the terraform script to upgrade Kubernetes:

$ terraform apply -var 'action=upgrade'
