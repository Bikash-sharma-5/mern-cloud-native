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
  # FIX: Use the equals sign (=) here instead of just a block
  kubernetes = {
    config_path = "/var/jenkins_home/.kube/config"
  }
}

# Use namespace_v1 for clean code
resource "kubernetes_namespace_v1" "mern_ns" {
  metadata {
    name = "mern-stack"
  }
}

# MERN App Deployment using v1
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

# Monitoring: Prometheus
resource "helm_release" "prometheus" {
  name             = "prometheus"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "prometheus"
  namespace        = "monitoring"
  create_namespace = true
}

# Monitoring: Grafana
resource "helm_release" "grafana" {
  name       = "grafana"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"
  namespace  = "monitoring"
}