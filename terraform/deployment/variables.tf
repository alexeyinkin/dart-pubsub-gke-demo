variable "CAPITALIZER_EMAIL" {
  type = string
}

variable "PROJECT" {
  type = string
}

variable "REGION" {
  type = string
}

variable "VERSION" {
  type = string
}

variable "ZONE" {
  type = string
}


variable "DEPLOYMENT_NAME" {
  type    = string
  default = "dart-pubsub-gke-demo"
}

variable "REPOSITORY" {
  type    = string
  default = "my-repository"
}
