# output of create_vpc module
output "vpc_id" {
  description = "The ID of the VPC"
  value       = "${concat(aws_vpc.test-VPC.*.id, list(""))}"
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = "${concat(aws_vpc.test-VPC.*.cidr_block, list(""))}"
}

output "subnet_id" {
  description = "The subnet_id of the primary public subnet of this VPC"
  value       = "${concat(aws_subnet.test-VPC-public.*.id, list(""))}"
}

output "subnet_cidr_block" {
  description = "The CIDR block of the primary public subnet"
  value       = "${concat(aws_subnet.test-VPC-public.*.cidr_block, list(""))}"
}

output "vpc_ra_id" {
  description = "The VPC RouteTabe Association id for public subet"
  value       = "${concat(aws_route_table_association.test-VPC-ra.*.id, list(""))}"
}

output "ha_subnet_id" {
  description = "The subnet_id of the primary public subnet of this VPC"
  value       = "${concat(aws_subnet.test-VPC-public-ha.*.id, list(""))}"
}

output "ha_subnet_cidr_block" {
  description = "The CIDR block of the primary public subnet"
  value       = "${concat(aws_subnet.test-VPC-public-ha.*.cidr_block, list(""))}"
}

output "ha_vpc_ra_id" {
  description = "The VPC RouteTabe Association id for public subet"
  value       = "${concat(aws_route_table_association.test-VPC-ra-ha.*.id, list(""))}"
}

