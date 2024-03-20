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


variable "CLUSTER" {
  type    = string
  default = "my-cluster"
}

variable "CREDENTIALS_FILE" {
  type    = string
  default = "deploy.json"
}

variable "KEYS_DIR" {
  type    = string
  default = "../keys"
}

variable "REPOSITORY" {
  type    = string
  default = "my-repository"
}
