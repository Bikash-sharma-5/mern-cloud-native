terraform {
  required_providers {
    kubernetes = { source = "hashicorp/kubernetes" }
    helm       = { source = "hashicorp/helm" }
  }
}

provider "kubernetes" {
  config_path = "/var/jenkins_home/.kube/config"
}

provider "helm" {
  kubernetes = {
    config_path = "/var/jenkins_home/.kube/config"
  }
}

# 1. Create Namespace
resource "kubernetes_namespace_v1" "mern_ns" {
  metadata { name = "mern-stack" }
}

# 2. MERN App Deployment
resource "kubernetes_deployment_v1" "mern_app" {
  metadata {
    name      = "mern-app"
    namespace = kubernetes_namespace_v1.mern_ns.metadata[0].name
  }
  spec {
    replicas = 1
    selector { match_labels = { app = "mern" } }
    template {
      metadata { labels = { app = "mern" } }
      spec {
        container {
          name  = "backend"
          image = "sharmajikechhotebete/mern-backend:latest"
          port { container_port = 5000 }
        }
        container {
          name  = "frontend"
          image = "sharmajikechhotebete/mern-frontend:latest"
          port { container_port = 80 }
        }
      }
    }
  }
}

# 3. Prometheus
resource "helm_release" "prometheus" {
  name             = "prometheus"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "prometheus"
  namespace        = "monitoring"
  create_namespace = true
}

# 4. Grafana
resource "helm_release" "grafana" {
  name       = "grafana"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"
  namespace  = "monitoring"
}