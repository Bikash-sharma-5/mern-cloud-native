terraform {
  required_providers {
    kubernetes = { source = "hashicorp/kubernetes" }
    helm       = { source = "hashicorp/helm" }
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config" # Connects to Docker Desktop K8s
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

# 1. Create a Namespace for your App
resource "kubernetes_namespace" "mern_ns" {
  metadata { name = "mern-stack" }
}

# 2. Deploy the Backend & Frontend in one Pod (simplest for local dev)
resource "kubernetes_deployment" "mern_app" {
  metadata {
    name      = "mern-app"
    namespace = kubernetes_namespace.mern_ns.metadata[0].name
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

# 3. Install Prometheus (via Helm)
resource "helm_release" "prometheus" {
  name             = "prometheus"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "prometheus"
  namespace        = "monitoring"
  create_namespace = true
}

# 4. Install Grafana (via Helm)
resource "helm_release" "grafana" {
  name       = "grafana"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"
  namespace  = "monitoring"
}