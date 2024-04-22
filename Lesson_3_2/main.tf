terraform {
  required_providers {
    aws = {
        source  = "hashicorp/aws"
        version = "5.40.0"
    }
    oregon = {
        source  = "hashicorp/aws"
        version = "5.40.0"
    }
  } 
}

provider "aws" {
  region = "us-east-1"
}

provider "aws" {
  alias  = "oregon"
  region = "us-west-2"
}

# Step 1: Create Network infrastructure
resource "aws_vpc" "main_vpc" {
  cidr_block = var.vpc_cidr_block

  tags = {
    "Name" = var.vpc_name
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = var.public_subnet_cidr_block
  availability_zone = "us-east-1a"

  tags = {
    "Name" = "${var.vpc_name}-public-subnet"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = var.private_subnet_cidr_block
  availability_zone = "us-east-1b"

  tags = {
    "Name" = "${var.vpc_name}-private-subnet"
  }
}

resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    "Name" = "${var.vpc_name}-igw"
  }
}

resource "aws_route_table" "public_subnet_rt" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_igw.id
  }

  tags = {
    "Name" = "${var.vpc_name}-public-subnet-rt"
  }
}

resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_subnet_rt.id
}

# Step 2: Create EC2 Instances
data "aws_ami" "amazon_linux" {
    most_recent     = true
    owners          = ["137112412989"]

    filter {
        name    = "name"
        values  = ["al2023-ami-2023.4.20240401.1-kernel-6.1-x86_64"]
    }
}

resource "aws_instance" "private_instance" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
  subnet_id     = aws_subnet.private_subnet.id
  depends_on    = [aws_subnet.private_subnet]

  tags = {
    "Name" = "${var.vpc_name}-private-instance"
  }
}

resource "aws_instance" "public_instance" {
  provider      = aws.oregon
  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
  subnet_id     = aws_subnet.public_subnet.id
  depends_on    = [aws_subnet.public_subnet]

  tags = {
    "Name" = "${var.vpc_name}-public-instance"
  }
}

# Step 3: Output Values
output "vpc_id" {
  value       = aws_vpc.main_vpc.id
  description = "VPC ID"
}

output "vpc_cidr_block" {
  value       = aws_vpc.main_vpc.cidr_block
  description = "VPC CIDR Block"
}

output "public_subnet_id" {
  value       = aws_subnet.public_subnet.id
  description = "Public Subnet ID"
}

output "private_subnet_id" {
  value       = aws_subnet.private_subnet.id
  description = "Private Subnet ID"
}

output "private_instance_id" {
  value       = aws_instance.private_instance.id
  description = "Private EC2 Instance ID"
}

output "public_instance_id" {
  value       = aws_instance.public_instance.id
  description = "Public EC2 Instance ID"
}

variable "vpc_name" {
  description = "Name for the VPC"
  type        = string
  default     = "MainVPC"
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr_block" {
  description = "CIDR block for public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr_block" {
  description = "CIDR block for private subnet"
  type        = string
  default     = "10.0.2.0/24"
}

variable "instance_type" {
  description = "Type of EC2 instance"
  type        = string
  default     = "t2.micro"
}