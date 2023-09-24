output "region" {
  value = var.region
}

output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_name2id_map" {
  value = local.public_subnet_name2id_map
}

output "public_subnet_id_list" {
  value = local.public_subnet_id_list
}

output "public_subnet_cidr_list" {
  value = local.public_subnet_cidr_list
}

output "private_subnet_name2id_map" {
  value = local.private_subnet_name2id_map
}

output "private_subnet_id_list" {
  value = local.private_subnet_id_list
}

output "private_subnet_cidr_list" {
  value = local.private_subnet_cidr_list
}
