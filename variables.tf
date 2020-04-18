#===========================#
#   Azure infrastructure    #
#===========================#

variable "azure_location" {
  type        = string
  description = "Azure region for all resources"
  default     = "West US 2"
}

variable "azure_main_resource_group" {
  type        = string
  description = "Resource Group to create the resources in"
  default     = "rke"
}

variable "azure_network_resource_group" {
  type        = string
  description = "RG associated with the target subnet"
}

variable "azure_vnet_name" {
  type        = string
  description = "VNet target for RKE cluster"
}

variable "azure_subnet_name" {
  type        = string
  description = "subnet target for all VMs"
}

#===========================#
#       Azure LB Info       #
#===========================#

variable "add_manager_lb" {
  type        = string
  description = "create a load balancer"
  default     = "yes"
}

#===========================#
#         Azure VMs         #
#===========================#

variable "vm_domain" {
  type        = string
  description = "Domain for the Kubernetes nodes"
  default     = ""
}

variable "vm_name_prefix" {
  type        = string
  description = "Prefix for the name of the virtual machines and the hostname of the Kubernetes nodes"
  default     = "manager"
}

variable "azure_vm_count" {
  type        = number
  description = "number of servers to deploy"
  default = 3
}

variable "azure_vm_size" {
  type        = string
  description = "size of the vm to deploy"
  default     = "D2s_v3"
}

variable "azure_vm_availability_zones" {
  type        = list(string)
  description = "List of availability zones to deploy to, per VM"
  default = ["1","2","3"]
}

variable "azure_image_name" {
  type        = string
  description = "VM Image to use"
}

variable "azure_vm_distro" {
  type        = string
  description = "The linux distribution used by the virtual machines (ubuntu/debian/centos/rhel)"
  default     = "ubuntu"
}

variable "azure_image_resource_group" {
  type        = string
  description = "Resource Group that holds the VM Image"
}

variable "vm_user" {
  type        = string
  description = "SSH user for the virtual machines"
  default     = "ubuntu"
}

variable "vm_ssh_key_path" {
  type        = string
  description = "Public Key Upload location"
  default     = "/home/ubuntu/.ssh/authorized_keys"
}

variable "vm_ssh_public_key" {
  description = "PublicKey for authentication. Azure only supports RSA SSH2 key signatures of at least 2048 bits in length"
}

#===========================#
# Kubernetes infrastructure #
#===========================#

variable "action" {
  type        = string
  description = "Which action have to be done on the cluster (create, add_worker, remove_worker, or upgrade)"
  default     = "create"
}

variable "k8s_kubespray_url" {
  type        = string
  description = "Kubespray git repository"
  default     = "https://github.com/kubernetes-incubator/kubespray.git"
}

variable "k8s_kubespray_version" {
  type        = string
  description = "Kubespray version"
}

variable "k8s_version" {
  type        = string
  description = "Version of Kubernetes that will be deployed"
}

variable "k8s_network_plugin" {
  type        = string
  description = "Kubernetes network plugin (calico/canal/flannel/weave/cilium/contiv/kube-router)"
  default     = "calico"
}

variable "k8s_weave_encryption_password" {
  type        = string
  description = "Weave network encryption password "
  default     = ""
}

variable "k8s_dns_mode" {
  type        = string
  description = "Which DNS to use for the internal Kubernetes cluster name resolution (example: kubedns, coredns, etc.)"
  default     = "coredns"
}

#================#
# Redhat account #
#================#

variable "rh_subscription_server" {
  description = "Address of the Redhat subscription server"
  default     = "subscription.rhsm.redhat.com"
}

variable "rh_unverified_ssl" {
  description = "Disable the Redhat subscription server certificate verification"
  default     = "false"
}

variable "rh_username" {
  description = "Username of your Redhat account"
  default     = "none"
}

variable "rh_password" {
  description = "Password of your Redhat account"
  default     = "none"
}
