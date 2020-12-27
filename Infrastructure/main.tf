provider "azurerm" {
  # whilst the `version` attribute is optional, we recommend pinning to a given version of the Provider
  subscription_id = var.subs_id
  client_id = var.client_id
  client_secret = var.client_secret
  tenant_id = var.tenant_id
  version = "=2.40.0"
  features {}
}
#create resource group
resource "azurerm_resource_group" "ansible-rg" {
    name     = var.resource_group_name
    location = var.resource_group_location
    tags      = {
      Environment = "Terraform-Ansible Demo"
    }
}

#Create virtual network
resource "azurerm_virtual_network" "vnet" {
    name                = "ansible-vnet-westeurope-001"
    address_space       = ["172.23.138.0/24"]
    location            = azurerm_resource_group.ansible-rg.location
    resource_group_name = azurerm_resource_group.ansible-rg.name
}

# Create subnet
resource "azurerm_subnet" "ansible-vm-subnet" {
  name                 = "ansible-subnet-westeurope-001"
  resource_group_name  = azurerm_resource_group.ansible-rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefix       = "172.23.138.0/24"
}

# Create public IP
resource "azurerm_public_ip" "publicip" {
  count               = var.instance_count
  name                = "${var.resource_prefix}-${format("%02d", count.index)}-PublicIP"
  location            = azurerm_resource_group.ansible-rg.location
  resource_group_name = azurerm_resource_group.ansible-rg.name
  allocation_method   = "Static"
}

# Create network security group and rule
resource "azurerm_network_security_group" "ansible-nsg" {
  name                = "nsg-ansible-001 "
  location            = "${azurerm_resource_group.ansible-rg.location}"
  resource_group_name = "${azurerm_resource_group.ansible-rg.name}"

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}