
variable "region" {
    description = "AWS region"
    default = "us-east-1"
}

variable "app" {
    description = "Application Name"
    default = "Brain-Scale"
}

#Network
variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "pub_sub_A_cidr_block" {
  description = "The CIDR block for Public Subnet A"
  default     = "10.0.11.0/24"
}

variable "pub_sub_B_cidr_block" {
  description = "The CIDR block for Public Subnet B"
  default     = "10.0.12.0/24"
}

variable "priv_sub_A_cidr_block" {
  description = "The CIDR block for Private Subnet A"
  default     = "10.0.13.0/24"
}

variable "priv_sub_B_cidr_block" {
  description = "The CIDR block for Private Subnet B"
  default     = "10.0.14.0/24"
}

#ECR
variable "ecr-repo-name" {
  description = "The name of ecr repository"
  default     = "brain-scale-simple-app"
}
