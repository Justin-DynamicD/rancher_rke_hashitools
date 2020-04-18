# rancher-rke-hashitools

This was inspired from a client request, a short review of Rancher documentation, and quite a bit of concepts from
[terraform-vsphere-kubespray](https://github.com/sguyennet/terraform-vsphere-kubespray).

In short, while Rancher is a great tool for managing K8S deployments, and even capable of using native AKS, they actually
recommend making the rancher server itself on classic VMs to ensure Rancher has complete access to the k8s cluster.

WHat's more, an RKE deployment uses 3 nodes with manager and worker nodes combined. So with a little inspiration and
some spare time, I decided to create a Terraform template to perform a complete deployment.

This repo does NOT contain a pre-built packer image, but kubespray is pretty good about doing the heavy lifting there,
so I didn't think it necessary.

## Requirements

The machine you are running from must be a linux instance (or in WSL2 on Windows) and will need the following installed
in order to function:

* Git
* Ansible v2.6 or v2.7
* Jinja >= 2.9.6
* Python netaddr
* Terraform v0.12
* Internet connection on the client machine to download Kubespray.
* Internet connection on the Kubernetes nodes to download the Kubernetes binaries.

## Working Linux distributions

While the original VMware example was tested on a number of instances, this has only been thoroughly tested on Ubuntu.

* Ubuntu LTS 16.04 (requirements: open-vm-tools package)
* Ubuntu LTS 18.04 (requirements: VMware tools)
* CentOS 7 (requirements: open-vm-tools package, perl package)
* Debian 9 (requirements: VMware tools, vSphere VM OS configuration set to "Ubuntu Linux (64-bit)", net-tools package)
* RHEL 7 (requirements: open-vm-tools package, perl package)

## Tested Kubernetes network plugins

|         |        RHEL 7      |       CentOS 7     |  Ubuntu LTS 18.04  |  Ubuntu LTS 16.04  |       Debian 9     |
|---------|:------------------:|:------------------:|:------------------:|:------------------:|:------------------:|
| Flannel | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: |
| Weave   | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: |
| Calico  | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: |
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
|      v1.15.3       |      v2.11.0      |
|      v1.14.3       |      v2.10.3      |
|      v1.14.1       |      v2.10.0      |
|      v1.13.5       |      v2.9.0       |
|      v1.12.5       |      v2.8.2       |
|      v1.12.4       |      v2.8.1       |
|      v1.12.3       |      v2.8.0       |

Execute the terraform script to upgrade Kubernetes:

$ terraform apply -var 'action=upgrade'
