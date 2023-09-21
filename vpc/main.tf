locals {
  default_tags = {
    Environment  = var.environment
    Organization = var.organization
  }
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_main_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = merge(local.default_tags, {
    Name = "${var.environment}-${var.region_to_name_map[var.region]}-${var.vpc_name}"
  }
  )
}

resource "aws_subnet" "public_subnet" {
  count      = length(var.public_subnet_cidr)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_subnet_cidr[count.index]

  tags = merge(local.default_tags, {
    Name = "${var.environment}-${var.region_to_name_map[var.region]}-${var.vpc_name}-pub-sbnt-${count.index + 1}"
  }
  )
}

resource "aws_subnet" "private_subnet" {
  count      = length(var.private_subnet_cidr)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.private_subnet_cidr[count.index]

  tags = merge(local.default_tags, {
    Name = "${var.environment}-${var.region_to_name_map[var.region]}-${var.vpc_name}-pvt-sbnt-${count.index + 1}"
  }
  )
}

resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.main.id

  tags = merge(local.default_tags, {
    Name = "${var.environment}-${var.region_to_name_map[var.region]}-${var.vpc_name}-igw"
  }
  )
}