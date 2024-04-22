resource "aws_instance" "instance" {
    ami                 = "ami-0395649fbe870727e"  # Oregon
    instance_type       = var.instance_type
    subnet_id           = aws_subnet.public_subnet.id

    tags = {
        "Name" = var.instance_name
    }
}

resource "aws_vpc" "main" {
    cidr_block = var.vpc_cidr_block

    tags = {
        "Name" = var.instance_name
    }
}

resource "aws_subnet" "public_subnet" {
    vpc_id     = aws_vpc.main.id
    cidr_block = var.public_subnet_cidr_block

    tags = {
        "Name" = var.instance_name
    }
}

resource "aws_subnet" "private_subnet" {
    vpc_id     = aws_vpc.main.id
    cidr_block = var.private_subnet_cidr_block

    tags = {
        "Name" = var.instance_name
    }
}