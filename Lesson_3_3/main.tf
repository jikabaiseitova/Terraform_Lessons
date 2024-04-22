terraform {
  required_providers {
    oregon = {
        source  = "hashicorp/aws"
        version = "5.40.0"
    }
  } 
}

provider "aws" {
  alias  = "oregon"
  region = "us-west-2"
}

# Define variables
variable "region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "us-west-2"
}

variable "vpc_cidr_block" {
  description = "The CIDR block for the custom VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet1_cidr_block" {
  description = "The CIDR block for subnet 1"
  type        = string
  default     = "10.0.1.0/24"
}

variable "subnet2_cidr_block" {
  description = "The CIDR block for subnet 2"
  type        = string
  default     = "10.0.2.0/24"
}

variable "instance_type" {
  description = "The EC2 instance type"
  type        = string
  default     = "t2.micro"
}

data "aws_ami" "ami" {
    most_recent     = true
    owners          = ["137112412989"]

    filter {
        name    = "name"
        values  = ["al2023-ami-2023.4.20240401.1-kernel-6.1-x86_64"]
    }
}

# Create custom VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = var.vpc_cidr_block
}

# Create subnets
resource "aws_subnet" "subnet1" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = var.subnet1_cidr_block
  availability_zone = "${var.region}a"
}

resource "aws_subnet" "subnet2" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = var.subnet2_cidr_block
  availability_zone = "${var.region}b"
  depends_on        = [aws_subnet.subnet1]
}

# Create Internet Gateway
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id
}

# Create NAT Gateway
resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.subnet1.id
  depends_on    = [aws_internet_gateway.my_igw]
}

# Create Elastic IP for NAT Gateway
resource "aws_eip" "nat" {
  domain = "vpc" # Use 'domain' attribute instead of 'vpc'
}

# Create Route Table for Public Subnet
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    gateway_id     = aws_internet_gateway.my_igw.id
  }
}

# Associate Route Table with Subnet 1
resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.public_route_table.id
}

# Create Route Table for Private Subnet
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }
}

# Associate Route Table with Subnet 2
resource "aws_route_table_association" "private_subnet_association" {
  subnet_id      = aws_subnet.subnet2.id
  route_table_id = aws_route_table.private_route_table.id
}

# Create EC2 instances
resource "aws_instance" "my_instance" {
  ami           = data.aws_ami.ami.id
  instance_type = var.instance_type
  subnet_id     = aws_subnet.subnet2.id
  depends_on    = [aws_subnet.subnet2]
}

resource "aws_instance" "second_instance" {
  ami           = data.aws_ami.ami.id
  instance_type = var.instance_type
  subnet_id     = aws_subnet.subnet1.id
  depends_on    = [aws_subnet.subnet1]
}

# Output values
output "instance_id" {
  description = "ID of the first EC2 instance"
  value       = aws_instance.my_instance.id
}

output "second_instance_id" {
  description = "ID of the second EC2 instance"
  value       = aws_instance.second_instance.id
}

output "subnet_ids" {
  description = "IDs of the created subnets"
  value       = [aws_subnet.subnet1.id, aws_subnet.subnet2.id]
}

output "vpc_id" {
  description = "ID of the created VPC"
  value       = aws_vpc.my_vpc.id
}

output "vpc_cidr_block" {
  description = "CIDR block of the created VPC"
  value       = aws_vpc.my_vpc.cidr_block
}