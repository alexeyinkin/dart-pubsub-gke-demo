module "basics" {
  source = "./basics"

  PROJECT = var.PROJECT
}

data "google_service_account" "gke-minimal" {
  account_id = "gke-minimal"
  depends_on = [module.basics]
}

data "google_service_account" "capitalizer" {
  account_id = "capitalizer"
  depends_on = [module.basics]
}


module "gke" {
  depends_on = [module.basics]
  source     = "./gke"

  PROJECT               = var.PROJECT
  ZONE                  = var.ZONE
  CLUSTER               = var.CLUSTER
  SERVICE_ACCOUNT_EMAIL = data.google_service_account.gke-minimal.email
}


module "deployment" {
  depends_on = [module.gke]
  source     = "./deployment"

  PROJECT    = var.PROJECT
  REGION     = var.REGION
  ZONE       = var.ZONE
  VERSION    = var.VERSION
  REPOSITORY = var.REPOSITORY

  CAPITALIZER_EMAIL = data.google_service_account.capitalizer.email
}
