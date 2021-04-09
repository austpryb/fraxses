variable "project_id" {
  default="chainlink-node-pool"
}

variable "sa_email" {
}

variable "gcp_region" {
  default = "us-east1"
}

variable "gcp_zone" {
  default = "us-east1-b"
}

variable "cluster_name" {
  default = "chainlink-node-pool-cluster"
}

variable "ssh_key" {
}

variable "user_email" {
}

variable "eth_url_kovan" {
}

variable "kubernetes_version" {
    default = "1.19.7"
}

variable node_username {
  description = "Chainlink node admin username"
}

variable postgres_username {
  description = "Postgres admin username"
  default     = "admin"
}
