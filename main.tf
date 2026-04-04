# Specify the Terraform provider
provider "azurerm" {
  features {}
}

# Create a Resource Group
resource "azurerm_resource_group" "example" {
  name     = "terraform-rg"
  #location = "East US"
  location = "ukwest"
} 

# Create  a Storage Account
resource "azurerm_storage_account" "example" {
  name                     = "terraformstorage125yomi"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_virtual_network" "example" {
  name                = "example-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_subnet" "example" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "example" {
  name                = "example-nic"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.example.id
    private_ip_address_allocation = "Dynamic"
  }
}
variable "ssh_public_key_path" {
  type        = string
  description = "The local path to the SSH public key"
  default     = "~/.ssh/id_ed25519.pub"
}

resource "azurerm_linux_virtual_machine" "example" {
  name                = "example-machine"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  size                = "Standard_D2s_v3"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.example.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file(pathexpand(var.ssh_public_key_path))
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}



# Output the strorage account name after creation
output "storage_account_name" {
  value = azurerm_storage_account.example.name
}

# Output the resource group name after creation
output "resource_group_name" {
  value = azurerm_resource_group.example.name
}


output "virtual_network_name" {
  value = azurerm_virtual_network.example.name
  
}

output "subnet_name" {
  value = azurerm_subnet.example.name
  
}


output "network_interface_name" {
  value = azurerm_network_interface.example.name
  
}


output "linux_virtual_machine_name" {
  value = azurerm_linux_virtual_machine.example.name
  
}
