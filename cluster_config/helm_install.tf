provider "helm" {
  kubernetes {
    host = digitalocean_kubernetes_cluster.dokub3.endpoint

    client_certificate     = base64decode(digitalocean_kubernetes_cluster.dokub3.kube_config.0.client_certificate)
    client_key             = base64decode(digitalocean_kubernetes_cluster.dokub3.kube_config.0.client_key)
    cluster_ca_certificate = base64decode(digitalocean_kubernetes_cluster.dokub3.kube_config.0.cluster_ca_certificate)
  }
}

data "helm_repository" "stable" {
  name = "stable"
  url  = "https://kubernetes-charts.storage.googleapis.com"
}

resource "helm_release" "cluster-ingress" {
    name      = "ingress-nginx"
    chart     = "stable/nginx-ingress"
    repository = data.helm_repository.stable.metadata.0.name
    namespace  = "ingress-nginx"

    set {
        name  = "controller.publishService.enabled"
        value = true
    }
}

data "helm_repository" "argo" {
  name = "argo"
  url  = "https://argoproj.github.io/argo-helm"
}

resource "helm_release" "argo-release" {
    name      = "argocd"
    chart     = "argo/argo-cd"
    namespace = "argocd"
    repository = data.helm_repository.argo.metadata.0.name
}


data "helm_repository" "jetstack" {
  name = "jetstack"
  url  = "https://charts.jetstack.io"
}

resource "helm_release" "jetstack-release" {
    name      = "cert-manager"
    chart     = "jetstack/cert-manager"
    namespace = "cert-manager"
    version   = "v0.14.1"
    repository = data.helm_repository.argo.metadata.0.name
}
