
variable "vpc_count" {
  type        = number
  description = "Number of VPCs to create."
}

variable "resource_name_label" {
  type        = string
  description = "Label name for all resources."
}

variable "pub_subnet" {
  type        = list(string)
  description = "Public subnet."
}

variable "pri_subnet" {
  type        = list(string)
  description = "Private subnet"
}

variable "pub_instance_zone" {
  type        = list(string)
  description = "GCP zone to launch public instance."
}

variable "pri_instance_zone" {
  type        = list(string)
  description = "GCP zone to launch private instance."
}

variable "pub_subnet_region" {
  type        = string
  description = "Region of public subnet. Optional"
  default     = null
}

variable "pri_subnet_region" {
  type        = string
  description = "Region of private subnet. Optional"
  default     = null
}

variable "pub_hostnum" {
  type        = number
  description = "Public hostpart of the public Ubuntu instance."
}

variable "pri_hostnum" {
  type        = number
  description = "Private hostnum of the private Ubuntu instance."
}

variable "ubuntu_image" {
  type        = string
  description = "Name of GCP Image to use for VMs. Default is 'ubuntu-1804-lts'."
  default     = "ubuntu-1804-lts"
}

variable "ssh_user" {
  type        = string
  description = "SSH User for ssh into ubuntu instances."
}

variable "public_key" {
  type        = string
  description = "Public key to ssh into Ubuntu instances."
}
