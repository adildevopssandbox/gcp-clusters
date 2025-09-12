variable "project_id" {
  type = string
}

variable "region" {
  type    = string
  default = "us-central1"
}

variable "zone" {
  type    = string
  default = "us-central1-a"
}

variable "backend_bucket" {
  type    = string
  default = ""
}

variable "cluster_name" {
  type    = string
  default = "gke-cluster1"
}

variable "subnet1_cidr" {
  type    = string
  default = "10.10.0.0/24"
}

variable "subnet2_cidr" {
  type    = string
  default = "10.10.1.0/24"
}

variable "pods_cidr" {
  type    = string
  default = "10.20.0.0/14"
}

variable "services_cidr" {
  type    = string
  default = "10.24.0.0/20"
}

variable "node_machine_type" {
  type    = string
  default = "e2-micro"
}

variable "node_count" {
  type    = number
  default = 2
}

# gke admin
variable "admin_user_email" {
  type    = string
  default = ""
}

# cluster deletion protection
variable "deletion_protection" {
  type    = bool
  default = false
}