## FQDN Test

### Description

This Terraform configuration creates AWS VPC testbed environment with ubuntu instances, sets up Aviatrix gateway, configures FQDN filters, and then tests end-to-end traffic to make sure FQDN filters are working. After test is done, copy the result output from the remote host to the local machine.

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

4) (Optional) Different type of FQDN feature test can be done by modifying terraform.tfvars file. In the example below, FQDN mode is "white" list and it can be changed to "black" for testing black-list. Also, FQDN domain, protocol and port info are passed as lists and it can be modified for customized testing. In the example below, "*.facebook.com" FQDN filter entry is tested along with TCP port 443. 

> aviatrix_fqdn_mode   = "white"  
> aviatrix_fqdn_domain = ["*.facebook.com", "*.google.com", "twitter.com", "www.apple.com"]  
> aviatrix_fqdn_protocol = ["tcp", "tcp", "udp", "icmp"]  
> aviatrix_fqdn_port     = ["443", "80", "480", "ping"]

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

Total Test Time = \~16 min (Create=\~4min Destroy=\~12min)

### Test Result

Check **result.txt** file in the same terraform script location. It should say **"PASS"** or **"FAIL"**.

### Troubleshoot

If test result is "FAIL" or user needs to check more info, check **log.txt** file in the same terraform script location after the run.
