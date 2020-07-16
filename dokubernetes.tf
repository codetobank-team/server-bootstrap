resource "digitalocean_kubernetes_cluster" "dokub3" {
  name    = "dokub3"
  region  = "ams3"
  version = "1.18.3-do.0"
  tags    = ["test"]

  node_pool {
    name       = "test-pool"
    size       = "s-1vcpu-2gb"
    node_count = 2
  }
}

provider "kubernetes" {
  host = digitalocean_kubernetes_cluster.dokub3.endpoint

  client_certificate     = base64decode(digitalocean_kubernetes_cluster.dokub3.kube_config.0.client_certificate)
  client_key             = base64decode(digitalocean_kubernetes_cluster.dokub3.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(digitalocean_kubernetes_cluster.dokub3.kube_config.0.cluster_ca_certificate)
}



resource "kubernetes_namespace" "ether-client-prod" {
  metadata {
    name = "etherbank-client-prod"
  }
}

resource "kubernetes_namespace" "ether-api-prod" {
  metadata {
    name = "etherbank-api-prod"
  }
}

resource "kubernetes_namespace" "argo-namespace" {
  metadata {
    name = "argocd"
  }
}

resource "kubernetes_namespace" "cert-manager" {
  metadata {
    name = "cert-manager"
  }
}

resource "kubernetes_namespace" "ingress-resource" {
  metadata {
    name = "ingress-nginx"
  }
}

resource "kubernetes_secret" "atlasname" {
   metadata {
     name = "ether-prod-secrets"
     namespace = "etherbank-api-prod"
   }
   
   type = "Opaque"
   data = {
     "atlas_db_name" = var.atlas_db_name
     "atlas_password" = var.atlas_password
     "jwtsecret" = var.jwtsecret
   }
}

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

provider "kubectl" {
  host = digitalocean_kubernetes_cluster.dokub3.endpoint

  client_certificate     = base64decode(digitalocean_kubernetes_cluster.dokub3.kube_config.0.client_certificate)
  client_key             = base64decode(digitalocean_kubernetes_cluster.dokub3.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(digitalocean_kubernetes_cluster.dokub3.kube_config.0.cluster_ca_certificate)
  load_config_file       = false
}

resource "kubectl_manifest" "cert-issuer" {
  yaml_body = <<YAML
    apiVersion: cert-manager.io/v1alpha2
    kind: ClusterIssuer
    metadata:
      name: letsencrypt-prod
      labels:
        name: letsencrypt-prod
    spec:
      acme:
        email: seyi_obaweya@yahoo.com
        privateKeySecretRef:
          name: letsencrypt-prod
        server: https://acme-v02.api.letsencrypt.org/directory
        solvers:
        - http01:
            ingress:
              class: nginx
  YAML
}

resource "kubectl_manifest" "prod-client" {
  yaml_body = <<YAML
    apiVersion: argoproj.io/v1alpha1
    kind: Application
    metadata:
      finalizers:
      - resources-finalizer.argocd.argoproj.io
      name: etherbank-api-prod
      namespace: argocd
    spec:
      destination:
        namespace: etherbank-api-prod
        server: https://kubernetes.default.svc
      project: default
      source:
        path: prod
        repoURL: https://github.com/codetobank-team/etherbank-infra
        targetRevision: master
      syncPolicy:
        automated:
          prune: true
          selfHeal: false
  YAML
}

resource "kubectl_manifest" "prod-api" {
  yaml_body = <<YAML
    apiVersion: argoproj.io/v1alpha1
    kind: Application
    metadata:
      finalizers:
      - resources-finalizer.argocd.argoproj.io
      name: etherbank-api-prod
      namespace: argocd
    spec:
      destination:
        namespace: etherbank-api-prod
        server: https://kubernetes.default.svc
      project: default
      source:
        path: prod
        repoURL: https://github.com/codetobank-team/etherbank-infra-backend
        targetRevision: master
      syncPolicy:
        automated:
          prune: true
          selfHeal: false
  YAML
}