data "aws_ami" "ami" {
  most_recent = true
  owners      = ["137112412989"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.4.20240401.1-kernel-6.1-x86_64"]
  }
}

data "terraform_remote_state" "networking" {
    backend = "s3"
    config = {
        bucket  = "terraform.tfstate-jyldyz"
        key     = "networking/terraform.tfstate"
        region  = "us-east-1"
    }
}