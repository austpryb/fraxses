variable "serviceprinciple_id" {
}

variable "serviceprinciple_key" {
}

variable "tenant_id" {
}

variable "subscription_id" {
}


variable "ssh_key" {
}

variable "location" {
  default = "eastus"
}

variable "resource_group" {
  default = "chainlink-node-pool"
}

variable "cluster_name" {
  default = "chainlink-node-pool-cluster"
}

variable "eth_url_kovan" {
}

variable "kubernetes_version" {
    default = "1.19.7"
}

variable node_username {
  description = "Chainlink node admin username"
  default     = "admin"
}

variable postgres_username {
  description = "Postgres admin username"
  default     = "admin"
}
