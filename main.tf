provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_compute_network" "vpc_network" {
  name                    = var.vpc_name
  auto_create_subnetworks = var.auto_create_subnetworks
  routing_mode            = var.routing_mode
}

resource "google_compute_global_address" "private_ip_address" {
  name          = "private-ip-address"
  purpose       = "VPC_PEERING"
  address_type  = var.address_type
  prefix_length = 16
  network       = google_compute_network.vpc_network.self_link
}

resource "google_service_networking_connection" "cloud_sql" {
  network                 = google_compute_network.vpc_network.self_link
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
  deletion_policy         = "ABANDON"
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
  name             = var.webapp_route
  network          = google_compute_network.vpc_network.self_link
  dest_range       = var.webapp_destination
  next_hop_gateway = var.next_hop_gateway
  priority         = 1000
  tags             = [google_compute_subnetwork.webapp_subnet.name]
  depends_on       = [google_compute_network.vpc_network]
}

resource "google_compute_firewall" "private_vpc_webapp_firewall" {
  name    = var.webapp_firewall_name
  network = google_compute_network.vpc_network.self_link

  allow {
    protocol = var.webapp_firewall_protocol
    ports    = var.webapp_firewall_protocol_allow_ports
  }

  source_tags = var.webapp_firewall_source_tags
  target_tags = var.webapp_firewall_target_tags
}

resource "google_compute_firewall" "private_vpc_ssh_firewall" {
  name    = var.webapp_subnet_ssh
  network = google_compute_network.vpc_network.self_link

  deny {
    protocol = var.webapp_firewall_protocol
    ports    = var.webapp_firewall__protocol_deny_ports
  }

  source_tags = var.webapp_firewall_source_tags
  target_tags = var.webapp_firewall_target_tags
}

resource "google_service_account" "service_account" {
  account_id   = "webapp-sa"
  display_name = "Custom SA for VM Instance"
}

resource "google_project_iam_binding" "logging_admin_binding" {
  project = var.project_id
  role    = "roles/logging.admin"

  members = [
    "serviceAccount:${google_service_account.service_account.email}"
  ]
}

resource "google_project_iam_binding" "monitoring_metric_writer_binding" {
  project = var.project_id
  role    = "roles/monitoring.metricWriter"

  members = [
    "serviceAccount:${google_service_account.service_account.email}"
  ]
}

resource "google_compute_instance" "webapp_instance" {
  name         = var.compute_instance_name
  machine_type = var.machine_type
  zone         = var.zone

  tags = var.compute_instance_tags

  service_account {
    email  = google_service_account.service_account.email
    scopes = ["cloud-platform"]
  }


  boot_disk {
    initialize_params {
      image = var.instance_image
      size  = var.instance_size
      type  = var.webapp_bootdisk_type
    }
  }

  network_interface {
    network    = google_compute_network.vpc_network.name
    subnetwork = google_compute_subnetwork.webapp_subnet.name

    access_config {
      network_tier = var.network_tier
    }
  }

  metadata_startup_script = <<-EOF
    #!/bin/bash
    echo "spring.datasource.url=jdbc:mysql://${google_sql_database_instance.my_db_instance.private_ip_address}:3306/webapp?createDatabaseIfNotExist=true" >> /opt/csye6225/application.properties
    echo "spring.datasource.username=webapp" >> /opt/csye6225/application.properties
    echo "spring.datasource.password=${random_password.user_password.result}" >> /opt/csye6225/application.properties
    echo "spring.jpa.hibernate.ddl-auto=update" >> /opt/csye6225/application.properties
    echo "spring.jpa.properties.hibernate.dialect=org.hibernate.dialect.MySQLDialect" >> /opt/csye6225/application.properties
    echo "projectId=dev-demo-415618" >> /opt/csye6225/application.properties
    echo "topicId=verify_email" >> /opt/csye6225/application.properties
  EOF
}


resource "google_sql_database_instance" "my_db_instance" {
  name             = var.dbinstance_name
  database_version = var.db_version
  region           = var.region
  settings {
    tier              = var.db_tier
    availability_type = var.db_availability
    disk_size         = var.disk_size
    disk_type         = var.disk_type
    ip_configuration {
      ipv4_enabled    = false
      private_network = google_compute_network.vpc_network.self_link
    }

    backup_configuration {
      enabled            = true
      binary_log_enabled = true
    }

  }
  deletion_protection = var.db_delete
  depends_on          = [google_service_networking_connection.cloud_sql]
}

output "cloud_sql_instance_ip_address" {
  value = google_sql_database_instance.my_db_instance.private_ip_address
}

