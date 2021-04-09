resource "kubernetes_namespace" "chainlink" {
  metadata {
    name = "chainlink"
  }
}

resource "kubernetes_config_map" "chainlink-env" {
  metadata {
    name      = "chainlink-env"
    namespace = "chainlink"
  }

  data = {
    #"env" = "${file("config/.env")}"
    ROOT = "/chainlink"
    LOG_LEVEL = "debug"
    ETH_CHAIN_ID = 42 # KOVAN
    MIN_OUTGOING_CONFIRMATIONS = 2
    LINK_CONTRACT_ADDRESS = "0xa36085F69e2889c224210F603D836748e7dC0088"
    CHAINLINK_TLS_PORT = 0
    SECURE_COOKIES = false
    ORACLE_CONTRACT_ADDRESS = ""
    ALLOW_ORIGINS = "*"
    MINIMUM_CONTRACT_PAYMENT = 100
    DATABASE_URL = "postgresql://${var.postgres_username}:${random_password.postgres-password.result}@postgres:5432/chainlink?sslmode=disable"
    DATABASE_TIMEOUT = 0
    ETH_URL = var.eth_url_kovan
  }
}


resource "random_password" "api-password" {
  length  = 16
  special = false
}

resource "random_password" "wallet-password" {
  length  = 16
  special = false
}

output "api-credentials" {
  value = "${random_password.api-password.result}"
  #sensitive   = true 
}

output "wallet-credentials" {
  value = "${random_password.wallet-password.result}"
  #sensitive   = true
}

resource "kubernetes_secret" "api-credentials" {
  metadata {
    name      = "api-credentials"
    namespace = "chainlink"
  }

  data = {
    api = "${var.node_username}\n${random_password.api-password.result}"

  }
}

resource "kubernetes_secret" "password-credentials" {
  metadata {
    name      = "password-credentials"
    namespace = "chainlink"
  }

  data = {
    password = "${random_password.wallet-password.result}"
  }
}


#todo env vars to populate $POSTGRES_USER:$POSTGRES_PASS@$POSTGRES_HOST:$POSTGRES_PORT/db
#getting it from resource "kubernetes_config_map" "postgres"
resource "kubernetes_deployment" "chainlink-node" {
  metadata {
    name = "chainlink"
    namespace = "chainlink"
    labels = {
      app = "chainlink-node"
    }
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "chainlink-node"
      }
    }

    template {
      metadata {
        labels = {
          app = "chainlink-node"
        }
      }
      spec {
        container {
          image = "smartcontract/chainlink:latest"
          name  = "chainlink-node"
          port {
            container_port = 6688
          }
          args = ["local", "n", "-p",  "/chainlink/.password", "-a", "/chainlink/.api"]

          env_from {
            config_map_ref {
              name = "chainlink-env"
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

resource "kubernetes_service" "chainlink_service" {
  metadata {
    name = "chainlink-node"
    namespace = "chainlink"
  }
  spec {
    selector = {
      app = "chainlink-node"
    }
    type = "NodePort"
    port {
      port = 6688
    }
  }
}

