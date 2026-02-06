terraform {
  required_providers {
    kubernetes = { source = "hashicorp/kubernetes" }
    helm       = { source = "hashicorp/helm" }
  }
}

provider "kubernetes" {
  config_path = "/var/jenkins_home/.kube/config"
  insecure    = true
}

provider "helm" {
  kubernetes = {
    config_path = "/var/jenkins_home/.kube/config"
    insecure    = true
  }
}

# --- NAMESPACES ---

resource "kubernetes_namespace_v1" "mern_ns" {
  metadata { name = "mern-stack" }
}

resource "kubernetes_namespace_v1" "monitoring_ns" {
  metadata { name = "monitoring" }
}

# --- MERN APP ---

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
          # Add a placeholder env var to prevent crash if your code expects one
          env {
            name  = "NODE_ENV"
            value = "production"
          }
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

# Service to access the app
resource "kubernetes_service_v1" "mern_service" {
  metadata {
    name      = "mern-service"
    namespace = kubernetes_namespace_v1.mern_ns.metadata[0].name
  }
  spec {
    selector = { app = "mern" }
    port {
      name        = "frontend"
      port        = 80
      target_port = 80
    }
    type = "NodePort"
  }
}

# --- MONITORING ---

resource "helm_release" "prometheus" {
  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus"
  namespace  = kubernetes_namespace_v1.monitoring_ns.metadata[0].name
  # No create_namespace here, we use the resource above
}

resource "helm_release" "grafana" {
  name       = "grafana"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"
  namespace  = kubernetes_namespace_v1.monitoring_ns.metadata[0].name
  
  # Ensure Prometheus is installed before starting Grafana
  depends_on = [helm_release.prometheus]
}