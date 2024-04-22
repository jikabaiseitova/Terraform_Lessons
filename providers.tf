terraform {
  required_providers {
    aws = {
        source  = "hashicorp/aws"
        version = "5.40.0"
    }
  } 
}

# The default provider configuration; resources that begin with `aws_` will use
# it as the default, and it can be referenced as `aws`.
provider "aws" {
  region = "us-west-2"  # Oregon
}
