resource "google_container_cluster" "my-cluster" {
  name     = var.CLUSTER
  location = var.ZONE

  workload_identity_config {
    workload_pool = "${var.PROJECT}.svc.id.goog"
  }

  initial_node_count = 1

  remove_default_node_pool = true
  deletion_protection      = false

  node_config {
    service_account = var.SERVICE_ACCOUNT_EMAIL
  }
}

resource "google_container_node_pool" "my-pool" {
  name       = "my-pool"
  location   = var.ZONE
  cluster    = google_container_cluster.my-cluster.name
  node_count = 1

  node_config {
    machine_type    = "e2-medium"
    service_account = var.SERVICE_ACCOUNT_EMAIL
  }
}
