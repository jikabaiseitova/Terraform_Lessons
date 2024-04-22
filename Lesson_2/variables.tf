variable "instance_tip" {
    default     = "t3.micro"
}

variable "instance_name" {
    description = "Instance name"
    default     = "Dev"
}

variable "userdata" {

}

variable "vpc_cidr_block" {
    description = "VPC CIDR block"
    default     = "10.1.2.0/24"
}

variable "subnet_cidr_block" {
    description = "CIDR блок для Subnet"
    default     = "10.0.2.0/16"
}