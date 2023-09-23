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

locals {
  public_subnet_map = flatten([
    for select_az, public_subnet_cidr_list in var.public_subnet_cidr_map: [
      for each_subnet_cir in public_subnet_cidr_list : {
        availability_zone = select_az
        cidr_block = each_subnet_cir
        subnet_number = "${index(public_subnet_cidr_list, each_subnet_cir) + 1}"
      }
    ]
  ])
}

resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.main.id
  count             = length(local.public_subnet_map)
  cidr_block        = local.public_subnet_map[count.index].cidr_block
  availability_zone = local.public_subnet_map[count.index].availability_zone

  tags = merge(local.default_tags, {
    Name = "${var.environment}-${var.region_to_name_map[var.region]}-${replace(var.vpc_name, "-", "")}-pubsbnt${substr(local.public_subnet_map[count.index].availability_zone, -2, -1)}-${local.public_subnet_map[count.index].subnet_number}"
    }
  )
}

locals {
  private_subnet_map = flatten([
    for select_az, private_subnet_cidr_list in var.private_subnet_cidr_map: [
      for each_subnet_cir in private_subnet_cidr_list : {
        availability_zone = select_az
        cidr_block = each_subnet_cir
        subnet_number = "${index(private_subnet_cidr_list, each_subnet_cir) + 1}"
      }
    ]
  ])
}

resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.main.id
  count             = length(local.private_subnet_map)
  cidr_block        = local.private_subnet_map[count.index].cidr_block
  availability_zone = local.private_subnet_map[count.index].availability_zone

  tags = merge(local.default_tags, {
    Name = "${var.environment}-${var.region_to_name_map[var.region]}-${replace(var.vpc_name, "-", "")}-pvtsbnt${substr(local.private_subnet_map[count.index].availability_zone, -2, -1)}-${local.private_subnet_map[count.index].subnet_number}"
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