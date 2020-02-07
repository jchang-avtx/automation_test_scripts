## FireNet Test with Aviatrix FQDN Firewall instance

### Description

This Terraform configuration creates Spoke VPC in Dev Domain, and both public and private ubuntu instances are created as well. And then, it creates Security VPC in FireNet Domain and deploys Aviatrix FireNet Gateway and FQDN Gateway. Then, it creates AWS TGW and attaches all VPCs and domains so that Dev domain is connected to FireNet domain for traffic inspection. After that, Egress (Internet-bound) traffic flows are initiated from ubuntu private instance and verify traffic flows are allowed or denied based on FQDN filter tag. After test is done, copy the result output from the remote host to the local machine.

### Prerequisites

1) Create a public_key private_key pair. For example. "ssh-keygen -t rsa" and save the key pair such as ~/Downloads/sshkey and ~/Downloads/sshkey.pub

2) Provide the location of public_key and private_key as variables in provider_cred.tfvars file.

3) Provide other info such as controller_ip, aws_access_key, etc as necessary in provider_cred.tfvars file as well.
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

Total Test Time = \~25min (Create=\~18min Destroy=\~7min)

### Test Result

Check **result.txt** file in the same terraform script location. It should say **"PASS"** or **"FAIL"**.

### Troubleshoot

If test result is "FAIL" or user needs to check more info, check **log.txt** file in the same terraform script location after the run.
