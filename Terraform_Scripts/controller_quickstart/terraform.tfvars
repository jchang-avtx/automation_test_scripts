# AWS resource information
region = "us-east-1"
controller_vpc_cidr_prefix = "10.70"
controller_key = "your-keypair-name"
controller_size = "t2.large"
controller_name_suffix = "Terraform"
# please choose "metered" or "byol"
controller_ami_type = "metered"

# iam role creation, please choose true or false
create_aviatrix_iam_roles = true

## Aviatrix controller information
controller_admin_password = "xxxxxxx"
controller_admin_email = "xyz@abc.com"

# Aviatrix AWS Account information
account_name ="awsCtrlTestAccount"
account_email = "xyz@abc.com"
account_password = "xxxxxxxx"
aws_account_number = "12345678910"

# aviatrix customized paramters. if choose metered ami, please set it to false
setup_customer_id = false
aviatrix_customer_id = "your-aviatrix-customer-id"
