
provider "kubernetes" {
    host                   =  var.host
    client_certificate     =  var.client_certificate
    client_key             =  var.client_key
    cluster_ca_certificate =  var.cluster_ca_certificate
}

resource "kubernetes_deployment" "external-adapter" {
  metadata {
    name = "external-adapter"
    namespace = "chainlink"
    labels = {
      test = "ExternalAdapter"
    }
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        test = "ExternalAdapter"
      }
    }

    template {
      metadata {
        labels = {
          test = "ExternalAdapter"
        }
      }

      spec {
        container {
          image = "austpryb/external-adapter:001"
          name  = "external-adapter"
          port {
            container_port = 8080
          }
          resources  {
            limits = {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "50Mi"
            }
          }
          # Need to add /alive, 200 endpoint
          #liveness_probe {
          #  http_get {
          #    path = "/alive"
          #    port = 8080
          #  }

          #  initial_delay_seconds = 3
          #  period_seconds        = 3
          #}
        }
      }
    }
  }
}

resource "kubernetes_service" "external-adapter-node-port" {
  metadata {
    name      = "external-adapter-node-port"
    namespace = "chainlink"
  }
  spec {
    selector = {
      app = "ExternalAdapter"
    }
    type = "NodePort"
    port {
      node_port   = 30201
      port        = 8080
      target_port = 8080
    }
  }
}

resource "kubernetes_service" "external-adapter-lb" {
  metadata {
    name = "external-adapter-lb"
    namespace = "chainlink"
  }
  spec {
    selector = {
      test = "DefaultLoadBalancer"
    }
    port {
      port        = 8080
      target_port = 8080
    }

    type = "LoadBalancer"
  }
}

