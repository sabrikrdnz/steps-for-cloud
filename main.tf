provider "azurerm" {
  # whilst the `version` attribute is optional, we recommend pinning to a given version of the Provider
  subscription_id = "${var.subs_id}"
  client_id = "${var.client_id}"
  client_secret = "${var.client_secret}"
  tenant_id = "${var.tenant_id}"
  version = "=2.40.0"
  features {}
}
#create resource group
resource "azurerm_resource_group" "ansible-docker-rg" {
    name     = "${var.resource_group_name}"
    location = "${var.resource_group_location}"
    tags      = {
      Environment = "Terraform-Ansible-Docker-Openshift Demo"
    }
}

#Create virtual network
resource "azurerm_virtual_network" "vnet" {
    name                = "ansible-vnet-westeurope-001"
    address_space       = ["172.23.138.0/24"]
    location            = "${azurerm_resource_group.ansible-docker-rg.location}"
    resource_group_name = "${azurerm_resource_group.ansible-docker-rg.name}"
}

# Create subnet
resource "azurerm_subnet" "ansible-vm-subnet" {
  name                 = "ansible-subnet-westeurope-001 "
  resource_group_name  = "${azurerm_resource_group.ansible-docker-rg.name}"
  virtual_network_name = "${azurerm_virtual_network.vnet.name}"
  address_prefix       = "172.23.138.0/24"
}

# Create public IP
resource "azurerm_public_ip" "publicip" {
  count               = var.instance_count
  name                = "${var.resource_prefix}-${format("%02d", count.index)}-PublicIP"
  location            = "${azurerm_resource_group.ansible-docker-rg.location}"
  resource_group_name = "${azurerm_resource_group.ansible-docker-rg.name}"
  allocation_method   = "Static"
}

# Create network security group and rule
resource "azurerm_network_security_group" "ansible-docker-nsg" {
  name                = "nsg-ansible-docker-001 "
  location            = "${azurerm_resource_group.ansible-docker-rg.location}"
  resource_group_name = "${azurerm_resource_group.ansible-docker-rg.name}"

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

# Create network interface
resource "azurerm_network_interface" "nic" {
  count               = var.instance_count
  name                = "${var.resource_prefix}-${format("%02d", count.index)}-NIC"
  location            = "${azurerm_resource_group.ansible-docker-rg.location}"
  resource_group_name = "${azurerm_resource_group.ansible-docker-rg.name}"

  ip_configuration {
    name                          = "niccfg-vmterraform"
    subnet_id                     = "${azurerm_subnet.ansible-vm-subnet.id}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = element(azurerm_public_ip.publicip.*.id, count.index)
  }
}

# Create virtual machine
resource "azurerm_virtual_machine" "example_linux_vm" {
    count                 = "${var.instance_count}"
    name                  = "${var.resource_prefix}-${format("%02d", count.index)}"
    location              = "${azurerm_resource_group.ansible-docker-rg.location}"
    resource_group_name   = "${azurerm_resource_group.ansible-docker-rg.name}"
    network_interface_ids = [element(azurerm_network_interface.nic.*.id, count.index)]
    vm_size               = "${var.ansible_node_vm_size}"

    storage_image_reference {
        publisher = "OpenLogic"
        offer = "CentOS"
        sku = "7.5"
        version = "latest"
    }

    storage_os_disk {
        name = "myosdisk-${count.index}"
        caching = "ReadWrite"
        create_option = "FromImage"
        managed_disk_type = "Standard_LRS"
    }

    os_profile {
        computer_name = "linuxhost"
        admin_username = "uygulama"
        admin_password = "Password1!"
    }

    os_profile_linux_config {
        disable_password_authentication = true
        ssh_keys {
            path     = "/home/uygulama/.ssh/authorized_keys"
            key_data = file("~/.ssh/id_rsa.pub")
        }
    }

    tags = {
    environment = "Test"
    }
}