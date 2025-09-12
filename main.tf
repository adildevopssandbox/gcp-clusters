resource "google_compute_network" "vpc1" {
  name                    = "vpc1"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet1" {
  name          = "subnet1"
  region        = var.region
  network       = google_compute_network.vpc1.id
  ip_cidr_range = var.subnet1_cidr

  secondary_ip_range {
    range_name    = "pods1"
    ip_cidr_range = var.pods_cidr
  }
  secondary_ip_range {
    range_name    = "services1"
    ip_cidr_range = var.services_cidr
  }
}

resource "google_compute_subnetwork" "subnet2" {
  name          = "subnet2"
  region        = var.region
  network       = google_compute_network.vpc1.id
  ip_cidr_range = var.subnet2_cidr
}

resource "google_project_iam_member" "clusterrole1" {
  project = var.project_id
  role    = "roles/container.admin"
  member  = "user:${var.admin_user_email}"
}

resource "google_service_account" "nodesa1" {
  account_id   = "nodesa1"
  display_name = "nodesa1"
}

resource "google_project_iam_member" "noderole_service_account" {
  project = var.project_id
  role    = "roles/container.nodeServiceAccount"
}

resource "google_project_iam_member" "noderole_logging" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.nodesa1.email}"
}

resource "google_project_iam_member" "noderole_monitor" {
  project = var.project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.nodesa1.email}"
}

resource "google_container_cluster" "cluster1" {
  name       = var.cluster_name
  location   = var.zone
  network    = google_compute_network.vpc1.id
  subnetwork = google_compute_subnetwork.subnet1.name

  ip_allocation_policy {
    cluster_secondary_range_name  = "pods1"
    services_secondary_range_name = "services1"
  }

  remove_default_node_pool = true
  initial_node_count       = 1
}

resource "google_container_node_pool" "nodepool1" {
  name     = "nodepool1"
  cluster  = google_container_cluster.cluster1.name
  location = var.zone

  node_count = var.node_count

  node_config {
    machine_type    = var.node_machine_type
    service_account = google_service_account.nodesa1.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/trace.append"
    ]
  }

  depends_on = [
    google_container_cluster.cluster1,
    google_project_iam_member.noderole_service_account
  ]
}

output "cluster_endpoint" {
  value = google_container_cluster.cluster1.endpoint
}
