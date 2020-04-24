#===============================================================================
# Template files
#===============================================================================

# Kubespray all.yml template #
# data "template_file" "kubespray_all" {
#   template = "${file("templates/kubespray_all.tpl")}"
#   vars = {
#     loadbalancer_apiserver    = azurerm_lb.managerlb.private_ip_address
#     loadbalancer_sku          = var.azure_lb_sku
#     azure_tenant_id           = data.azurerm_subscription.current.tenant_id
#     azure_subscription_id     = data.azurerm_subscription.current.subscription_id
#     azure_aad_client_id       = azuread_service_principal.manager.application_id
#     azure_aad_client_secret   = random_password.azure_aad_client_secret.result
#     azure_resource_group      = azurerm_resource_group.main.name
#     azure_location            = azurerm_resource_group.main.location
#     azure_subnet_name         = var.azure_subnet_names[1]
#     azure_security_group_name = azurerm_network_security_group.manager.name
#     azure_vnet_name           = var.azure_vnet_name
#     azure_vnet_resource_group = data.azurerm_resource_group.network_rg.name
#     azure_route_table_name    = azurerm_route_table.manager.name
#     azure_vmtype              = "standard"
#   }
# }

# cloud-config file #
data "template_file" "cloud_config" {
  template = "${file("templates/cloud_config.tpl")}"
  vars = {
    vm_user = var.vm_user
    vm_ssh_public_key = var.vm_ssh_public_key
  }
}

# generate cluster configuration file for rke #
data "template_file" "rancher_cluster_hosts" {
  count    = length(var.azure_subnet_names)
  template = "${file("templates/rancher_cluster_hosts.tpl")}"
  vars = {
    username = var.vm_user
    hostname = "${azurerm_resource_group.main.name}-${var.vm_name_prefix}-${count.index + 1}"
    host_ip  = azurerm_network_interface.manager[count.index].private_ip_address
  }
}

data "template_file" "rancher_cluster_suffix" {
  template = "${file("templates/rancher_cluster_suffix.tpl")}"
}

# hostname and ip list template for Ansible #
data "template_file" "kubespray_hosts_master" {
  count    = length(var.azure_subnet_names)
  template = "${file("templates/ansible_hosts.tpl")}"

  vars = {
    hostname = "${azurerm_resource_group.main.name}-${var.vm_name_prefix}-${count.index + 1}"
    host_ip  = azurerm_network_interface.manager[count.index].private_ip_address
  }
}

data "template_file" "kubespray_hosts_master_list" {
  count    = length(var.azure_subnet_names)
  template = "${file("templates/ansible_hosts_list.tpl")}"

  vars = {
    hostname = "${azurerm_resource_group.main.name}-${var.vm_name_prefix}-${count.index + 1}"
  }
}

#===============================================================================
# Local Files
#===============================================================================

# Create Kubespray hosts.ini configuration file from Terraform templates #
resource "local_file" "rancher_cluster" {
  content  = "nodes:\n${join("", data.template_file.rancher_cluster_hosts.*.rendered)}${data.template_file.rancher_cluster_suffix.rendered}"
  filename = "config/rancher-cluster.yml"
}

# Create Kubespray hosts.ini configuration file from Terraform templates #
resource "local_file" "ansible_hosts" {
  content  = "${join("", data.template_file.kubespray_hosts_master.*.rendered)}\n[kube-master]\n${join("", data.template_file.kubespray_hosts_master_list.*.rendered)}\n[etcd]\n${join("", data.template_file.kubespray_hosts_master_list.*.rendered)}\n[kube-node]\n${join("", data.template_file.kubespray_hosts_master_list.*.rendered)}\n[k8s-cluster:children]\nkube-master\nkube-node"
  filename = "config/hosts.ini"
}

#===============================================================================
# Locals
#===============================================================================

# Extra args for ansible playbooks #
locals {
  extra_args = {
    ubuntu = "-T 300"
    debian = "-T 300 -e 'ansible_become_method=su'"
    centos = "-T 300"
    rhel   = "-T 300"
  }
}
