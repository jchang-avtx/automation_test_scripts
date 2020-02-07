## FireNet Test with Palo Alto Networks VM-Series Firewall instance

### Description

This Terraform configuration creates Spoke VPC1 in Dev Domain, VPC2 in Shared Service Domain, TransitVPC in Aviatrix Edge Domain, Security VPC in Security Domain. And then, it creates Aviatrix Transit GW in TransitVPC and makes connection to On-Prem via VGW. Then, it also creates Aviatrix FireNet GW in Security VPC. After that, it creates AWS TGW and attaches all VPCs. Also, it launches and associates Palo Alto VM-Series Firewall instance to Aviatrix FireNet GW. It also makes sure Dev domain is connected to Shared Service and Security Domains by adding/modifying domain connection policy of TGW. After that, end-to-end traffic is tested between ubuntu instances in order to create East-West (Dev-SharedService) flows, North-South (Dev-OnPrem) flows, Egress (Internet-bound) flows. Each traffic flow is verified in VM-Series Firewall instance by making sure that traffic is appropriately routed to Firewall instance. After test is done, copy the result output from the remote host to the local machine.

> ***Note***: This test requires to assign 5 VPCs and 7 Elastic IP addresses. Before start testing, please make sure the target AWS region can accommodate enough resources. If there are not enough resources, you may also request a service limit increase by creating an AWS support case.

### Prerequisites

1) Create a public_key private_key pair. For example. "ssh-keygen -t rsa" and save the key pair such as ~/Downloads/sshkey and ~/Downloads/sshkey.pub

2) Provide the location of public_key and private_key as variables in provider_cred.tfvars file.

3) For Palo Alto Networks VM-Series initial configuration, using bootstrap option will significantly simplify setup. It can be done by creating IAM role, creating bootstrap bucket structure, and uploading pre-defined config files. For detailed steps, please follow the steps 1, 2 and 3 from the following URL:
https://docs.aviatrix.com/HowTos/bootstrap_example.html


4) Provide other info such as controller_ip, aws_access_key, etc as necessary in provider_cred.tfvars file as well. Make sure the variable names of bootstrap_role and bootstrap_bucket matches the actual names that you have used in the above step. In the example below, "bootstrap-VM-S3-role" is used for bootstrap_role and "bootstrap-firenet-bucket" is used for bootstrap_bucket.
> aws_region     = "Enter_AWS_region"  
> aws_access_key = "Enter_AWS_access_key"  
> aws_secret_key = "Enter_AWS_secret_key"  
> aviatrix_controller_ip       = "Enter_your_controller_IP"  
> aviatrix_controller_username = "Enter_your_controller_username"  
> aviatrix_controller_password = "Enter_your_controller_password"  
> aviatrix_aws_access_account  = "Enter_your_AWS_access_account"  
> public_key = "\~/Downloads/sshkey.pub"  
> private_key = "\~/Downloads/sshkey"  
> bootstrap_role = "bootstrap-VM-S3-role"  
> bootstrap_bucket = "bootstrap-firenet-bucket"

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

Total Test Time = \~37min (Create=\~30min Destroy=\~7min)

### Test Result

Check **result.txt** file in the same terraform script location. It should say **"PASS"** or **"FAIL"**.

### Troubleshoot

If test result is "FAIL" or user needs to check more info, check **log.txt** file in the same terraform script location after the run.
