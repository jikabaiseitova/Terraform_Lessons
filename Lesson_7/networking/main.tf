locals {
    name = "Jyldyz"
}

resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    "Name" = "${local.name}-vpc"
  }
}

resource "aws_subnet" "public" {
  count             = 3
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = tolist(toset(["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]))[count.index]

    tags = {
    "Name" = "${local.name}-public-subnet-${count.index + 1}"
  }
}

resource "aws_subnet" "private" {
  count             = 3
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = tolist(toset(["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]))[count.index]

    tags = {
    "Name" = "${local.name}-private-subnet-${count.index + 1}"
  }
}

resource "aws_security_group" "sg" {
  count        = 3
  name         = "my-new-sg-${count.index + 1}"
  description  = "Security group for instance ${count.index + 1}"
  vpc_id = aws_vpc.vpc.id

  dynamic "ingress" {
    for_each = var.instance_ingress_rules[count.index]
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

variable "instance_ingress_rules" {
  type = list(list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  })))

  default = [
    # Ingress rules for the first instance
    [
      {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      },
      {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
      }
    ],
    # Ingress rules for the second instance
    [
      {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      },
      {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
      }
    ],
    # Ingress rules for the third instance
    [
      {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      },
      {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      },
      {
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      },
      {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
      }
    ]
  ]
  
}