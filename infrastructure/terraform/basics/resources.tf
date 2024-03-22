resource "google_pubsub_topic" "input" {
  name                       = "input"
  message_retention_duration = "86400s"
}

resource "google_pubsub_subscription" "input-sub" {
  name                 = "input-sub"
  topic                = google_pubsub_topic.input.name
  ack_deadline_seconds = 600
}

resource "google_pubsub_topic" "output" {
  name                       = "output"
  message_retention_duration = "86400s"
}

resource "google_pubsub_subscription" "output-sub" {
  name                 = "output-sub"
  topic                = google_pubsub_topic.output.name
  ack_deadline_seconds = 600
}


resource "google_project_iam_custom_role" "MyPubSubConsumer" {
  role_id     = "MyPubSubConsumer"
  title       = "MyPubSubConsumer"
  description = "A minimal role to consume messages. It's weaker than the built-in 'Pub/Sub Subscriber' by not allowing to create subscriptions. It's stronger by allowing to list the subscriptions because Google client library lists subscriptions before consuming."

  permissions = [
    "pubsub.subscriptions.consume",
    "pubsub.subscriptions.get",
  ]
}

resource "google_project_iam_custom_role" "MyPubSubPublisher" {
  role_id     = "MyPubSubPublisher"
  title       = "MyPubSubPublisher"
  description = "A minimal role to publish messages. It's stronger than the built-in 'Pub/Sub Publisher' by allowing to list the topics because Google client library lists topics before publishing."

  permissions = [
    "pubsub.topics.get",
    "pubsub.topics.publish",
  ]
}


resource "google_service_account" "gke-minimal" {
  account_id  = "gke-minimal"
  description = "For GKE nodes. Uses the minimal permissions + ability to read images."
  # https://cloud.google.com/kubernetes-engine/docs/how-to/hardening-your-cluster#use_least_privilege_sa
}

resource "google_project_iam_member" "gke-minimal_logWriter" {
  project = var.PROJECT
  role    = "roles/logging.logWriter"
  member  = google_service_account.gke-minimal.member
}

resource "google_project_iam_member" "gke-minimal_monitoring_metricWriter" {
  project = var.PROJECT
  role    = "roles/monitoring.metricWriter"
  member  = google_service_account.gke-minimal.member
}

resource "google_project_iam_member" "gke-minimal_monitoring_viewer" {
  project = var.PROJECT
  role    = "roles/monitoring.viewer"
  member  = google_service_account.gke-minimal.member
}

resource "google_project_iam_member" "gke-minimal_stackdriver_resourceMetadata_writer" {
  project = var.PROJECT
  role    = "roles/stackdriver.resourceMetadata.writer"
  member  = google_service_account.gke-minimal.member
}

resource "google_project_iam_member" "gke-minimal_autoscaling_metricsWriter" {
  project = var.PROJECT
  role    = "roles/autoscaling.metricsWriter"
  member  = google_service_account.gke-minimal.member
}

resource "google_project_iam_member" "gke-minimal_artifactregistry_reader" {
  project = var.PROJECT
  role    = "roles/artifactregistry.reader"
  member  = google_service_account.gke-minimal.member
}


resource "google_service_account" "capitalizer" {
  account_id = "capitalizer"
}

resource "google_pubsub_subscription_iam_member" "capitalizer_input-sub_MyPubSubConsumer" {
  subscription = google_pubsub_subscription.input-sub.name
  role         = google_project_iam_custom_role.MyPubSubConsumer.name
  member       = google_service_account.capitalizer.member
}

resource "google_pubsub_topic_iam_member" "capitalizer_output_MyPubSubPublisher" {
  topic  = google_pubsub_topic.output.name
  role   = google_project_iam_custom_role.MyPubSubPublisher.name
  member = google_service_account.capitalizer.member
}
