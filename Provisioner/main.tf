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
  public_key = file("~/.ssh/id_rsa.pub")
}


