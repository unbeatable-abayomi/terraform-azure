variable "resource_group_name" {
   description = "Name of Resource Group"
   type = string
   default = "terraform-rg"
}

variable "location" {
  description = "Location to deploy Resources"
  type = string
  default = "ukwest"
}


variable "vm_name" {
  description = "Name of VM"
  type = string
  default = "example-tf-machine"
}


variable "vm_size" {
  description = "Size of VM"
  type = string
  default = "Standard_D2s_v3"
}

variable "usernamessh" {
  description = "The username for SSH"
  type = string
  default = "adminuser"
}

variable "vm_count" {
  type    = number
  default = 3  # Set this to 3, 5, or 10 depending on your needs
}