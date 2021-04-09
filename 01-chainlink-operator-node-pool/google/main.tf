
provider "google" {
  credentials = file("key.json")
  project     = var.project_id
  region      = var.gcp_region
  zone        = var.gcp_zone
}


module "cluster" {
  source                = "./modules/cluster/"
  sa_email              = var.sa_email
  user_email            = var.user_email
  ssh_key               = var.ssh_key
  gcp_region            = var.gcp_region
  gcp_zone              = var.gcp_zone
  cluster_name          = var.cluster_name
  kubernetes_version    = var.kubernetes_version
}

module "k8s" {
  source                = "./modules/k8s/"
  host                  = "${module.cluster.endpoint}"
# token                 = "${module.cluster.token}" # used in azure cluster auth
  cluster_ca_certificate= "${base64decode(module.cluster.cluster_ca_certificate)}"
  node_username         = var.user_email
  eth_url_kovan         = var.eth_url_kovan 
}
