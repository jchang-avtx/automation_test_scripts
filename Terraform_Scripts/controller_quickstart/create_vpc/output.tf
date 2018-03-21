# output of create_vpc module
output "vpc_id" {
  description = "The ID of the VPC"
  value       = "${aws_vpc.test-VPC.id}"
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = "${aws_vpc.test-VPC.cidr_block}"
}

output "subnet_id" {
  description = "The subnet_id of the primary public subnet of this VPC"
  value       = "${aws_subnet.test-VPC-public.id}"
}

output "subnet_cidr_block" {
  description = "The CIDR block of the primary public subnet"
  value       = "${aws_subnet.test-VPC-public.cidr_block}" 
}

output "vpc_ra_id" {
  description = "The VPC RouteTabe Association id for public subet"
  value       = "${aws_route_table_association.test-VPC-ra.id}"
}

output "ha_subnet_id" {
  description = "The subnet_id of the primary public subnet of this VPC"
  value       = "${aws_subnet.test-VPC-public-ha.id}"
}

output "ha_subnet_cidr_block" {
  description = "The CIDR block of the primary public subnet"
  value       = "${aws_subnet.test-VPC-public-ha.cidr_block}"
}

output "ha_vpc_ra_id" {
  description = "The VPC RouteTabe Association id for public subet"
  value       = "${aws_route_table_association.test-VPC-ra-ha.id}"
}

