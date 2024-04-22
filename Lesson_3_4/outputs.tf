output "subnet_ids" {
  value       = data.aws_subnets.default_subnet.ids
  description = "Subnet ids"
}

output "vpc_id" {
  value       = aws_vpc.main.id
  description = "VPS id"
}

output "vpc_cidr_block" {
  value       = aws_vpc.main.cidr_block
  description = "VPC CIDR block"
}

output "instance_id" {
  value       = aws_instance.instance.id
  description = "Instance id"
}