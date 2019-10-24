# Outputs for TF Regression Testbed AWS VPC environment setup

output "gov_west_vpc_info" {
	value = [
		module.aws-vpc-gov-west.vpc_name,
		module.aws-vpc-gov-west.vpc_id
	]
}
output "gov_west_subnet_info" {
	value = [
		module.aws-vpc-gov-west.subnet_name,
		module.aws-vpc-gov-west.subnet_cidr
	]
}
output "gov_west_ubuntu_info" {
	value = [
		module.aws-vpc-gov-west.ubuntu_name,
		module.aws-vpc-gov-west.ubuntu_id,
		module.aws-vpc-gov-west.ubuntu_public_ip,
		module.aws-vpc-gov-west.ubuntu_private_ip
	]
}

output "gov_east_vpc_info" {
	value = [
		module.aws-vpc-gov-east.vpc_name,
		module.aws-vpc-gov-east.vpc_id
	]
}
output "gov_east_subnet_info" {
	value = [
		module.aws-vpc-gov-east.subnet_name,
		module.aws-vpc-gov-east.subnet_cidr
	]
}
output "gov_east_ubuntu_info" {
	value = [
		module.aws-vpc-gov-east.ubuntu_name,
		module.aws-vpc-gov-east.ubuntu_id,
		module.aws-vpc-gov-east.ubuntu_public_ip,
		module.aws-vpc-gov-east.ubuntu_private_ip
	]
}
