
variable "region" {
  default = "us-east-1"
}

variable "vpc_main_cidr" {
  description = "The main IPv4 CIDR for VPC"
}

variable "vpc_name" {}

variable "public_subnet_cidr_map" {
  type        = map(any)
  description = "Map of list of CIDRs for public subnets corresponding to specific AZs"
  default     = {}
}

variable "private_subnet_cidr_map" {
  type        = map(any)
  description = "Map of list of CIDRs for public subnets corresponding to specific AZs"
  default     = {}
}

variable "environment" {}
variable "organization" {}

variable "region_to_name_map" {
  type = map(any)
  default = {
    us-east-1      = "usea1"
    us-east-2      = "usea2"
    us-west-2      = "uswe2"
    ap-south-1     = "apso1"
    ap-southeast-1 = "apse1"
  }

}