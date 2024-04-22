terraform {
  backend "s3" {
    bucket  = "terraform.tfstate-jyldyz"
    key     = "ec2/terraform.tfstate"
  }
}

locals {
    name = "Jyldyz"
}

resource "aws_instance" "instance" {
  count           = 3
  ami             = data.aws_ami.ami.id
  instance_type   = "t3.micro"
  subnet_id       = data.terraform_remote_state.networking.outputs.public_subnets[count.index]
  security_groups = [data.terraform_remote_state.networking.outputs.security_groups[count.index]]
  associate_public_ip_address = count.index < 2 ? true : false
  
  tags = {
    "Name" = "${local.name}-instance-${count.index + 1}"
  }
}



