# Resource to create VPCs
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_main_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = merge(
    local.default_tags, {
    Name = "${var.environment}-${var.region_to_name_map[var.region]}-${var.vpc_name}"
    }
  )
}

# Resource to create public subnets
# Uses locals "public_subnet_set" for input
resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.main.id
  for_each          = {for subnet_input in local.public_subnet_set : "${subnet_input.cidr_block}" => subnet_input}

  cidr_block        = each.value.cidr_block
  availability_zone = each.value.availability_zone

  tags = merge(
    local.default_tags, {
    Name = "${var.environment}-${var.region_to_name_map[var.region]}-${replace(var.vpc_name, "-", "")}-${each.value.subnet_number}"
    }
  )
}

# Resource to create private subnets
# Uses locals "private_subnet_set" for input
resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.main.id
  for_each          = {for subnet_input in local.private_subnet_set : "${subnet_input.cidr_block}" => subnet_input}

  cidr_block        = each.value.cidr_block
  availability_zone = each.value.availability_zone

  tags = merge(
    local.default_tags, {
    Name = "${var.environment}-${var.region_to_name_map[var.region]}-${replace(var.vpc_name, "-", "")}-${each.value.subnet_number}"
    }
  )
}


# Resource to create Internet Gateway
resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    local.default_tags, {
    Name = "${var.environment}-${var.region_to_name_map[var.region]}-${replace(var.vpc_name, "-", "")}-igw"
    }
  )
}

# Resource to create dedicated Route table for public subnets so that they can have route to internet
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    local.default_tags, {
    Name = "${var.environment}-${var.region_to_name_map[var.region]}-${replace(var.vpc_name, "-", "")}-pub-rt"
    }
  )
}

# Resource to create public Route table association to public subnets so that they can have route to internet
resource "aws_route_table_association" "public_rt_assoc" {
  for_each = local.public_subnet_name2id_map
  subnet_id      = each.value
  route_table_id = aws_route_table.public_rt.id
}

# Resource to add dfault route to public_rt Route table pointing to IGW
resource "aws_route" "public_rt_route" {
  route_table_id            = aws_route_table.public_rt.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id                = aws_internet_gateway.main_igw.id
  depends_on                = [aws_route_table.public_rt]
}


# Resource to create dedicated Route table for private subnets without internet access
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    local.default_tags, {
    Name = "${var.environment}-${var.region_to_name_map[var.region]}-${replace(var.vpc_name, "-", "")}-pvt-rt"
    }
  )
}

# Resource to create private Route table association to private subnets
resource "aws_route_table_association" "private_rt_assoc" {
  for_each = local.private_subnet_name2id_map
  subnet_id      = each.value
  route_table_id = aws_route_table.private_rt.id
}

# Resource to create an ACL for public subnets currently allowing traffic both ways
resource "aws_network_acl" "public_subnet_nacl" {
  vpc_id = aws_vpc.main.id
  subnet_ids =  local.public_subnet_id_list

  egress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
    icmp_code  = 0
    icmp_type  = 0
  }

  ingress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
    icmp_code  = 0
    icmp_type  = 0
  }

  tags = merge(
    local.default_tags, {
    Name = "${var.environment}-${var.region_to_name_map[var.region]}-${replace(var.vpc_name, "-", "")}-pub-nacl"
    }
  )
}

# Resource to create an ACL for private subnets currently allowing traffic both ways
resource "aws_network_acl" "private_subnet_nacl" {
  vpc_id = aws_vpc.main.id
  subnet_ids =  local.private_subnet_id_list

  egress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
    icmp_code  = 0
    icmp_type  = 0
  }

  ingress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
    icmp_code  = 0
    icmp_type  = 0
  }

  tags = merge(
    local.default_tags, {
    Name = "${var.environment}-${var.region_to_name_map[var.region]}-${replace(var.vpc_name, "-", "")}-pvt-nacl"
    }
  )
}