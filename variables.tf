variable "instance_type" {
    description = "Instance type"
    default     = "t3.micro"
}

variable "instance_name" {
    description = "Instance name"
    default     = "Dev"
}

variable "vpc_cidr_block" { 
    description = "VPC CIDR block"
    default     = "10.0.0.0/16"
}

variable "public_subnet_cidr_block" {
    description = "CIDR блок для public Subnet"
    default     = "10.0.1.0/24"
}

variable "private_subnet_cidr_block" {
    description = "CIDR блок для private Subnet"
    default     = "10.0.2.0/24"
}