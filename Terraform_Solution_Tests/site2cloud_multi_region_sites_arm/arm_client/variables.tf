# Variables for ARM Client module

variable "region" {
  type        = string
  description = "Name of region to launch Ubuntu client"
}
variable "vpc_id" {
  type        = string
  description = "VPC ID to deploy resources"
}
variable "public_key" {
  type        = string
  description = "Public key for creating Ubuntu client"
}
variable "subnet_id" {
  type        = string
  description = "Subnet ID to launch Ubuntu client"
}
