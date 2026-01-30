terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
}

# -------------------------
# Resource Group
# -------------------------
resource "azurerm_resource_group" "rg" {
  name     = "rg-core"
  location = var.location

  tags = {
    environment = var.environment
    managed_by = "terraform"
  }
}

# -------------------------
# Networking
# -------------------------
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-core"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.12.0.0/16"]

  tags = {
    environment = var.environment
  }
}

resource "azurerm_subnet" "subnet" {
  name                 = "subnet-core"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.12.1.0/24"]
}

# -------------------------
# NSG
# -------------------------
resource "azurerm_network_security_group" "nsg" {
  name                = "nsg-core"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# SSH
resource "azurerm_network_security_rule" "ssh" {
  name                        = "allow-ssh"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

# RDP
resource "azurerm_network_security_rule" "rdp" {
  name                        = "allow-rdp"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3389"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

resource "azurerm_subnet_network_security_group_association" "subnet_assoc" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# -------------------------
# Public IPs
# -------------------------
resource "azurerm_public_ip" "linux_pip" {
  name                = "pip-linux"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
}

resource "azurerm_public_ip" "windows_pip" {
  name                = "pip-windows"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
}

# -------------------------
# NICs (one per VM — required)
# -------------------------
resource "azurerm_network_interface" "linux_nic" {
  name                = "nic-linux"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.linux_pip.id
  }
}

resource "azurerm_network_interface" "windows_nic" {
  name                = "nic-windows"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.windows_pip.id
  }
}

# -------------------------
# Linux VM
# -------------------------
resource "azurerm_linux_virtual_machine" "linux_vm" {
  name                = "vm-linux"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = var.linux_vm_size
  admin_username      = var.linux_admin_username

  network_interface_ids = [
    azurerm_network_interface.linux_nic.id
  ]

  admin_ssh_key {
    username   = var.linux_admin_username
    public_key = file(var.ssh_public_key_path)
  }

  os_disk {
    name                 = "linux-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "24.04-LTS"
    version   = "latest"
  }

  tags = {
    environment = var.environment
  }
}

# -------------------------
# Windows VM
# -------------------------
resource "azurerm_windows_virtual_machine" "windows_vm" {
  name                = "vm-windows"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = var.windows_vm_size
  admin_username      = var.windows_admin_username
  admin_password      = var.windows_admin_password

  network_interface_ids = [
    azurerm_network_interface.windows_nic.id
  ]

  os_disk {
    name                 = "windows-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-g2"
    version   = "latest"
  }

  tags = {
    environment = var.environment
  }
}

# -------------------------
# Windows VM 2
# -------------------------
resource "azurerm_windows_virtual_machine" "windows_vm_2" {
  name                = "vm-windows-2"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = var.windows_vm_size
  admin_username      = var.windows_admin_username
  admin_password      = var.windows_admin_password

  network_interface_ids = [
    azurerm_network_interface.windows_nic.id
  ]

  os_disk {
    name                 = "windows-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-g2"
    version   = "latest"
  }

  tags = {
    environment = var.environment
  }
}

# -------------------------
# Outputs
# -------------------------
output "linux_public_ip" {
  value = azurerm_public_ip.linux_pip.ip_address
}

output "windows_public_ip" {
  value = azurerm_public_ip.windows_pip.ip_address
}