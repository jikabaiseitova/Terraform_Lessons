output "subnet_ids" {
    value       = [aws_subnet.public_subnet.id, aws_subnet.private_subnet.id]
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