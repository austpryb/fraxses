resource "kubernetes_deployment" "avalanchego" {
  metadata {
    name = "avalanchego"
    namespace = "chainlink"
    labels = {
      app = "avalanchego"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "avalanchego"
      }
    }

    template {
      metadata {
        labels = {
          app = "avalanchego"
        }
      }

      spec {
        container {
          image = "austpryb/avalanchego:003"
          name  = "avalanchego"
          port {
            container_port = 9650
          }
          resources  {
            limits = {
              cpu    = "3"
              memory = "6Gi"
            }
            requests = {
              cpu    = "2"
              memory = "5Gi"
            }
          }
        }
      }
    }
  }
}

resource "google_compute_address" "avalanchego-ilb" {
  name   = "avalanchego-ilb"
}

resource "google_compute_address" "avalanchego-elb" {
  name   = "avalanchego-elb"
}

/*
resource "kubernetes_service" "nginx" {
  metadata {
    namespace = kubernetes_namespace.chainlink.metadata[0].name
    name      = "nginx"
  }

  spec {
    selector = {
      run = "nginx"
    }

    session_affinity = "ClientIP"

    port {
      protocol    = "TCP"
      port        = 9650
      target_port = 9650
    }

    type             = "LoadBalancer"
    load_balancer_ip = google_compute_address.avalanchego-ilb.address
  }
}
*/

resource "kubernetes_service" "avalanchego-elb" {
  metadata {
    name      = "avalanchego-elb"
    namespace = kubernetes_namespace.chainlink.metadata.0.name
  }
  spec {
    selector = {
      app = "avalanchego-elb"
    }
    type = "LoadBalancer"
    port {
      #node_port   = 9650
      port        = 9650
      target_port = 9650
    }
  }
}

resource "kubernetes_service" "avalanchego-service" {
  metadata {
    name = "avalanchego-node"
    namespace =  kubernetes_namespace.chainlink.metadata.0.name
  }
  spec {
    selector = {
      app = "avalanchego-node"
    }
    type = "NodePort"
    port {
      port        = 9650
      #target_port = 9650
    }
  }
}


resource "google_compute_global_address" "avalanchego-node" {
  name = "avalanchego-node"
}

resource "kubernetes_ingress" "avalanchego-ingress" {
  metadata {
    name = "avalanchego-ingress"
    namespace = kubernetes_namespace.chainlink.metadata.0.name
    annotations = {
      "kubernetes.io/ingress.global-static-ip-name" = google_compute_global_address.avalanchego-node.name
    }
  }
  spec {
    backend {
      service_name = "avalanchego-node"
      service_port = 9650
    }
  }
}

output "avalanchgo-ip" {
  description = "Global IPv4 address for the Load Balancer serving the Chainlink Node"
  value       = google_compute_global_address.avalanchego-node.address
}
output "avalanchego-elb-ip" {
  value = google_compute_address.avalanchego-elb.address
}
output "avalanchego-node-ip" {
  value = google_compute_address.avalanchego-ilb.address
}
