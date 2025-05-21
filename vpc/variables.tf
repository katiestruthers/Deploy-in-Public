variable "region" {
  type        = string
  description = "The region where we are creating the VPC"
}

variable "cidr_block" {
  type        = string
  description = "Value of cidr block"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "Value of public subnet cidr blocks"
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "Value of private subnet cidr blocks"
}

variable "app_name" {
  type       = string
  description = "Value of app name"
}