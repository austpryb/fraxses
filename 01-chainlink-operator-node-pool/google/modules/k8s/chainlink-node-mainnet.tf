
resource "kubernetes_config_map" "chainlink-mainnet-env" {
  metadata {
    name      = "chainlink-mainnet-env"
    namespace = "chainlink"
  }

  data = {
    #"env" = "${file("config/.env")}"
    ROOT = "/chainlink"
    LOG_LEVEL = "debug"
    ETH_CHAIN_ID = 1 # MAINNET
    MIN_OUTGOING_CONFIRMATIONS = 2
    LINK_CONTRACT_ADDRESS = "0x514910771af9ca656af840dff83e8264ecf986ca"
    CHAINLINK_TLS_PORT = 0
    SECURE_COOKIES = false
    ORACLE_CONTRACT_ADDRESS = ""
    ALLOW_ORIGINS = "*"
    MINIMUM_CONTRACT_PAYMENT = 100
    DATABASE_URL = "postgresql://${var.postgres_username}:${random_password.postgres-password.result}@postgres:5432/chainlink-mainnet?sslmode=disable"
    DATABASE_TIMEOUT = 0
    ETH_URL = var.eth_url_kovan
  }
}

resource "kubernetes_deployment" "chainlink-mainnet-node" {
  metadata {
    name = "chainlink-mainnet"
    namespace = "chainlink"
    labels = {
      app = "chainlink-mainnet-node"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "chainlink-mainnet-node"
      }
    }

    template {
      metadata {
        labels = {
          app = "chainlink-mainnet-node"
        }
      }
      spec {
        container {
          image = "smartcontract/chainlink:latest"
          name  = "chainlink-mainnet-node"
          port {
            container_port = 6688
          }
          args = ["local", "n", "-p",  "/chainlink/.password", "-a", "/chainlink/.api"]

          env_from {
            config_map_ref {
              name = "chainlink-mainnet-env"
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

resource "kubernetes_service" "chainlink-mainnet-service" {
  metadata {
    name = "chainlink-mainnet-node"
    namespace = "chainlink"
  }
  spec {
    selector = {
      app = "chainlink-mainnet-node"
    }
    type = "NodePort"
    port {
      port = 6688
    }
  }
}

