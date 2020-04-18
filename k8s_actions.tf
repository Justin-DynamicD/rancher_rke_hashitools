#===============================================================================
# Null Resource
#===============================================================================

# Modify the permission on the config directory
resource "null_resource" "config_permission" {
  provisioner "local-exec" {
    command = "chmod -R 700 config"
  }

  depends_on = ["local_file.kubespray_hosts", "local_file.kubespray_k8s_cluster", "local_file.kubespray_all"]
}

# Clone Kubespray repository #
resource "null_resource" "kubespray_download" {
  provisioner "local-exec" {
    command = "cd ansible && rm -rf kubespray && git clone --branch ${var.k8s_kubespray_version} ${var.k8s_kubespray_url}"
  }
}

# Execute register and auto-subscribe RHEL Ansible playbook #
resource "null_resource" "rhel_register" {
  count = "${var.azure_vm_distro == "rhel" ? 1 : 0}"

  provisioner "local-exec" {
    command = "cd ansible/rhel && ansible-playbook -i ../../config/hosts.ini -b -u ${var.vm_user} -e \"ansible_ssh_pass=$VM_PASSWORD ansible_become_pass=$VM_PRIVILEGE_PASSWORD rh_username=${var.rh_username} rh_password=$RH_PASSWORD rh_subscription_server=${var.rh_subscription_server} rh_unverified_ssl=${var.rh_unverified_ssl}\" ${lookup(local.extra_args, var.azure_vm_distro)} -v register.yml"

    environment = {
      VM_PASSWORD           = var.vm_password
      VM_PRIVILEGE_PASSWORD = var.vm_privilege_password
      RH_PASSWORD           = var.rh_password
    }
  }

  depends_on = ["local_file.kubespray_hosts", "azurerm_virtual_machine.manager"]
}

# Execute register and auto-subscribe RHEL Ansible playbook when a node is added#
resource "null_resource" "rhel_register_kubespray_add" {
  count = "${var.azure_vm_distro == "rhel" && var.action == "add_worker" ? 1 : 0}"

  provisioner "local-exec" {
    command = "cd ansible/rhel && ansible-playbook -i ../../config/hosts.ini -b -u ${var.vm_user} -e \"ansible_ssh_pass=$VM_PASSWORD ansible_become_pass=$VM_PRIVILEGE_PASSWORD rh_username=${var.rh_username} rh_password=$RH_PASSWORD rh_subscription_server=${var.rh_subscription_server} rh_unverified_ssl=${var.rh_unverified_ssl}\" ${lookup(local.extra_args, var.azure_vm_distro)} -v register.yml"

    environment = {
      VM_PASSWORD           = var.vm_password
      VM_PRIVILEGE_PASSWORD = var.vm_privilege_password
      RH_PASSWORD           = var.rh_password
    }
  }

  depends_on = ["local_file.kubespray_hosts", "azurerm_virtual_machine.manager"]
}

# Execute firewalld RHEL Ansible playbook #
resource "null_resource" "rhel_firewalld" {
  count = "${var.azure_vm_distro == "rhel" || var.azure_vm_distro == "centos" ? 1 : 0}"

  provisioner "local-exec" {
    command = "cd ansible/rhel && ansible-playbook -i ../../config/hosts.ini -b -u ${var.vm_user} -e \"ansible_ssh_pass=$VM_PASSWORD ansible_become_pass=$VM_PRIVILEGE_PASSWORD\" ${lookup(local.extra_args, var.azure_vm_distro)} -v firewalld.yml"

    environment = {
      VM_PASSWORD           = var.vm_password
      VM_PRIVILEGE_PASSWORD = var.vm_privilege_password
    }
  }

  depends_on = ["local_file.kubespray_hosts", "azurerm_virtual_machine.manager"]
}

