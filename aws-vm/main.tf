
# 1. Specify the Provider
provider "aws" {
  #region = "us-east-1" # North Virginia
  region = var.region_name
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
  #ami           = "ami-0c7217cdde317cfec" # Ubuntu 22.04 LTS in us-east-1
  ami           = var.ami_id

  #instance_type = "t2.micro"             # Free Tier eligible
  instance_type = var.instance_type_name
  #key_name      = "us-east-1-devops-user" # The exact name as it appears in AWS Console
  key_name      = var.key_pair_name
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]

  tags = { Name = "Terraform-Ubuntu-VM" }
}

