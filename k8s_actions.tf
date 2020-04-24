#===============================================================================
# Null Resource
#===============================================================================

# Modify the permission on the config directory
resource "null_resource" "config_permission" {
  provisioner "local-exec" {
    command = "chmod -R 700 config"
  }

  depends_on = [local_file.rancher_cluster, local_file.ansible_hosts]
}

# Run RKE to deploy K8s
resource "null_resource" "deploy_k8s" {
  count = var.action == "create" ? 1 : 0
  provisioner "local-exec" {
    command = "cd config && rke up --config ./rancher-cluster.yml"
  }

  depends_on = [null_resource.config_permission, local_file.rancher_cluster, local_file.ansible_hosts, azurerm_virtual_machine.manager]
}



# Cleanup the config directory on destroy
resource "null_resource" "config_cleanup" {
  provisioner "local-exec" {
    when    = destroy
    command = "rm config/* -rf"
  }
}