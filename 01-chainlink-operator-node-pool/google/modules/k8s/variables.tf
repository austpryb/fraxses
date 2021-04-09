variable "host" {
}

#variable "token" {
#}

variable "cluster_ca_certificate" {
}

variable "eth_url_kovan" {
}

variable node_username {
  description = "Chainlink node admin username"
}

variable postgres_username {
  description = "Postgres admin username"
  default     = "admin"
}
