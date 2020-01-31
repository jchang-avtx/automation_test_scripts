## Transitive Peering Test

### Description

This Terraform configuration creates 3 AWS VPCs (Source, Transitive, Destination) testbed environment with ubuntu instances, sets up 3 Aviatrix gateways A, B and C in each VPC. And then, it configures Aviatrix encrypted tunnels A-B and B-C. After that, it configures Transitive Peering between A and C with next hop of B. Then, it tests end-to-end traffic between SrcVPC and DstVPC by passing through TransitiveVPC. After test is done, copy the result output from the remote host to the local machine.

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
terraform destroy -var-file=provider_cred.tfvars -auto-approve -parallelism=5
terraform show
```
> ***Note***: Terraform destroy might timeout in this case. Use parallelism option with 5 to reduce the number of concurrent operations. Default is 10.

### Test Duration

Total Test Time = \~17 min (Create=\~10min Destroy=\~7min)

### Test Result

Check **result.txt** file in the same terraform script location. It should say **"PASS"** or **"FAIL"**.

### Troubleshoot

If test result is "FAIL" or user needs to check more info, check **log.txt** file in the same terraform script location after the run.
