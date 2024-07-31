provider "aws" {
  region = "ap-south-2"
}

variable "ami" {
  description = "Instance AMI value"
}

variable "instance_type" {
  description = "Instance type of EC2"
}

resource "aws_instance" "example" {
  ami = var.ami
  instance_type = var.instance_type
}
