# Test order 6: change name after removing user.

# BEFORE RUNNING THIS: Please note that after running this file, you cannot use Terraform to destroy your infrastructure
# This has been logged in Mantis. Please see Mantis: id=7967

## NOTE: CAN ONLY BE RUN AFTER removeuser.tfvars (OR current state must be equal to that of the parameters in removeuser.tfvars aside from name change)
## This is because it seems that Terraform will detect it as an attempt to create/ modify a
## profile called "profileName2" instead of changing modifying the name of existing profile that matches parameters listed

## What is interesting is after a successful 'terraform apply' of this change,
## the aviatrix_vpn_profile_name will be changed in 'terraform show' HOWEVER, the "id" remains the same
## this will somehow cause Terraform to dissociate this profile as one it is managing and will no longer be able to be destroyed
## The GUI will also still be unchanged, unlike every other change that can be made to other parameters

aviatrix_controller_ip          = "1.2.3.4"
aviatrix_controller_username    = "admin"
aviatrix_controller_password    = "password"

aviatrix_vpn_profile_name       = "profileName2"
aviatrix_vpn_profile_base_rule  = "allow_all"
aviatrix_vpn_profile_user_list  = []

aviatrix_vpn_profile_action     = ["allow", "deny"] # can be referred to with [0] for allow, [1] for deny in vpn_user_profile.tf
aviatrix_vpn_profile_protocol   = ["all", "tcp", "udp", "icmp", "sctp", "rdp", "dccp"]
aviatrix_vpn_profile_port       = ["5544", "5555", "5566", "5577", "5588", "5599", "5600"]
aviatrix_vpn_profile_target     = ["10.0.0.0/32", "11.0.0.0/32", "12.0.0.0/32", "13.0.0.0/32", "14.0.0.0/32", "15.0.0.0/32", "16.0.0.0/32"]
