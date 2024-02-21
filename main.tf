provider "google" {
  credentials = file(var.credentials_file)
  project     = var.project_id
  region      = var.region
}

resource "google_compute_network" "vpc_network" {
  name                    = var.vpc_name
  auto_create_subnetworks = var.auto_create_subnetworks
  routing_mode            = var.routing_mode
}

resource "google_compute_subnetwork" "webapp_subnet" {
  name          = var.webapp_subnet_name
  network       = google_compute_network.vpc_network.self_link
  ip_cidr_range = var.webapp_subnet_cidr
  region        = var.region
}

resource "google_compute_subnetwork" "db_subnet" {
  name          = var.db_subnet_name
  network       = google_compute_network.vpc_network.self_link
  ip_cidr_range = var.db_subnet_cidr
  region        = var.region
}

resource "google_compute_route" "webapp_route" {
  name                    = var.webapp_route
  network                 = google_compute_network.vpc_network.self_link
  dest_range              = var.webapp_destination
  next_hop_gateway        = var.next_hop_gateway
  priority                = 1000
  tags                    = [google_compute_subnetwork.webapp_subnet.name]
  depends_on              = [google_compute_network.vpc_network]
}

resource "google_compute_firewall" "private_vpc_webapp_firewall" {
  name = var.webapp_firewall_name
  network = google_compute_network.vpc_network.self_link

  allow {
    protocol = var.webapp_firewall_protocol
    ports = var.webapp_firewall_protocol_allow_ports
  }

  source_tags = var.webapp_firewall_source_tags
  target_tags = var.webapp_firewall_target_tags
}

resource "google_compute_firewall" "private_vpc_ssh_firewall" {
  name = var.webapp_subnet_ssh
  network = google_compute_network.vpc_network.self_link

  deny {
    protocol = var.webapp_firewall_protocol
    ports = var.webapp_firewall__protocol_deny_ports
  }

  source_tags = var.webapp_firewall_source_tags
  target_tags = var.webapp_firewall_target_tags
}

resource "google_compute_instance" "webapp_instance" {
  name = var.compute_instance_name
  machine_type = var.machine_type
  zone = var.zone

  tags = var.compute_instance_tags

  boot_disk {
    initialize_params {
      image = var.instance_image
      size = var.instance_size
      type = var.webapp_bootdisk_type
    }
  }

  network_interface {
    network = google_compute_network.vpc_network.name
    subnetwork = google_compute_subnetwork.webapp_subnet.name

    access_config {
      network_tier = var.network_tier
    }
  }
}
