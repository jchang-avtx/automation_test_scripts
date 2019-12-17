# Variable declarations for TF Regression Testbed ARM VNET environment setup

variable "region" {
	type  			= string
	description = "Region for the resources."
}
variable "public_key" {
	type  			= string
	description	= "Public key used for creating key pair for all instances."
}
variable "pub_hostnum" {
	type				= number
	description = "Number to be used for public ubuntu instance private ip host part. Must be a whole number that can be represented as a binary integer."
}
variable "pri_hostnum" {
	type				= number
	description = "Number to be used for private ubuntu instance private ip host part. Must be a whole number that can be represented as a binary integer."
}
variable "resource_name_label" {
	type				= string
	description	= "Label name for all the resources."
}
variable "vnet_count" {
	type				= number
	description	= "Number of vnets to create."
}
variable "vnet_cidr" {
  type				= list(string)
	description	= "Cidr for vnets."
}
variable "pub_subnet1_cidr" {
	type				= list(string)
	description	= "Cidr for public subnet 1."
}
variable "pub_subnet2_cidr" {
	type				= list(string)
	description	= "Cidr for public subnet 2."
}
variable "pri_subnet1_cidr" {
	type				= list(string)
	description	= "Cidr for private subnet 1."
}
variable "pri_subnet2_cidr" {
	type				= list(string)
	description	= "Cidr for private subnet 2."
}
