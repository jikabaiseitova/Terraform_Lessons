terraform {
  backend "s3" {
    bucket                = "terraform.tfstate-jyldyz"
    key                   = "terraform.tfstate"
    workspace_key_prefix  = "env"
  }
}

locals {
    env                 = "prod"
    name                = "prod-vpc"
    create_default_cidr = true
}

resource "aws_vpc" "vpc_prod" {
  count = terraform.workspace == "prod" ? 1 : 0

  cidr_block = local.create_default_cidr ? "10.0.0.0/16" : var.cidr_block

  tags =  {
    "Name" = "${terraform.workspace}-vpc"
  }
}

resource "aws_s3_bucket" "bucket" {
  count = terraform.workspace == "dev" || terraform.workspace == "stage" || terraform.workspace == "prod" ? 1 : 0

  tags = {
    "Name" = "${terraform.workspace}-bucket"
  }
}