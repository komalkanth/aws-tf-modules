/* output "region" {
  value = var.region
}

output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_ids" {
  value = aws_subnet.public_subnet[*].id
}

output "avail_zones" {
  value = data.aws_availability_zones.available.names
} */

output "public_subnet_locals" {
  value = local.public_subnet_map[*]
}