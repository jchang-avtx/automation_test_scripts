## Site2Cloud Connections Test to Multi-Regions

### Description

The purpose of this Terraform configuration is to test site2cloud connections to different regions. First, it creates Cloud VNet and a bunch of Site VNets in different regions according to the defined list of test regions. And then, it deploys Aviatrix GWs and Ubuntu clients in Cloud Net and each Site VNet. It also creates back-to-back site2cloud connections between CloudGW and SiteGW. After that, end-to-end site2cloud traffic is tested in order to verify each site2cloud connection.


### Prerequisites

1) Ensure Terraform v0.13 and above is installed.

2) Edit terraform.tfvars file and modify arm_site_region by commenting/uncommenting lines in order to select the test regions. Testing more than 10 site regions is not recommended for each run because it takes quite some time especially if debugging is needed.

3) Create a public_key private_key pair. For example. "ssh-keygen -t rsa" and save the key pair such as ~/Downloads/sshkey and ~/Downloads/sshkey.pub

4) Provide the location of public_key and private_key as variables in provider_cred.tfvars file.

5) Provide other info such as controller_ip, arm_subscription_id, etc as necessary in provider_cred.tfvars file.
> arm_subscription_id = "Enter_Azure_subscription_ID"  
> arm_tenant_id = "Enter_Azure_directory_or_tenant_ID"  
> arm_client_id = "Enter_Azure_application_or_client_ID"  
> arm_client_secret = "Enter_Azure_client_secret_or_application_key"  
> aviatrix_controller_ip       = "Enter_your_controller_IP"  
> aviatrix_controller_username = "Enter_your_controller_username"  
> aviatrix_controller_password = "Enter_your_controller_password"  
> aviatrix_arm_access_account  = "Enter_your_ARM_access_account_string"  
> public_key = "\~/Downloads/sshkey.pub"  
> private_key = "\~/Downloads/sshkey"

### Usage
```
terraform init
terraform plan -var-file=provider_cred.tfvars
terraform apply -var-file=provider_cred.tfvars -auto-approve
terraform show
terraform destroy -var-file=provider_cred.tfvars -auto-approve
terraform show
```

### Test Duration

###### Single Cloud Region (West US) to Single Site Region (East US)
Total Test Time = \~30 min (Create=\~15min Destroy=\~15min)

###### Single Cloud Region (West US) to 10 ARM Site Regions
Total Test Time = \~120 min (Create=\~70min Destroy=\~50min)


### Test Result

Check **result.txt** file in the same terraform script location. It should say **"PASS"** or **"FAIL"**.

### Troubleshoot

If test result is "FAIL" or user needs to check more info by checking **log.txt** file in the same terraform script location after the run.
