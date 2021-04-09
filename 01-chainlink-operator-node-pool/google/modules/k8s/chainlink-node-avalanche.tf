
resource "kubernetes_config_map" "chainlink-avalanche-env" {
  metadata {
    name      = "chainlink-avalanche-env"
    namespace = "chainlink"
  }

  data = {
    #"env" = "${file("config/.env")}"
    ROOT = "/chainlink"
    LOG_LEVEL = "debug"
    ETH_CHAIN_ID = 1 # MAINNET
    MIN_OUTGOING_CONFIRMATIONS = 2
    LINK_CONTRACT_ADDRESS = "<NOT IMPLEMENTED>"
    CHAINLINK_TLS_PORT = 0
    SECURE_COOKIES = false
    ORACLE_CONTRACT_ADDRESS = ""
    ALLOW_ORIGINS = "*"
    MINIMUM_CONTRACT_PAYMENT = 100
    DATABASE_URL = "postgresql://${var.postgres_username}:${random_password.postgres-password.result}@postgres:5432/chainlink-avalanche?sslmode=disable"
    DATABASE_TIMEOUT = 0
    ETH_URL = var.eth_url_kovan
  }
}

resource "kubernetes_deployment" "chainlink-avalanche-node" {
  metadata {
    name = "chainlink-avalanche"
    namespace = "chainlink"
    labels = {
      app = "chainlink-avalanche-node"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "chainlink-avalanche-node"
      }
    }

    template {
      metadata {
        labels = {
          app = "chainlink-avalanche-node"
        }
      }
      spec {
        container {
          image = "smartcontract/chainlink:latest"
          name  = "chainlink-avalanche-node"
          port {
            container_port = 6688
          }
          args = ["local", "n", "-p",  "/chainlink/.password", "-a", "/chainlink/.api"]

          env_from {
            config_map_ref {
              name = "chainlink-avalanche-env"
            }
          }

          volume_mount {
            name        = "api-volume"
            sub_path    = "api"
            mount_path  = "/chainlink/.api"
          }

          volume_mount {
            name        = "password-volume"
            sub_path    = "password"
            mount_path  = "/chainlink/.password"
          }
        }
        
        volume {
          name = "api-volume"
          secret {
            secret_name = "api-credentials" 
          }
        }
        volume {
          name = "password-volume"
          secret {
            secret_name = "password-credentials" 
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "chainlink-avalanche-service" {
  metadata {
    name = "chainlink-avalanche-node"
    namespace = "chainlink"
  }
  spec {
    selector = {
      app = "chainlink-avalanche-node"
    }
    type = "NodePort"
    port {
      port = 6688
    }
  }
}

