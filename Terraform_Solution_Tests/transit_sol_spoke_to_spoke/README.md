## Transit Solution Test (Spoke to Spoke)

### Description

This Terraform configuration creates 2 Spoke VPCs, 1 Transit VPC, 1 Aviatrix Transit GW, 2 Aviatrix Spoke GWs, and ubuntu instances in Spoke VPCs. And then, it  attaches Spoke VPCs to Transit VPC. After that, end-to-end traffic is tested between ubuntu instances. After test is done, copy the result output from the remote host to the local machine.

### Prerequisites

1) Create a public_key private_key pair. For example. "ssh-keygen -t rsa" and save the key pair such as ~/Downloads/sshkey and ~/Downloads/sshkey.pub

2) Provide the location of the public_key as variable in provider_cred.tfvars file.

3) Add the private_key on the local machine where terraform is going to run. For example, ssh-add ~/Downloads/sshkey

4) Provide other info such as controller_ip, aws_access_key, etc as necessary in provider_cred.tfvars file.
> aws_region     = "Enter_AWS_region"  
> aws_access_key = "Enter_AWS_access_key"  
> aws_secret_key = "Enter_AWS_secret_key"  
> aviatrix_controller_ip       = "Enter_your_controller_IP"  
> aviatrix_controller_username = "Enter_your_controller_username"  
> aviatrix_controller_password = "Enter_your_controller_password"  
> aviatrix_aws_access_account  = "Enter_your_AWS_access_account"  
> public_key = "~/Downloads/sshkey.pub"
 

### Usage
```
terraform init
terraform plan -var-file=provider_cred.tfvars -detailed-exitcode
terraform apply -var-file=provider_cred.tfvars -auto-approve
terraform show
terraform destroy -var-file=provider_cred.tfvars -auto-approve
```

### Test Duration

Total Test Time = \~18min (Create=\~13min Destroy=\~5min)

### Test Result

Check **result.txt** file in the same terraform script location. It should say **"PASS"** or **"FAIL"**.

### Troubleshoot

If test result is "FAIL" or user needs to check more info, check **log.txt** file in the same terraform script location after the run.
