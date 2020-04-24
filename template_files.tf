#===============================================================================
# Template files
#===============================================================================

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
  vars = {
    aadClientId     = azuread_service_principal.manager.application_id
    aadClientSecret = random_password.azure_aad_client_secret.result
    subscriptionId  = data.azurerm_subscription.current.subscription_id
    tenantId        = data.azurerm_subscription.current.tenant_id
  }
}

# hostname and ip list template for Ansible #
data "template_file" "ansible_hosts_master" {
  count    = length(var.azure_subnet_names)
  template = "${file("templates/ansible_hosts.tpl")}"

  vars = {
    hostname = "${azurerm_resource_group.main.name}-${var.vm_name_prefix}-${count.index + 1}"
    host_ip  = azurerm_network_interface.manager[count.index].private_ip_address
  }
}

data "template_file" "ansible_hosts_master_list" {
  count    = length(var.azure_subnet_names)
  template = "${file("templates/ansible_hosts_list.tpl")}"

  vars = {
    hostname = "${azurerm_resource_group.main.name}-${var.vm_name_prefix}-${count.index + 1}"
  }
}

#===============================================================================
# Local Files
#===============================================================================

# Create rke deployment yaml #
resource "local_file" "rancher_cluster" {
  content  = "nodes:\n${join("", data.template_file.rancher_cluster_hosts.*.rendered)}${data.template_file.rancher_cluster_suffix.rendered}"
  filename = "config/rancher-cluster.yml"
}

# Create ansible host list #
resource "local_file" "ansible_hosts" {
  content  = "${join("", data.template_file.ansible_hosts_master.*.rendered)}\n[kube-master]\n${join("", data.template_file.ansible_hosts_master_list.*.rendered)}\n[etcd]\n${join("", data.template_file.ansible_hosts_master_list.*.rendered)}\n[kube-node]\n${join("", data.template_file.ansible_hosts_master_list.*.rendered)}\n[k8s-cluster:children]\nkube-master\nkube-node"
  filename = "config/hosts.ini"
}
