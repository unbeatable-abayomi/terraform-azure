variable "region_name" {
   description = "Name of Region"
   type = string
   default = "us-east-1"
}


variable "ami_id" {
   description = "AMI id"
   type = string
   default = "ami-0c7217cdde317cfec"
}

variable "instance_type_name" {
   description = "Instance Name"
   type = string
   default = "t2.micro"
}

variable "key_pair_name" {
    description = "Name of Key Pair"
   type = string
   default = "us-east-1-devops-user"
}



