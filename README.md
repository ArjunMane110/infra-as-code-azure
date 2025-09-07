# infra-as-code-azure
Azure Core Infrastructure with Terraform

This project provisions a foundational Azure infrastructure stack using Terraform. It creates:

Resource Group

Virtual Network and Subnet

Network Security Group with rules

Public IP and Network Interface

Linux Virtual Machine

The setup is tagged for development and designed to be extended with PaaS services such as Web Apps, Function Apps, Container Registry, and Key Vault.

Prerequisites

Terraform
 v1.0+

Azure CLI installed and logged in:

az login


An SSH key pair (default: ~/.ssh/id_rsa on Linux, ~/.ssh/id_ed25519 on macOS)

Files

main.tf – Core Azure resources

variables.tf – Input variable definitions

terraform.tfvars – Default values (Linux host)

osx.tfvars – macOS-specific overrides

Usage
1. Initialize Terraform
terraform init

2. Validate configuration
terraform validate

3. Plan deployment

For Linux host (default):

terraform plan


For macOS host:

terraform plan -var-file="osx.tfvars"

4. Apply deployment

For Linux:

terraform apply


For macOS:

terraform apply -var-file="osx.tfvars"

Outputs

After apply, Terraform will output:

public_ip_address – The VM’s public IP

Cleanup

To destroy all resources created by this project:

terraform destroy



<img width="390" height="454" alt="image" src="https://github.com/user-attachments/assets/2d936b04-0fb9-4796-bc10-cd95fe15def5" />
