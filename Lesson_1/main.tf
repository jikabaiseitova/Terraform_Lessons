resource "aws_instance" "instance_1" {
  ami                           = "ami-080e1f13689e07408"
  instance_type                 = "t2.micro"
  associate_public_ip_address   = true

    tags = {
    Name = "Jyldyz"
  }
}

resource "aws_instance" "instance_2" {
  ami                           = "ami-051f8a213df8bc089"
  instance_type                 = "t3.micro"
  availability_zone             = "us-east-1a"

    tags = {
    Name = "Jyldyz"
  }
}

resource "aws_instance" "instance_3" {
  ami                           = "ami-080e1f13689e07408"
  instance_type                 = "t2.micro"
  availability_zone             = "us-east-1a"
  monitoring                    = true

    tags = {
    Name = "Jyldyz"
  }
}