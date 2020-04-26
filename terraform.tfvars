# a bare minimum of variables are defined here, falling back on defaults.
# Review variables.tf for more options.

#===============================================================================
# Azure infrastructure
#===============================================================================

# name of the resource group that will contain RKE
# this value gets prefixed across all resources
azure_main_resource_group = "rke"

# The Azure region.  This template will leverage availability zones by default
# see variables.tf for more options
azure_location = "West US 2"

# this template assumes there is an existing network in place.
# the next variables define the subnet to place resources into
azure_network_resource_group = "common-networking"
azure_vnet_name = "internal-network"

# Each entry represents a single vm deployment and it's associated availability
# zone. Default is 3 servers, every zone definition must map to a 
# `azure_subnet_name` in the next section. If all servers route to a single
# zone/subnet, availability zones are skipped.

azure_vm_availability_zones = ["1","2","3"]

# Multi-AZ deployment requires subnets to be zone-bound.  This maps AZ Zones
# to the appropriate subnet name. If the region does not support zones, simply 
# define a single subnet as map "1" and zone configuration will be skipped
azure_subnet_names = {
  "1" = "az1"
  "2" = "az2"
  "3" = "az3"
}

# A public-facing azure Load Balancer can be enabled if desired. If so, the 
# subnet is re-declared in case one wishes to use a dedicated subnet to host the
# frontend IP.
azure_lb_enable  = "yes"

# Not all subscriptions support zone-redundant Load Balancers. Uncomment if this
# is available or you wish to specify a zone.
# azure_lb_zones = ["zone-redundant"]

#===============================================================================
# virtual machines parameters
#===============================================================================

# An additional prefix to add to the names of the virtual machines This
# technically gets added _after_ the resource group prefix ex. `rke-manager`
vm_name_prefix = "manager"

# source image name to use in deployment
azure_image_name = "rke-ubuntu-image"
azure_image_resource_group = "custom-images"

# Username and key used to SSH to the virtual machines #
vm_user = "rancher"
vm_ssh_public_key = ""
vm_ssh_key_path = "/home/rancher/.ssh/authorized_keys"

#===============================================================================
# RKE parameters
#===============================================================================

# URL for Rancher
rke_url = "rancher.example.com"

# The Kubernetes and RKE versions that will be deployed, latest otherwise.
#k8s_version = "v1.15.11-rancher2-1"
#rke_version = "2.3.6"