variable "vpc" {
  description = "Map for each VPC to create"
  default = {
    "us-east-1" = "84.19.0.0/16"
    "eu-west-1" = "85.20.0.0/16"
  }
}
