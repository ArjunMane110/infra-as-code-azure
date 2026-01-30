variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "tenant_id" {
  description = "Azure tenant ID"
  type        = string
}

variable "location" {
  description = "Azure region for deployment"
  type        = string
  default     = "East US"
}

variable "environment" {
  description = "Deployment environment (dev, test, prod)"
  type        = string
  default     = "dev"
}

# -------------------------
# Linux VM variables
# -------------------------

variable "linux_admin_username" {
  description = "Admin username for the Linux VM"
  type        = string
  default     = "azureuser"
}

variable "linux_vm_size" {
  description = "Linux VM size"
  type        = string
  default     = "Standard_B1s"
}

variable "ssh_public_key_path" {
  description = "Absolute path to SSH public key used for Linux VM access"
  type        = string
}

# -------------------------
# Windows VM variables
# -------------------------

variable "windows_vm_size" {
  description = "Windows VM size"
  type        = string
  default     = "Standard_B2s"
}

variable "windows_admin_username" {
  description = "Admin username for the Windows VM"
  type        = string
}

variable "windows_admin_password" {
  description = "Admin password for the Windows VM"
  type        = string
  sensitive   = true
}

variable "windows_vm_size_2" {
  description = "Windows VM size for the second Windows VM"
  type        = string
  default     = "Standard_B2s"
}

variable "windows_admin_username_2" {
  description = "Admin username for the Windows VM 2"
  type        = string
}

variable "windows_admin_password_2" {
  description = "Admin password for the Windows VM 2"
  type        = string
  sensitive   = true
}