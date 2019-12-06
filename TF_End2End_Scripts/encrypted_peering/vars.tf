variable "resource_name_label" {
  description = "Name of label for aws resources created. Default is 'encrypted-peering'"
  default     = "encrypted-peering"
}
variable "ssh_user" {
  description = "Name of user when ssh into aws instance. Default is 'ubuntu'"
  default     = "ubuntu"
}
variable "public_key" {
  description = "Public key to be used for creating key pairs for aws instances."
}
variable "private_key" {
  description = "Private key to be used for ssh into aws instances. Optional."
  default     = ""
}
variable "ssh_agent" {
  type        = bool
  description = "Whether or not to authenticate using ssh-agent. On Windows, only Pageant is supported. Default is true."
  default     = true
}
variable "aws_account_number" {
  description = "AWS account number for creating aviatrix account."
}
variable "aws_access_key" {
  description = "AWS access key for creating aviatrix account."
}
variable "aws_secret_key" {
  description = "AWS secret key for creating aviatrix account."
}
variable "access_account_name" {
  description = "Aviatrix access account name."
  default     = "test-aws-acc"
}
