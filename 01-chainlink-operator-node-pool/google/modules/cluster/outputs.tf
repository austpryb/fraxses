output "cluster_username" {
  value = google_container_cluster.chainlink-node-pool.master_auth[0].username
}

output "cluster_password" {
  value = google_container_cluster.chainlink-node-pool.master_auth[0].password
}

output "endpoint" {
  value = google_container_cluster.chainlink-node-pool.endpoint
}

output "instance_group_urls" {
  value = google_container_cluster.chainlink-node-pool.instance_group_urls
}

output "node_config" {
  value = google_container_cluster.chainlink-node-pool.node_config
}

output "node_pools" {
  value = google_container_cluster.chainlink-node-pool.node_pool
}

output "cluster_ca_certificate" {
  value = google_container_cluster.chainlink-node-pool.master_auth.0.cluster_ca_certificate
}
