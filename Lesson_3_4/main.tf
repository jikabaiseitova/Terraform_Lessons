terraform {
  backend "s3" {
    bucket                = "jyldyz"
    key                   = "Lesson_4/terraform.tfstate"
    dynamodb_endpoint     = "terraform-state-lock-dynamo"
    region                = "us-east-1"
    encrypt               = true
    kms_key_id            = "alias/kms"
  }
}

locals {
  vpc_id = aws_vpc.main.id
  name   = "jyldyz"
}

resource "aws_instance" "instance" {
  ami           = data.aws_ami.ami.id
  instance_type = var.instance_type
  subnet_id     = aws_subnet.public_subnet.id

  tags = {
    "Name" = "${local.name}-instance"
  }
}

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block

  tags = {
    "Name" = "${local.name}-vpc"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr_block
  map_public_ip_on_launch = true

  lifecycle {
    ignore_changes = [cidr_block]
  }

  tags = {
    "Name" = "${local.name}-public_subnet"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.private_subnet_cidr_block

  lifecycle {
    ignore_changes = [cidr_block]
  }

  tags = {
    "Name" = "${local.name}-private_subnet"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.main.id
}

# Create NAT Gateway
resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_subnet.id
  depends_on    = [aws_internet_gateway.my_igw]
}

# Create Elastic IP for NAT Gateway
resource "aws_eip" "nat" {
  domain = "vpc"
}

# Create Route Table for Public Subnet
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }
}

# Associate Route Table with Public Subnet 
resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

# Create Route Table for Private Subnet
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }
}

# Associate Route Table with Private Subnet 
resource "aws_route_table_association" "private_subnet_association" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_route_table.id
}

# Create EC2 second instances
resource "aws_instance" "second_instance" {
  ami           = data.aws_ami.ami.id
  instance_type = var.instance_type
  subnet_id     = aws_subnet.public_subnet.id
  depends_on    = [aws_subnet.public_subnet]

  tags = {
    "Name" = "${local.name}-second-instance"
  }
}

resource "aws_security_group" "public_sg" {
  name        = "public_sg"
  description = "Security group for public subnet"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = aws_vpc.main.id
}

resource "aws_security_group" "private_sg" {
  name        = "private_sg"
  description = "Security group for private subnet"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = aws_vpc.main.id
}

resource "aws_security_group_rule" "allow_internal_traffic" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.private_sg.id
  source_security_group_id = aws_security_group.private_sg.id
}