# Variables for GCP Client module

variable "region" {
  type        = string
  description = "Name of region to launch Ubuntu client"
}
variable "vpc_id" {
  type        = string
  description = "VPC ID to deploy resources"
}
variable "ssh_user" {
  type        = string
  description = "SSH User for ssh into Ubuntu client"
}
variable "public_key" {
  type        = string
  description = "Public key for creating Ubuntu client"
}
variable "subnet_name" {
  type        = string
  description = "Name of subnet to launch Ubuntu client"
}
