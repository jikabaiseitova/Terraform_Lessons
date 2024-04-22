resource "aws_instance" "instance" {
    ami             = data.aws_ami.ami.id
    instance_type   = var.instance_tip
    subnet_id       = data.aws_subnets.default_subnet.ids[1]
    user_data       = var.userdata


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

resource "aws_subnet" "subnet" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.subnet_cidr_block

    tags = {
        "Name" = var.instance_name
    }
}