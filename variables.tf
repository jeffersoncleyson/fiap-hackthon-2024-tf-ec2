# Input variable definitions

variable "application_name" {
  description = "Application name"
  type        = string
}

variable "vpc_public_subnets" {
  description = "VPC Public Subnets"
  type        = list
}

variable "vpc_sg_id" {
  description = "VPC Security Group"
  type        = string
}