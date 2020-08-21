## Site2Cloud Connections Test to Multi-Regions

### Description

The purpose of this Terraform configuration is to test site2cloud connections to different regions. First, it creates Cloud VPC and a bunch of Site VPCs in different regions according to the defined list of test regions. And then, it deploys Aviatrix GWs and Ubuntu clients in Cloud VPC and each Site VPC. It also creates back-to-back site2cloud connections between CloudGW and SiteGW. After that, end-to-end site2cloud traffic is tested in order to verify each site2cloud connection.

> ***Note***: Some AWS regions such as me-south-1(Bahrain), af-south-1(CapeTown), ap-east-1(HongKong), and eu-south-1(Milan) are not enabled by default. If these regions are planning to be tested, please make sure these regions are enabled before running Terraform. If these regions need to be enabled, sign in to the AWS Console, choose "My Account", scroll down to "AWS Regions" section, take the action "Enable". Also, note that after enabling the region, it may take a few minutes to several hours for resources to be available.


### Prerequisites

1) Edit terraform.tfvars file and modify aws_cloud_region, aws_site_region, site2cloud related pre-shared-key and other algorithms as necessary. As noted above, particular AWS test region may need to be enabled beforehand.

2) Create a public_key private_key pair. For example. "ssh-keygen -t rsa" and save the key pair such as ~/Downloads/sshkey and ~/Downloads/sshkey.pub

3) Provide the location of public_key and private_key as variables in provider_cred.tfvars file.

4) Provide other info such as controller_ip, aws_access_key, etc as necessary in provider_cred.tfvars file.
> aws_access_key = "Enter_AWS_access_key"  
> aws_secret_key = "Enter_AWS_secret_key"  
> aviatrix_controller_ip       = "Enter_your_controller_IP"  
> aviatrix_controller_username = "Enter_your_controller_username"  
> aviatrix_controller_password = "Enter_your_controller_password"  
> aviatrix_aws_access_account  = "Enter_your_AWS_access_account"  
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

###### Single Cloud Region (us-west-2) to Single Site Region (us-east-1)
Total Test Time = \~10 min (Create=\~7min Destroy=\~3min)

###### Single Cloud Region (us-west-2) to all AWS Site Regions
Total Test Time = \~100 min (Create=\~70min Destroy=\~30min)


### Test Result

Check **result.txt** file in the same terraform script location. It should say **"PASS"** or **"FAIL"**.

### Troubleshoot

If test result is "FAIL" or user needs to check more info by checking **log.txt** file in the same terraform script location after the run.
