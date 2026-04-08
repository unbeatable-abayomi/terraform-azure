
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

output "public_ip_name_azure" {
  #value = azurerm_public_ip.example.ip_address
  value = azurerm_public_ip.example[*].ip_address
  
}
output "subnet_name" {
  value = azurerm_subnet.example.name
  
}


output "network_interface_names" {
  value = azurerm_network_interface.example[*].name
  
}


output "linux_virtual_machine_names" {
  value = azurerm_linux_virtual_machine.example[*].name
  
}

output "vm_ip_map" {
  value = {
    for ip in azurerm_public_ip.example :
    ip.name => ip.ip_address
  }
}