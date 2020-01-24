## TGW Orchestrator Test (Without On-Prem connection)

### Description

This Terraform configuration creates Spoke VPC1 and VPC2 in Dev Domain, Spoke VPC3 in Prod Domain, VPC4 in Shared Service Domain, and ubuntu instances in each VPC. And then, it creates AWS TGW and add/modify domain connection policies so that Dev domain and Prod domain are segregated, but both Dev and Prod can access Shared Service Domain. After that, end-to-end traffic is tested between ubuntu instances in order to verify traffic flows are in accordance with domain policies. After test is done, copy the result output from the remote host to the local machine.

> ***Note***: This test requires to assign 4 VPCs and 4 Elastic IP addresses. Before start testing, please make sure the target AWS region can accommodate enough resources. If there are not enough resources, you may also request a service limit increase by creating an AWS support case.

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

Total Test Time = \~20min (Create=\~13min Destroy=\~7min)

### Test Result

Check **result.txt** file in the same terraform script location. It should say **"PASS"** or **"FAIL"**.

### Troubleshoot

If test result is "FAIL" or user needs to check more info, check **log.txt** file in the same terraform script location after the run.
