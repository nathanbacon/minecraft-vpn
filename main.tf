# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.2"
    }
  }

  required_version = ">= 1.1.0"
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "vpnrg" {
  name     = "my_vpn_resource_group"
  location = "West US"
}

resource "azurerm_resource_group" "mc_rg" {
    name = "minecraft"
    location = "West US"
}

resource "azurerm_virtual_network" "my_vn" {
  name                = "my_virtual_network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.vpnrg.location
  resource_group_name = azurerm_resource_group.vpnrg.name
}

resource "azurerm_subnet" "mysubnet" {
  name                 = "internal"
  virtual_network_name = azurerm_virtual_network.my_vn.name
  address_prefixes     = ["10.0.2.0/24"]
  resource_group_name  = azurerm_resource_group.vpnrg.name
}

resource "azurerm_network_interface" "my_nic" {
  name                = "my-nic"
  location            = azurerm_resource_group.vpnrg.location
  resource_group_name = azurerm_resource_group.vpnrg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.mysubnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "openvpn" {
  name                = "palladium"
  resource_group_name = azurerm_resource_group.vpnrg.name
  location            = azurerm_resource_group.vpnrg.location
  size                = "Standard_B1s"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.my_nic.id
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }
}

resource "azurerm_private_dns_zone" "myprivatednszone" {
  name = "myprivatedomain.zone"
  resource_group_name = azurerm_resource_group.vpnrg.name
}

resource "azurerm_linux_virtual_machine" "openvpn" {
  name                = "cadmium"
  resource_group_name = azurerm_resource_group.vpnrg.name
  location            = azurerm_resource_group.vpnrg.location
  size                = "Standard_B2s"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.my_nic.id
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }
}