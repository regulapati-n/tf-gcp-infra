provider "google" {
  credentials = file(var.credentials_file)
  project     = var.project_id
  region      = var.region
}

resource "google_compute_network" "vpc_network" {
  name                    = var.vpc_name
  auto_create_subnetworks = false
  routing_mode            = "REGION"
}

resource "google_compute_subnetwork" "webapp_subnet" {
  name          = var.webapp_subnet_name
  network       = google_compute_network.vpc_network.self_link
  ip_cidr_range = var.webapp_subnet_cidr
  region        = var.region
}

resource "google_compute_subnetwork "db_subnet" {
  name          = var.db_subnet_name
  network       = google_compute_network.vpc_network.self_link
  ip_cidr_range = var.db_subnet_cidr
  region        = var.region
}

resource "google_compute_route" "webapp_route" {
  name                    = "webapp-route"
  network                 = google_compute_network.vpc_network.self_link
  dest_range              = "0.0.0.0/0"
  next_hop_gateway        = "default-internet-gateway"
  priority                = 1000
  tags                    = [google_compute_subnetwork.webapp_subnet.name]
  depends_on              = [google_compute_network.vpc_network]
}
