provider "aws" {
  region = "ap-south-2"
}

variable "ami" {
  description = "this is the AMI value for the instance"
}

variable "instance_type" {
  description = "this is the instance type for the EC2 instance"
}

resource "aws_instance" "example" {
  ami = var.ami
  instance_type = var.instance_type
}
