# See:
# https://cloud.google.com/kubernetes-engine/docs/how-to/workload-identity

resource "kubernetes_service_account" "capitalizer" {
  metadata {
    name = "capitalizer"
    annotations = {
      "iam.gke.io/gcp-service-account" = var.CAPITALIZER_EMAIL
    }
  }
}

resource "google_service_account_iam_member" "workload_identity_user" {
  service_account_id = "projects/${var.PROJECT}/serviceAccounts/${var.CAPITALIZER_EMAIL}"
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.PROJECT}.svc.id.goog[default/${kubernetes_service_account.capitalizer.metadata[0].name}]"
}

resource "kubernetes_deployment" "dart-pubsub-gke-demo" {
  metadata {
    name = var.DEPLOYMENT_NAME
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        app = var.DEPLOYMENT_NAME
      }
    }
    template {
      metadata {
        labels = {
          app = var.DEPLOYMENT_NAME
        }
      }
      spec {
        service_account_name = kubernetes_service_account.capitalizer.metadata[0].name
        container {
          name  = "example"
          image = "${var.REGION}-docker.pkg.dev/${var.PROJECT}/${var.REPOSITORY}/capitalizer:${var.VERSION}"

          env {
            name  = "PROJECT"
            value = var.PROJECT
          }
        }
      }
    }
  }
}
