terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.40.0"
    }
  }
}

provider "aws" {
  region = terraform.workspace == "dev" ? "us-east-1" : terraform.workspace == "stage" ? "us-east-2" : terraform.workspace == "prod" ? "us-west-2" : null 
}