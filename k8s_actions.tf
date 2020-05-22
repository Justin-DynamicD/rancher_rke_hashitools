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

  depends_on = [null_resource.config_permission, local_file.rancher_cluster, azurerm_virtual_machine.manager, azurerm_role_assignment.managerowner]
}

# push cert-manager CRDs for Rancher
resource "null_resource" "cert_manager" {
  count = var.action == "create" ? 1 : 0
  triggers = {
    order = "${null_resource.deploy_k8s[0].id}"
  }
  provisioner "local-exec" {
    command = "kubectl apply --validate=false -f ${var.k8s_certmanager_manifest}"
    environment = {
      KUBECONFIG = "${path.module}/config/kube_config_rancher-cluster.yml"
    }
  }

  depends_on = [null_resource.deploy_k8s]
}

# setup namespace for Rancher
resource "null_resource" "rancher_namespace" {
  count = var.action == "create" ? 1 : 0
  triggers = {
    order = "${null_resource.cert_manager[0].id}"
  }
  provisioner "local-exec" {
    command = "kubectl create namespace ${var.rke_namespace}"
    environment = {
      KUBECONFIG = "${path.module}/config/kube_config_rancher-cluster.yml"
    }
  }

  depends_on = [null_resource.cert_manager]
}

# Cleanup the config directory on destroy
resource "null_resource" "config_cleanup" {
  provisioner "local-exec" {
    when    = destroy
    command = "rm config/* -rf"
  }
}

#===============================================================================
# Helm Deploy
#===============================================================================

resource "helm_release" "rancher" {
  name       = var.rke_chart
  namespace  = var.rke_namespace
  repository = var.rke_helm_repo_url
  chart      = var.rke_chart
  version    = var.rke_version != "" ? var.rke_version : null

  set {
    name  = "hostname"
    value = var.rke_url
  }

  depends_on = [null_resource.cert_manager]
}
