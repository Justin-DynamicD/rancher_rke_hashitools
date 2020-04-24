# a bare minimum of variables are defined here, falling back on defaults
# review variables.tf for more options

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

# Multi-AZ deployment requires subnets to be zone-bound.  This maps AZ Zones
# to the appropriate subnet name.
azure_subnet_names = {
  "1" = "az1"
  "2" = "az2"
  "3" = "az3"
}

#===============================================================================
# Global virtual machines parameters
#===============================================================================

# each entry represents a single vm deployment and it's associated AZ
# The server count is therefore not bound to number of AZ's but instead is 
# configurable. Default is 3 servers, 1 in each zone per best practices.

azure_vm_availability_zones = ["1","2","3"]

# The prefix to add to the names of the virtual machines
# This technically gets added _after_ the resource group prefix
vm_name_prefix = "manager"

# source image name to use in deployment
azure_image_name = "rke-ubuntu-image"
azure_image_resource_group = "custom-images"

# Username and key used to SSH to the virtual machines #
vm_user = "rancher"
vm_ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDDJkGZR6j08OTC9ry7xTo1hSVLBEZmVn2magL4inKx7c/Lz407Dd/dtlLcqxGcDaPRQEzewBoJpYS3ouw+7a7a3pY9X22JAcxP2jqXZsquRiRUlWXjsRlO4L5rgJK67IqG5CNU5l2/P/rhV5N62eKwbx1qSP87tQZXgjT+1DTAapYW1GEiVj5Qja72XnFaIWvCQBQeGEczaYs1yJUr6T/BOoRmYGufACZ1FoaDJ+0oCYJwHTZ0IbA1aXbtbSuCDftDkhOYnbxbyILX1Sl1pS/VDUR2YzxXkHMoH2FyKXTXM0tn8txZEu0PwZ4Yx7nxZdVojQlGIRMqhioOm8nY+Qvu/H/rl/PYnR0bH5BD1xEdQd9LgDTDXE93ydgi0mjzxtzGQNB1R9g2Ek2/qMspBoYDOYeiD1K4nU+nyP6jwHRJYOKweVDzhadLnHzn5+Oy2I0UWvjSD8UN/a40Y+e/xe1+fHPL5m2F3kKfr/pQdtsHZjiYNb6lF6/zRfZFZU5VVzR987NMxuMECZ/SZdyXSuVOiC3h6l2Ir0lG7flWa17eZBMADf/+wJyXhj9jHgG351H80YzLkSqbJ836iZlc1a5yhAv3YejBk+Nxrqvt7SjRPKzwmukjcjK8F+KknTnzKJXDW7PhiMYv8Y/GCGk7JWJl0wVoSQw0QDKVe+O3Vw3Ugw== justin.dynamicd@gmail.com"
vm_ssh_key_path = "/home/rancher/.ssh/authorized_keys"

#===============================================================================
# Kubernetes parameters
#===============================================================================

# The Kubernetes version that will be deployed #
k8s_version = "v1.17.5"