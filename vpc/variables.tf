variable "region" {
  default = "us-east-1"
}

variable "vpc_main_cidr" {
  description = "The main IPv4 CIDR for VPC"
}

variable "subnet_cidr" {
  type        = list(any)
  description = "The main IPv4 CIDR for subnet"
}
