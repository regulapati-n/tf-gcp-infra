variable "project_id" {
  description = "GCP project ID"
}

variable "region" {
  description = "GCP region"
}

variable "vpc_name" {
  description = "Name of the VPC"
}

variable "webapp_subnet_name" {
  description = "Name of the webapp subnet"
}

variable "webapp_subnet_cidr" {
  description = "CIDR range for the webapp subnet"
}

variable "db_subnet_name" {
  description = "Name of the db subnet"
}

variable "db_subnet_cidr" {
  description = "CIDR range for the db subnet"
}

variable "credentials_file" {
  description = "Add path to the credentials file"
}