resource "google_sql_database" "database" {
  name     = var.db_name
  instance = google_sql_database_instance.my_db_instance.name
}
resource "random_password" "user_password" {
  length           = 8
  special          = true
  override_special = "-"
}

resource "google_sql_user" "database_user" {
  name       = var.db_name
  instance   = google_sql_database_instance.my_db_instance.name
  password   = random_password.user_password.result
  depends_on = [google_sql_database_instance.my_db_instance]
}

data "google_dns_managed_zone" "nixor_zone" {
  name = "nixor"

}

resource "google_dns_record_set" "webapp_record" {
  managed_zone = data.google_dns_managed_zone.nixor_zone.name
  name         = data.google_dns_managed_zone.nixor_zone.dns_name # Empty string for root domain
  type         = "A"
  ttl          = 300
  rrdatas = [
    google_compute_instance.webapp_instance.network_interface[0].access_config[0].nat_ip
  ]
  depends_on = [google_compute_instance.webapp_instance]
}

resource "google_storage_bucket" "webapp_bucket" {
  name     = "nixor-bucket"
  location = "US"
}

resource "google_pubsub_topic" "verify_email" {
  name = "verify_email"
  labels = {
    foo = "bar"
  }
  message_retention_duration = "6048s"
}


resource "google_pubsub_subscription" "webapp_subscription" {
  name                 = "webapp-subscription"
  topic                = google_pubsub_topic.verify_email.id
  ack_deadline_seconds = 20
}

resource "google_project_iam_binding" "creator" {
  project = var.project_id
  role    = "roles/iam.serviceAccountTokenCreator"
  members = [
    "serviceAccount:${google_service_account.service_account.email}",
  ]
}

resource "google_storage_bucket_object" "archive" {
  name   = "function"
  bucket = google_storage_bucket.webapp_bucket.name
  source = "/Users/nikhilregulapati/Desktop/function-source-3/Archive.zip"
}

resource "google_cloudfunctions2_function" "cloud_function" {
  name        = "cloudfunction"
  location    = var.region
  description = "abcd"

  depends_on = [google_vpc_access_connector.serverlessvpc, google_sql_database_instance.my_db_instance]
  build_config {
    runtime     = "java17"
    entry_point = "gcfv2pubsub.PubSubFunction"

    source {
      storage_source {
        bucket = google_storage_bucket.webapp_bucket.name
        object = google_storage_bucket_object.archive.name
      }
    }
  }

  service_config {
    min_instance_count               = 0
    max_instance_count               = 1
    available_memory                 = "2Gi"
    max_instance_request_concurrency = 10
    available_cpu                    = "2"
    service_account_email            = google_service_account.cloudfunction_service.email
    environment_variables = {
      dbUrl    = "jdbc:mysql://${google_sql_database_instance.my_db_instance.private_ip_address}:3306/webapp?createDatabaseIfNotExist=true"
      dbName   = google_sql_database.database.name
      dbPass   = "${random_password.user_password.result}"
      api_key  = var.apiKey
    }
    vpc_connector                 = "projects/${var.project_id}/locations/${var.region}/connectors/${google_vpc_access_connector.serverlessvpc.name}"
    vpc_connector_egress_settings = "PRIVATE_RANGES_ONLY"

  }


  #  vpc
  event_trigger {
    trigger_region = var.region
    event_type     = "google.cloud.pubsub.topic.v1.messagePublished"
    pubsub_topic   = google_pubsub_topic.verify_email.id
    retry_policy   = "RETRY_POLICY_DO_NOT_RETRY"
  }
}
resource "google_project_iam_binding" "pubsub_publisher_binding" {
  project = var.project_id
  role    = "roles/pubsub.publisher"

  members = [
    "serviceAccount:${google_service_account.service_account.email}"
  ]
}

resource "google_vpc_access_connector" "serverlessvpc" {
  project       = var.project_id
  name          = "vpcconnectorx"
  region        = var.region
  network       = google_compute_network.vpc_network.name
  ip_cidr_range = "10.0.8.0/28"
}


resource "google_service_account" "cloudfunction_service" {
  account_id   = "cloud-sa"
  display_name = "cloud service account"
}

resource "google_project_iam_binding" "invoker_binding" {
  members = ["serviceAccount:${google_service_account.cloudfunction_service.email}"]
  project = var.project_id
  role    = "roles/run.invoker"
}

#resource "google_service_account_iam_member" "member_service" {
#  service_account_id = google_service_account.cloudfunction_service.id
#  role     = "roles/iam.serviceAccountUser"
#  member = google_service_account.cloudfunction_service.email
#}



