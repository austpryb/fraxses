resource "google_project_service" "container_api" {
  service                    = "container.googleapis.com"
  disable_dependent_services = true
}

resource "google_service_account" "chainlink-node-pool" {
  account_id   = "cl-gke-nodes"
  display_name = "Service Account used by Kubernetes Cluster"
}

resource "google_container_cluster" "chainlink-node-pool" {
  name     = var.cluster_name
  location = var.gcp_zone

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 3

  enable_legacy_abac = false

  depends_on = [
    google_project_service.container_api
  ]
}

resource "google_container_node_pool" "main_nodes" {
  name = "main-nodes"
  cluster    = google_container_cluster.chainlink-node-pool.name
  node_count = 3

  node_config {
    image_type   = "COS"
    disk_size_gb = 100
    disk_type    = "pd-standard"
    machine_type = "e2-standard-4"

    metadata = {
      disable-legacy-endpoints = "true"
    }
    service_account = google_service_account.chainlink-node-pool.email

    oauth_scopes = [
      "cloud-platform"
    ]
  }
}
