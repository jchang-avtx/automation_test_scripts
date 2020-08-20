## Site2Cloud Connections Test to Multi-Regions

### Description

The purpose of this Terraform configuration is to test site2cloud connections to different regions. First, it creates Cloud VPC and a bunch of Site VPCs in different regions according to the defined list of test regions. And then, it deploys Aviatrix GWs and Ubuntu clients in Cloud VPC and each Site VPC. It also creates back-to-back site2cloud connections between CloudGW and SiteGW. After that, end-to-end site2cloud traffic is tested in order to verify each site2cloud connection.


### Prerequisites

1) Ensure Terraform v0.13 and above is installed.

2) Edit terraform.tfvars file and modify gcp_site_region by commenting/uncommenting lines in order to select the test regions. Testing more than 10 site regions is not recommended for each run because it takes quite some time especially if debugging is needed.

3) Create a public_key private_key pair. For example. "ssh-keygen -t rsa" and save the key pair such as ~/Downloads/sshkey and ~/Downloads/sshkey.pub

4) Provide the location of public_key and private_key as variables in provider_cred.tfvars file.

5) Open public_key file and note down the user name which is at the end of the file contents. Provide the user name string to ssh_user variable in provider_cred.tfvars file.

6) Provide other info such as controller_ip, gcp_credential_file_location, gcp_project_name, etc as necessary in provider_cred.tfvars file.
> gcp_credential_file_location = = "Enter_GCP_json_credential_file_location"  
> gcp_project_name = "Enter_GCP_project_name"  
> aviatrix_controller_ip       = "Enter_your_controller_IP"  
> aviatrix_controller_username = "Enter_your_controller_username"  
> aviatrix_controller_password = "Enter_your_controller_password"  
> aviatrix_gcp_access_account  = "Enter_your_GCP_access_account_string"  
> ssh_user = "Enter_ssh_user_account_name"  
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

###### Single Cloud Region (us-west1) to Single Site Region (us-east1)
Total Test Time = \~14min (Create=\~10min Destroy=\~4min)

###### Single Cloud Region (us-west1) to 10 GCP Site Regions
Total Test Time = \~75min (Create=\~50min Destroy=\~25min)


### Test Result

Check **result.txt** file in the same terraform script location. It should say **"PASS"** or **"FAIL"**.

### Troubleshoot

If test result is "FAIL" or user needs to check more info by checking **log.txt** file in the same terraform script location after the run.
