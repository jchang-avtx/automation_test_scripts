## Spoke SNAT/DNAT Test

### Description

The purpose of this Terraform configuration is to test Spoke SNAT/DNAT solution for customer use cases such as customer cannot accept Spoke routes at on-prem due to network routing reason, or customer cannot accept Spoke routes at on-prem due to network overlapping/identical reason. This Terraform configuration creates 3 Aviatrix Spoke GWs which are attached to Aviatrix Cloud Transit GW. Spoke1 will simulate network routing reason use case and Spoke3 will simulate network overlap/identical use case. Spoke2 will be used to test normal Spoke-to-Spoke communication. It also setups another Aviatrix Transit GW in order to simulate OnPrem GW which is having back-to-back connection with Cloud Transit GW. Then, end-to-end traffic is tested between Spoke-Spoke and Spoke-OnPrem.

### Prerequisites

1) Create a public_key private_key pair. For example. "ssh-keygen -t rsa" and save the key pair such as ~/Downloads/sshkey and ~/Downloads/sshkey.pub

2) Provide the location of public_key and private_key as variables in provider_cred.tfvars file.

3) Provide other info such as controller_ip, aws_access_key, etc as necessary in provider_cred.tfvars file.
> aws_region     = "Enter_AWS_region"  
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
terraform plan -var-file=provider_cred.tfvars -detailed-exitcode
terraform apply -var-file=provider_cred.tfvars -auto-approve
terraform show
terraform destroy -var-file=provider_cred.tfvars -auto-approve
terraform show
```

### Test Duration

Total Test Time = \~33 min (Create=\~21min Destroy=\~12min)

### Test Result

Check **result.txt** file in the same terraform script location. It should say **"PASS"** or **"FAIL"**.

### Troubleshoot

If test result is "FAIL" or user needs to check more info, check **log.txt** file in the same terraform script location after the run.
