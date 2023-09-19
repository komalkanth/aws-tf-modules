resource "aws_vpc" "main" {
  cidr_block           = var.vpc_main_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "main"
  }
}


resource "aws_subnet" "main" {
  count      = length(var.subnet_cidr)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.subnet_cidr[count.index]

  tags = {
    Name = "main"
  }
}
