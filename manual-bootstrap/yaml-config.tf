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