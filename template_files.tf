#===============================================================================
# Template files
#===============================================================================

# Kubespray all.yml template #
data "template_file" "kubespray_all" {
  template = "${file("templates/kubespray_all.tpl")}"
  vars = {
    vsphere_vcenter_ip     = var.vsphere_vcenter
    loadbalancer_apiserver = azurerm_lb.managerlb.private_ip_address
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
  count    = var.azure_vm_count
  template = "${file("templates/ansible_hosts.tpl")}"

  vars = {
    hostname = "${azurerm_resource_group.main.name}-${var.vm_name_prefix}-${count.index + 1}.${vm_domain}"
    host_ip  = "${lookup(azurerm_network_interface.manager.private_ip_address, count.index)}"
  }
}

# Kubespray master hostname list template #
data "template_file" "kubespray_hosts_master_list" {
  count    = var.azure_vm_count
  template = "${file("templates/ansible_hosts_list.tpl")}"

  vars = {
    hostname = "${azurerm_resource_group.main.name}-${var.vm_name_prefix}-${count.index + 1}.${vm_domain}"
  }
}

#===============================================================================
# Local Files
#===============================================================================

# Create Kubespray all.yml configuration file from Terraform template #
resource "local_file" "kubespray_all" {
  content  = "${data.template_file.kubespray_all.rendered}"
  filename = "config/group_vars/all.yml"
}

# Create Kubespray k8s-cluster.yml configuration file from Terraform template #
resource "local_file" "kubespray_k8s_cluster" {
  content  = "${data.template_file.kubespray_k8s_cluster.rendered}"
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
