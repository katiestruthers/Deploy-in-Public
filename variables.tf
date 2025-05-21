variable "region" {
  type        = string
  description = "The region where we are creating the VPC"
  default     = "ca-central-1"
}

variable "cidr_block" {
  type        = string
  description = "Value of cidr block"
  default     = "10.0.0.0/24"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "Value of public subnet cidr blocks"
  default     = ["10.0.0.0/26", "10.0.0.64/26"]
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "Value of private subnet cidr blocks"
  default     = ["10.0.0.128/26", "10.0.0.192/26"]
}

variable "app_name" {
  type       = string
  description = "Value of app name"
  default = "dip"
}