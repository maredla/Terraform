variable "cidr" {
  default = "10.0.0.0/16" 
}

resource "aws_vpc" "terraform_vpc" {
  cidr_block = var.cidr
}

resource "aws_subnet" "sub1" {
  vpc_id = aws_vpc.terraform_vpc.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "ap-south-2a"
}

resource "aws_internet_gateway" "My_Ig" {
  vpc_id = aws_vpc.terraform_vpc.id
}

resource "aws_route_table" "RT" {
    vpc_id = aws_vpc.terraform_vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.My_Ig.id
    }

}

resource "aws_route_table_association" "rta1" {
    subnet_id = aws_subnet.sub1.id
    route_table_id = aws_route_table.RT.id
}



resource "aws_security_group" "webSG"  {
    name = "web"
    vpc_id = aws_vpc.terraform_vpc.id

    ingress {
        description = "HTTP from VPC"
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["10.0.0.0/0"]
    }

    ingress {
        description = "SSH"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["10.0.0.0/0"]
    }


    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["10.0.0.0/0"]
    }

    tags = {
        Name = "web-sg"
    }
  
}

resource "aws_key_pair" "demo_key_pair" {
  key_name = "demo_key_pair"
  public_key = file("~/.ssh/public_key.pub")
}

resource "aws_instance" "server" {
  ami = "ami-05b5693ff73bc6f84"
  instance_type = "t3.micro"
  key_name = aws_key_pair.demo_key_pair
  vpc_security_group_ids = [aws_security_group.webSG.id]
  subnet_id = aws_subnet.sub1.id

    connection {
      type = "ssh"
      user = "ubuntu"
      private_key = file("~/.ssh/public_key")
      host = self.public_ip
    }

#File provision to copy a file from Local to Remote
provisioner "file" {
  source = "app.py"
  destination = "/home/ubuntu/app.py" 
}

provisioner "remote-exec" {
  inline = [ 
    "echo 'Hello from the remote instance",
    "sudo apt update -y",  #update packages of Ubuntu
    "sudo apt-get install -y python3-pip", #Phython package installation
    "cd /home/ubuntu/",
    "sudo pip3 install flask",
    "sudo python3 app.py &"
   ]
}

}