# Execute firewall RHEL Ansible playbook when a node is added#
resource "null_resource" "rhel_firewalld_kubespray_add" {
  count = "${var.azure_vm_distro == "rhel" || var.azure_vm_distro == "centos" && var.action == "add_worker" ? 1 : 0}"

  provisioner "local-exec" {
    command = "cd ansible/rhel && ansible-playbook -i ../../config/hosts.ini -b -u ${var.vm_user} -e \"ansible_ssh_pass=$VM_PASSWORD ansible_become_pass=$VM_PRIVILEGE_PASSWORD\" ${lookup(local.extra_args, var.azure_vm_distro)} -v firewalld.yml"

    environment = {
      VM_PASSWORD           = var.vm_password
      VM_PRIVILEGE_PASSWORD = var.vm_privilege_password
    }
  }

  depends_on = ["local_file.kubespray_hosts", "azurerm_virtual_machine.manager"]
}


# Execute create Kubespray Ansible playbook #
resource "null_resource" "kubespray_create" {
  count = "${var.action == "create" ? 1 : 0}"

  provisioner "local-exec" {
    command = "cd ansible/kubespray && ansible-playbook -i ../../config/hosts.ini -b -u ${var.vm_user} -e \"kube_version=${var.k8s_version}\" ${lookup(local.extra_args, var.azure_vm_distro)} -v cluster.yml"
  }

  depends_on = ["local_file.kubespray_hosts", "null_resource.kubespray_download", "local_file.kubespray_all", "local_file.kubespray_k8s_cluster", "azurerm_virtual_machine.manager"]
}

# Execute scale Kubespray Ansible playbook #
resource "null_resource" "kubespray_add" {
  count = "${var.action == "add_worker" ? 1 : 0}"

  provisioner "local-exec" {
    command = "cd ansible/kubespray && ansible-playbook -i ../../config/hosts.ini -b -u ${var.vm_user} -e \"kube_version=${var.k8s_version}\" ${lookup(local.extra_args, var.azure_vm_distro)} -v scale.yml"
  }

  depends_on = ["local_file.kubespray_hosts", "null_resource.kubespray_download", "local_file.kubespray_all", "local_file.kubespray_k8s_cluster", "azurerm_virtual_machine.manager"]
}

# Execute upgrade Kubespray Ansible playbook #
resource "null_resource" "kubespray_upgrade" {
  count = "${var.action == "upgrade" ? 1 : 0}"

  triggers = {
    ts = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = "cd ansible && rm -rf kubespray && git clone --branch ${var.k8s_kubespray_version} ${var.k8s_kubespray_url}"
  }

  provisioner "local-exec" {
    command = "cd ansible/kubespray && ansible-playbook -i ../../config/hosts.ini -b -u ${var.vm_user} -e \"kube_version=${var.k8s_version}\" ${lookup(local.extra_args, var.azure_vm_distro)} -v upgrade-cluster.yml"

  }

  depends_on = ["local_file.kubespray_hosts", "null_resource.kubespray_download", "local_file.kubespray_all", "local_file.kubespray_k8s_cluster", "azurerm_virtual_machine.manager"]
}

# Create the local admin.conf kubectl configuration file #
resource "null_resource" "kubectl_configuration" {
  provisioner "local-exec" {
    command = "ansible -i ${lookup(azurerm_network_interface.manager.private_ip_address, 0)}, -b -u ${var.vm_user} -e ${lookup(local.extra_args, var.azure_vm_distro)} -m fetch -a 'src=/etc/kubernetes/admin.conf dest=config/admin.conf flat=yes' all"

  }

  provisioner "local-exec" {
    command = "sed 's/lb-apiserver.kubernetes.local/${azurerm_lb.managerlb.private_ip_address}/g' config/admin.conf | tee config/admin.conf.new && mv config/admin.conf.new config/admin.conf && chmod 700 config/admin.conf"
  }

  provisioner "local-exec" {
    command = "chmod 600 config/admin.conf"
  }

  depends_on = ["null_resource.kubespray_create"]
}
