terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.21.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.27.0"
    }
  }
}

provider "google" {
  project = var.PROJECT
  region  = var.REGION
  zone    = var.ZONE
}

data "google_client_config" "default" {
  depends_on = [module.gke]
}

data "google_container_cluster" "my-cluster" {
  name       = var.CLUSTER
  location   = var.ZONE
  depends_on = [module.gke]
}

provider "kubernetes" {
  host                   = "https://${data.google_container_cluster.my-cluster.endpoint}"
  cluster_ca_certificate = base64decode(data.google_container_cluster.my-cluster.master_auth[0].cluster_ca_certificate)
  token                  = data.google_client_config.default.access_token
}
