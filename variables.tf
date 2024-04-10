variable "credentials_file" {
  description = "Path to the Google Cloud Platform service account key file"
  type        = string
}

variable "project_id" {
  description = "Google Cloud Platform project ID"
  type        = string
}

variable "region" {
  description = "Region where resources will be deployed"
  type        = string
}

variable "vpc_name" {
  description = "Name of the VPC network"
  type        = string
}

variable "routing_mode" {
  description = "Routing mode for the VPC network (REGIONAL or GLOBAL)"
  type        = string
}

variable "auto_create_subnetworks" {
  description = "autocreate subnets(true/false)"
  type        = bool

}
variable "delete_default_route" {
  description = "Whether to delete default routes on network creation"
  type        = bool
}

variable "webapp_subnet_name" {
  description = "Name of the subnet for the web application"
  type        = string
}

variable "webapp_subnet_cidr" {
  description = "CIDR block for the web application subnet"
  type        = string
}

variable "db_subnet_name" {
  description = "Name of the subnet for the database"
  type        = string
}

variable "db_subnet_cidr" {
  description = "CIDR block for the database subnet"
  type        = string
}

variable "webapp_route" {
  description = "Name of the route for the web application"
  type        = string
}

variable "webapp_destination" {
  description = "Destination CIDR for the web application route"
  type        = string
}

variable "next_hop_gateway" {
  description = "Next hop gateway for the web application route"
  type        = string
}

variable "webapp_firewall_name" {
  description = "Name of the firewall for the web application"
  type        = string
}

variable "webapp_firewall_protocol" {
  description = "Protocol for the web application firewall rule (e.g., tcp, udp)"
  type        = string
}

variable "webapp_firewall_protocol_allow_ports" {
  description = "List of ports to allow for the web application firewall rule"
  type        = list(string)
}

variable "webapp_firewall_source_tags" {
  description = "Source tags for the web application firewall rule"
  type        = list(string)
}

variable "webapp_firewall_target_tags" {
  description = "Target tags for the web application firewall rule"
  type        = list(string)
}

variable "webapp_subnet_ssh" {
  description = "Name of the firewall rule for SSH access to the web application subnet"
  type        = string
}

variable "webapp_firewall__protocol_deny_ports" {
  description = "List of ports to deny for the web application SSH firewall rule"
  type        = list(string)
}

variable "compute_instance_name" {
  description = "Name of the compute instance for the web application"
  type        = string
}

variable "machine_type" {
  description = "Machine type for the compute instance"
  type        = string
}

variable "zone" {
  description = "Zone where the compute instance will be located"
  type        = string
}

variable "instance_image" {
  description = "URL of the image for the compute instance"
  type        = string
}

variable "instance_size" {
  description = "Size of the boot disk for the compute instance (in GB)"
  type        = number
}

variable "webapp_bootdisk_type" {
  description = "Type of the boot disk for the compute instance"
  type        = string
}

variable "compute_instance_tags" {
  description = "Tags for the compute instance"
  type        = list(string)
}

variable "network_tier" {
  description = "Network tier for the compute instance"
  type        = string
}

variable "dbinstance_name" {
  description = "Name of the database instance"
  type        = string
}

variable "db_version" {
  description = "Type of database and database version"
  type        = string
}

variable "db_tier" {
  description = "Type of database instance"
  type        = string
}

variable "disk_type" {
  description = "type of disk"
  type        = string
}

variable "disk_size" {
  description = "Size of the disk to create"
  type        = string
}

variable "db_availability" {
  description = "availability type for the sql instance"
  type        = string
}

variable "db_delete" {
  description = "deletion protection for the sql instance"
  type        = bool
}

variable "db_name" {
  description = "name of the database"
  type        = string
}

variable "address_type" {
  description = "type of address"
  type        = string
  default     = "INTERNAL"
}

variable "sa_id" {
  description = "name of service id"
  type        = string
}

variable "sa_name" {
  description = "service account name"
  type        = string
}

variable "dns_zone_name" {
  description = "Cloud DNS zone Name"
  type        = string
}

variable "dns_record_type" {
  description = "Cloud DNS record type"
  type        = string
}

variable "dns_ttl" {
  description = "dns record TTL"
  type        = string
}

variable "apiKey" {
  description = "Mailgun API Key"
  type        = string
}


variable "min_vm" {
  description = "Minimum active vm"
  type = string
}

variable "max_vm" {
  description = "Maximum Vm"
  type = string
}

variable "cpu_target" {
  description = "cpu utilization target for VM"
  type = string
}

variable "cooldown" {
  description = "cooldown period for autoscaler"
  type = string
}

variable "target_size" {
  description = "target size for vm template"
  type = string

}

variable "delay_sec" {
  description = "target size"
  type = string
}

variable "timeout_sec" {
  description = "timeout seconds for webapp backend"
  type = string
}

variable "named_port" {
  description = "named port for group manager"
}

variable "health_check_name" {
  description = "value"
  type = string
}

variable "interval_sec" {
  description = "value"
  type = string

}

variable "healthcheck_timeout" {
  type = string
}

variable "threshold" {
  type = string

}

variable "unhealthy_threshold" {
  type = string

}

variable "auto_scaler_name" {
  type = string

}

variable "region_instance_name" {
  type = string

}

variable "url_name" {
  type = string

}

variable "backend_name" {
  type = string
}

variable "port_range" {
  type = string

}

variable "ssl_name" {
  type = string

}

variable "ssl_type" {
  type = string

}

variable "global_name" {
  type = string

}

variable "cool_down" {
  type = string

}

variable "keyring_name" {
  type = string

}