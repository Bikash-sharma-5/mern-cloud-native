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

# --- 1. NAMESPACES ---

resource "kubernetes_namespace_v1" "mern_ns" {
  metadata { name = "mern-stack" }
}

resource "kubernetes_namespace_v1" "monitoring_ns" {
  metadata { name = "monitoring" }
}

# --- 2. MONGODB DATABASE ---

resource "kubernetes_deployment_v1" "mongodb" {
  metadata {
    name      = "mongodb"
    namespace = kubernetes_namespace_v1.mern_ns.metadata[0].name
  }
  spec {
    replicas = 1
    selector { match_labels = { app = "mongodb" } }
    template {
      metadata { labels = { app = "mongodb" } }
      spec {
        container {
          name  = "mongodb"
          image = "mongo:latest"
          port { container_port = 27017 }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "mongodb_service" {
  metadata {
    name      = "mongodb-service"
    namespace = kubernetes_namespace_v1.mern_ns.metadata[0].name
  }
  spec {
    selector = { app = "mongodb" }
    port {
      port        = 27017
      target_port = 27017
    }
  }
}

# --- 3. MERN APPLICATION (Frontend & Backend) ---

resource "kubernetes_deployment_v1" "mern_app" {
  depends_on = [kubernetes_deployment_v1.mongodb]
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
          env {
            name  = "MONGO_URI"
            value = "mongodb://mongodb-service:27017/mern_db"
          }
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
    type = "LoadBalancer"
  }
}

# --- 4. MONITORING (Prometheus & Grafana) ---

resource "helm_release" "prometheus" {
  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus"
  namespace  = kubernetes_namespace_v1.monitoring_ns.metadata[0].name
}

resource "helm_release" "grafana" {
  name       = "grafana"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"
  namespace  = kubernetes_namespace_v1.monitoring_ns.metadata[0].name
  depends_on = [helm_release.prometheus]
}