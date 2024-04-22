output "vpc" {
  value = aws_vpc.vpc.id
}

output "private_subnets" {
  value = {for i, v in aws_subnet.private : i => v.id}
}

output "public_subnets" {
  value = {for i, v in aws_subnet.public : i => v.id}
}

output "security_groups" {
  value = {for i, v in aws_security_group.sg : i => v.id}
}

