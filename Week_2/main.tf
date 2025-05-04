terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
    http = {
      source = "hashicorp/http"
      version = "~> 3.4"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = "ca-central-1"
}

provider "tls" {}

provider "local" {}

provider "http" {}

data "http" "my_ip" {
  url = "https://ipinfo.io/json"
}

resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/24"
  instance_tenancy = "default"

  tags = {
    Name = "dip-vpc"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.0.0/25"

  tags = {
    Name = "dip-public-subnet"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.0.128/25"

  tags = {
    Name = "dip-private-subnet"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "dip-igw"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "dip-public-route-table"
  }
}

resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_eip" "nat_eip" {
  depends_on = [aws_internet_gateway.igw]
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet.id

  tags = {
    Name = "dip-nat-gw"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.igw]
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gw.id
  }

  tags = {
    Name = "dip-private-route-table"
  }
}

resource "aws_route_table_association" "private_subnet_association" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "tls_private_key" "private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "key" {
  key_name   = "dip-key"
  public_key = tls_private_key.private_key.public_key_openssh
}

resource "local_file" "private_key" {
  content  = tls_private_key.private_key.private_key_pem
  filename = "dip-key.pem"
}

resource "aws_security_group" "public_sg" {
  name = "dip-public-sg"
  description = "Allow SSH inbound traffic from my IP address, all TCP inbound traffic, and all outbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port        = 22 # SSH port
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [format("%s/32", jsondecode(data.http.my_ip.response_body).ip)]
  }

  ingress {
    from_port   = 80 # NGINX port
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0 # All ports
    to_port          = 0
    protocol         = "-1" # All protocols
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "dip-public-sg"
  }
}

resource "aws_instance" "public_instance" {
  ami           = "ami-03afc49e3def9a472"  # Amazon Linux 2023 AMI for ca-central-1
  instance_type = "t3.micro"

  subnet_id = aws_subnet.public_subnet.id

  associate_public_ip_address = true

  key_name = aws_key_pair.key.key_name

  vpc_security_group_ids = [ aws_security_group.public_sg.id ]

  tags = {
    Name = "dip-public-ec2"
  }
}

resource "aws_security_group" "private_sg" {
  name = "dip-private-sg"
  description = "Allow SSH inbound traffic from bastion host, TCP inbound traffic from public subnet, and all outbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port        = 22 # SSH port
    to_port          = 22
    protocol         = "tcp"
    security_groups  = [aws_security_group.bastion_host_sg.id]
  }

  ingress {
    from_port   = 80 # NGINX port
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/25"] # Public subnet CIDR block
  }

  egress {
    from_port        = 0 # All ports
    to_port          = 0
    protocol         = "-1" # All protocols
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "dip-private-sg"
  }
}

resource "aws_instance" "private_instance" {
  ami           = "ami-03afc49e3def9a472"  # Amazon Linux 2023 AMI for ca-central-1
  instance_type = "t3.micro"

  subnet_id = aws_subnet.private_subnet.id

  associate_public_ip_address = false

  key_name = aws_key_pair.key.key_name

  vpc_security_group_ids = [ aws_security_group.private_sg.id ]

  tags = {
    Name = "dip-private-ec2"
  }
}

resource "aws_security_group" "bastion_host_sg" {
  name = "dip-bastion-host-sg"
  description = "Allow SSH inbound traffic from my IP address and all outbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port        = 22 # SSH port
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [format("%s/32", jsondecode(data.http.my_ip.response_body).ip)]
  }

  egress {
    from_port        = 0 # All ports
    to_port          = 0
    protocol         = "-1" # All protocols
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "dip-bastion-host-sg"
  }
}

resource "aws_instance" "bastion_host" {
  ami           = "ami-03afc49e3def9a472"  # Amazon Linux 2023 AMI for ca-central-1
  instance_type = "t3.micro"

  subnet_id = aws_subnet.public_subnet.id

  associate_public_ip_address = true

  key_name = aws_key_pair.key.key_name

  vpc_security_group_ids = [ aws_security_group.bastion_host_sg.id ]

  tags = {
    Name = "dip-bastion-host-ec2"
  }
}
