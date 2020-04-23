#===============================================================================
# Template files
#===============================================================================

# Kubespray all.yml template #
data "template_file" "kubespray_all" {
  template = "${file("templates/kubespray_all.tpl")}"
  vars = {
    loadbalancer_apiserver    = azurerm_lb.managerlb.private_ip_address
    loadbalancer_sku          = var.azure_lb_sku
    azure_tenant_id           = data.azurerm_subscription.current.tenant_id
    azure_subscription_id     = data.azurerm_subscription.current.subscription_id
    azure_aad_client_id       = azuread_service_principal.manager.application_id
    azure_aad_client_secret   = random_password.azure_aad_client_secret.result
    azure_resource_group      = azurerm_resource_group.main.name
    azure_location            = azurerm_resource_group.main.location
    azure_subnet_name         = var.azure_subnet_names[0]
    azure_security_group_name = azurerm_network_security_group.manager.name
    azure_vnet_name           = var.azure_vnet_name
    azure_vnet_resource_group = data.azurerm_resource_group.network_rg.name
    azure_route_table_name    = azurerm_route_table.manager.name
    azure_vmtype              = "standard"
  }
}

# Kubespray k8s-cluster.yml template #
data "template_file" "kubespray_k8s_cluster" {
  template = "${file("templates/kubespray_k8s_cluster.tpl")}"
  vars = {
    kube_version        = var.k8s_version
    kube_network_plugin = var.k8s_network_plugin
    weave_password      = var.k8s_weave_encryption_password
    k8s_dns_mode        = var.k8s_dns_mode
  }
}

# Kubespray master hostname and ip list template #
data "template_file" "kubespray_hosts_master" {
  count    = length(var.azure_subnet_names)
  template = "${file("templates/ansible_hosts.tpl")}"

  vars = {
    hostname = "${azurerm_resource_group.main.name}-${var.vm_name_prefix}-${count.index + 1}"
    host_ip  = azurerm_network_interface.manager[count.index].private_ip_address
  }
}

# Kubespray master hostname list template #
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

# Create Kubespray all.yml configuration file from Terraform template #
resource "local_file" "kubespray_all" {
  content  = data.template_file.kubespray_all.rendered
  filename = "config/group_vars/all.yml"
}

# Create Kubespray k8s-cluster.yml configuration file from Terraform template #
resource "local_file" "kubespray_k8s_cluster" {
  content  = data.template_file.kubespray_k8s_cluster.rendered
  filename = "config/group_vars/k8s-cluster.yml"
}

# Create Kubespray hosts.ini configuration file from Terraform templates #
resource "local_file" "kubespray_hosts" {
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
