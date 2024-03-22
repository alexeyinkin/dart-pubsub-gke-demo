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

variable "REPOSITORY" {
  type    = string
  default = "my-repository"
}
