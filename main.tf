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



# 1. Specify the Provider
provider "aws" {
  region = "us-east-1" # North Virginia
}

# 2. Create the VPC (The "House")
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = { Name = "terraform-vpc" }
}

# 3. Create an Internet Gateway (The "Front Door")
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
}

# 4. Create a Public Subnet
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true # This gives the VM a Public IP automatically
}

# 5. Route Table (The "Directions" to the Internet)
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public_rt.id
}

# 6. Security Group (The "Firewall")
resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # In a real NOC, you'd put your IP here
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 7. The Virtual Machine (EC2 Instance)
resource "aws_instance" "web" {
  ami           = "ami-0c7217cdde317cfec" # Ubuntu 22.04 LTS in us-east-1
  instance_type = "t2.micro"             # Free Tier eligible

  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]

  tags = { Name = "Terraform-Ubuntu-VM" }
}

# 8. Output the Public IP
output "instance_public_ip" {
  value = aws_instance.web.public_ip
}