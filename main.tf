# Specify the Terraform provider
provider "azurerm" {
  features {}
}

# Create a Resource Group
resource "azurerm_resource_group" "example" {
  name     = "terraform-rg"
  location = "East US"
} 

# Create  a Storage Account
resource "azurerm_storage_account" "example" {
  name                     = "terraformstorage125yomi"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Output the strorage account name after creation
output "storage_account_name" {
  value = azurerm_storage_account.example.name
}

# Output the resource group name after creation
output "resource_group_name" {
  value = azurerm_resource_group.example.name
}