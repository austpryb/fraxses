variable "serviceprinciple_id" {
}

variable "serviceprinciple_key" {
}

variable "location" {
  default = "eastus"
}

variable "resource_group" {
  default = "chainlink-node-pool"
}

variable "cluster_name" {
  default = "chainlink-kubernetes-cluster"
}

variable "kubernetes_version" {
    default = "1.19.7"
}

variable "ssh_key" {
}
