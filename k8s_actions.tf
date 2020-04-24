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

# push cert-manager CRDs andsetup namespace for Rancher
resource "null_resource" "cert_manager" {
  count = var.action == "create" ? 1 : 0
  provisioner "local-exec" {
    command = "kubectl apply --validate=false -f ${var.k8s_certmanager_manifest}"
    environment = {
      KUBECONFIG = "${path.module}/config/kube_config_rancher-cluster.yml"
    }
  }

  provisioner "local-exec" {
    command = "kubectl create namespace ${rke_namespace}"
    environment = {
      KUBECONFIG = "${path.module}/config/kube_config_rancher-cluster.yml"
    }
  }

  depends_on = [null_resource.deploy_k8s]
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

data "helm_repository" "rancher" {
  name = var.rke_helm_repo_name
  url  = var.rke_helm_repo_url
}

resource "helm_release" "rancher" {
  name       = var.rke_chart
  namespace  = var.rke_namespace
  repository = data.helm_repository.rancher.metadata[0].name
  chart      = "${var.rke_helm_repo_name}/${var.rke_chart}"
  version    = var.rke_version != "" ? var.rke_version : null

  set {
    name  = "hostname"
    value = var.rke_url
  }

  depends_on = [null_resource.cert_manager]
}
