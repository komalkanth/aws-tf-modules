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
  public_subnet_set = flatten([
    for selected_az, public_subnet_map in var.public_subnet_cidr_map: [
      for subnetnumber, cidrblock in public_subnet_map : {
        availability_zone = selected_az
        cidr_block = cidrblock
        subnet_number = "pubsbnt${substr(selected_az, -2, -1)}-${substr(subnetnumber, -1, -1)}"
      }
    ]
  ])
}

resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.main.id
  for_each          = {for subnet_input in local.public_subnet_set : "${subnet_input.cidr_block}" => subnet_input}

  cidr_block        = each.value.cidr_block
  availability_zone = each.value.availability_zone

  tags = merge(local.default_tags, {
    Name = "${var.environment}-${var.region_to_name_map[var.region]}-${replace(var.vpc_name, "-", "")}-${each.value.subnet_number}"
    }
  )
}

locals {
  private_subnet_set = flatten([
    for selected_az, private_subnet_map in var.private_subnet_cidr_map: [
      for subnetnumber, cidrblock in private_subnet_map : {
        availability_zone = selected_az
        cidr_block = cidrblock
        subnet_number = "pvtsbnt${substr(selected_az, -2, -1)}-${substr(subnetnumber, -1, -1)}"
      }
    ]
  ])
}

resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.main.id
  for_each          = {for subnet_input in local.private_subnet_set : "${subnet_input.cidr_block}" => subnet_input}

  cidr_block        = each.value.cidr_block
  availability_zone = each.value.availability_zone

  tags = merge(local.default_tags, {
    Name = "${var.environment}-${var.region_to_name_map[var.region]}-${replace(var.vpc_name, "-", "")}-${each.value.subnet_number}"
    }
  )
}

/* resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.main.id
  count             = length(local.private_subnet_map)
  cidr_block        = local.private_subnet_map[count.index].cidr_block
  availability_zone = local.private_subnet_map[count.index].availability_zone

  tags = merge(local.default_tags, {
    Name = "${var.environment}-${var.region_to_name_map[var.region]}-${replace(var.vpc_name, "-", "")}-pvtsbnt${substr(local.private_subnet_map[count.index].availability_zone, -2, -1)}-${local.private_subnet_map[count.index].subnet_number}"
    }
  )
} */

resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.main.id

  tags = merge(local.default_tags, {
    Name = "${var.environment}-${var.region_to_name_map[var.region]}-${var.vpc_name}-igw"
    }
  )
}