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



resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    local.default_tags, {
    Name = "${var.environment}-${var.region_to_name_map[var.region]}-${replace(var.vpc_name, "-", "")}-igw"
    }
  )
}


resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    local.default_tags, {
    Name = "${var.environment}-${var.region_to_name_map[var.region]}-${replace(var.vpc_name, "-", "")}-pub-rt"
    }
  )
}

resource "aws_route_table_association" "public_rt_assoc" {
  for_each = local.public_subnet_name2id_map
  subnet_id      = each.value
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route" "public_rt_route" {
  route_table_id            = aws_route_table.public_rt.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id                = aws_internet_gateway.main_igw.id
  depends_on                = [aws_route_table.public_rt]
}



resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    local.default_tags, {
    Name = "${var.environment}-${var.region_to_name_map[var.region]}-${replace(var.vpc_name, "-", "")}-pvt-rt"
    }
  )
}

resource "aws_route_table_association" "private_rt_assoc" {
  for_each = local.private_subnet_name2id_map
  subnet_id      = each.value
  route_table_id = aws_route_table.private_rt.id
}


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