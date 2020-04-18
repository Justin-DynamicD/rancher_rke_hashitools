# a bare minimum of variables are defined here, falling back on defaults
# review variables.tf for more options

#===============================================================================
# Azure configuration
#===============================================================================

# name of the resource group that will contain RKE
# this value gets prefixed across all resources
azure_main_resource_group = "rke"

# The Azure region.  This template will leverage availability zones by default
# see variables.tf for more options
azure_location = "West US 2"

# this template assumes there is an existing network in place.
# the next variables define the subnet to place resources into
azure_network_resource_group = ""
azure_vnet_name = ""
azure_subnet_name = ""

#===============================================================================
# Global virtual machines parameters
#===============================================================================

# The prefix to add to the names of the virtual machines
# This technically gets added _after_ the resource group prefix
vm_name_prefix = "manager"
vm_domain = ""

# source image name to use in deployment
azure_image_name = ""
azure_image_resource_group = ""

# The linux distribution used by the virtual machines (ubuntu/debian/centos/rhel) #
azure_vm_distro = "ubuntu"

# Username and key used to SSH to the virtual machines #
vm_user = "ubuntu"
vm_ssh_public_key = ""
vm_ssh_key_path = "/home/ubuntu/.ssh/authorized_keys"

#===============================================================================
# Redhat subscription parameters
#===============================================================================

# If you use RHEL 7 as a base distro, you need to specify your subscription account #
rh_subscription_server = "subscription.rhsm.redhat.com"
rh_unverified_ssl = "false"
rh_username = ""
rh_password = ""

#===============================================================================
# Kubernetes parameters
#===============================================================================

# The version of Kubespray that will be used to deploy Kubernetes #
k8s_kubespray_version = "v2.11.0"

# The Kubernetes version that will be deployed #
k8s_version = "v1.15.3"
