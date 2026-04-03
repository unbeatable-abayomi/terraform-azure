# Specify the Terraform provider
provider "azurerm" {
  features {}
}

# Create a Resource Group
resource "azurerm_resource_group" "example" {
  name     = "terraform-rg"
  location = "East US"
} 

# Output the resource group name after creation
output "resource_group_name" {
  value = azurerm_resource_group.example.name
}