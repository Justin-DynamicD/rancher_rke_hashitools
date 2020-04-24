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

variable "azure_vm_availability_zones" {
  type        = list(string)
  description = "List of availability zones to deploy to, per VM"
  default = ["1","2","3"]
}

variable "azure_subnet_names" {
  type        = map(string)
  description = "subnet target for all VMs"
  default = {
    "1" = ""
    "2" = ""
    "3" = ""
  }
}

#===========================#
#       Azure LB Info       #
#===========================#

variable "azure_lb_sku" {
  type        = string
  description = "SKU of the Azure LB. You must be in a single zone to use 'basic'"
  default     = "standard"
}

#===========================#
#         Azure VMs         #
#===========================#

variable "vm_name_prefix" {
  type        = string
  description = "Prefix for the name of the virtual machines and the hostname of the Kubernetes nodes"
  default     = "manager"
}

variable "azure_vm_size" {
  type        = string
  description = "size of the vm to deploy"
  default     = "Standard_d2s_v3"
}

variable "azure_image_name" {
  type        = string
  description = "VM Image to use"
}

variable "azure_image_resource_group" {
  type        = string
  description = "Resource Group that holds the VM Image"
}

variable "vm_user" {
  type        = string
  description = "SSH user for the virtual machines"
  default     = "rancher"
}

variable "vm_ssh_key_path" {
  type        = string
  description = "Public Key Upload location"
  default     = "/home/rancher/.ssh/authorized_keys"
}

variable "vm_ssh_public_key" {
  description = "PublicKey for authentication. Azure only supports RSA SSH2 key signatures of at least 2048 bits in length"
}

#===========================#
# Kubernetes infrastructure #
#===========================#

variable "action" {
  type        = string
  description = "action to take on the underlying k8s cluter."
  default     = "create"
}

variable "k8s_version" {
  type        = string
  description = "version of k8s to deplpoy"
  default     = "v1.17.5"
}

#===========================#
# Rancher Helm Chart Info   #
#===========================#

variable "rke_namespace" {
  type        = string
  description = "namespace for Rancher tro run in, per docs it should not change"
  default     = "cattle-system"
}