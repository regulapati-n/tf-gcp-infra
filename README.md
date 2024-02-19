# Terraform Repository for Google Cloud Platform (GCP)

This repository contains Terraform configurations for provisioning resources on Google Cloud Platform (GCP). It sets up infrastructure primarily using Compute Engine instances, along with enabling Google Cloud Build API and Cloud DNS API.

## Configuration Files

- **main.tf**: This file contains the main Terraform configuration for provisioning Compute Engine instances and configuring other necessary resources.
- **vars.tf**: This file defines variables used within the Terraform configuration, allowing customization of parameters such as instance type, region, etc.

## Provisioned Resources

### Compute Engine Instances
Compute Engine instances are provisioned to host applications or services. These instances can be customized based on the provided variables and requirements.

### Enabled APIs
- **Google Cloud Build API**: Enables continuous integration and continuous deployment (CI/CD) pipelines.
- **Cloud DNS API**: Allows management and configuration of DNS records and zones within Google Cloud DNS.

## Usage
To use this Terraform configuration:

1. Ensure you have Terraform installed locally. If not, follow the instructions [here](https://learn.hashicorp.com/tutorials/terraform/install-cli) to install Terraform.
2. Clone this repository to your local machine.
3. Navigate to the cloned directory.
4. Update the variables in `vars.tf` file as per your requirements.
5. Initialize the Terraform configuration by running:
