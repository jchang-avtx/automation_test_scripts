# Aviatrix Controller QuickStart
A Terraform example to launch a controller in desired region and complete  the following:

```sh
Create IAM role if needed
Create vpc for controller
assign EIP
configure SG
complete initial setup
setup account
setup customer-id if needed
```

Pre-Requisites 
--------------
```sh
create aws credential file at your directory ~/.aws

filename: ~/.aws/credentials
*****
[default]
aws_access_key_id=xxxxxxxxx
aws_secret_access_key=xxxxxxxxxxxxxxxxxxxxx
*****
AWS Region (example: us-west-2)
a pre-generated key in that region
```

User parameters
---------------

 Persistent variable values are assign within this file named "terraform.tfvars" and automatically loads them to populate variables. 
```sh

WS resource information
region = "us-east-1"
controller_vpc_cidr_prefix = "10.70"
controller_key = "your-keys"
controller_size = "t2.large"
controller_name_suffix = "terrafrom"
# please choose "metered" or "byol"
controller_ami_type = "metered"

# iam role creation
create_aviatrix_iam_roles = true

## Aviatrix controller information
controller_admin_password = "xxxxxxxxx"
controller_admin_email = "emailid@xyz.com"

# Aviatrix AWS Account information
account_name ="awsCtrlTestAccount"
account_email = ""emailid@xyz.com"
account_password = "abcdefg"
aws_account_number = "12345678910"

# aviatrix customized paramters. if choose metered ami, please set it to false
setup_customer_id = false
aviatrix_customer_id = "your_aviatrix_customer_id"

```

Initialize terraform
--------------------
 This is one time command to initialize working directory containing Terraform configuration files. It is safe to run this command multiple times. 
```sh
$ terraform init

3 modules should be loaded:
- module.launch_controller
- module.launch_controller.create_aviatrix_roles
- module.launch_controller.create_controller_vpc

```
How to check terraform configuration files
------------------------------------------
```sh
$ terraform plan -target module.launch_controller
```
if you just do "terraform plan", you will get error:
Error: Error running plan: 1 error(s) occurred:

* provider.aviatrix: Aviatrix: Client: Controller IP is not set

Ignore this error, this is due to our controller hasn't created yet.

How to run terraform scripts
----------------------------
It is two steps:

```sh
$ terraform apply -auto-approve -target module.launch_controller
$ terraform apply -auto-approve
```
The first one launch aviatrix controller and execute initial setup.
The second one finish setup account and customer-id.

How to cleanup all resources
----------------------------
```sh
$ terraform destroy -force
```
