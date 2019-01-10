variable "mod_ondemand_max_account" {}
variable "mod_cloud_type"           {}
variable "mod_ondemand_act_name"    {type="list"}
variable "mod_aws_account_number"   {}
variable "mod_spoke_cidr_prefix"    {}
variable "mod_name_suffix"          {}
variable "mod_transit_gateway"      {}
variable "mod_spoke_region"         {}
variable "mod_spoke_gw_size"        {}
variable "AMI" {
  type = "map"
  default = {
    ca-central-1 = "ami-018b3065"
    us-east-1    = "ami-aa2ea6d0"
    us-east-2    = "ami-82f4dae7"
    us-west-1    = "ami-45ead225"
    us-west-2    = "ami-0def3275"

  }
}
