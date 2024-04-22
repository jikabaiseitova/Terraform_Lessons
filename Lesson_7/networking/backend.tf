terraform {
  backend "s3" {
    bucket = "terraform.tfstate-jyldyz"
    key = "networking/terraform.tfstate"
  }
}