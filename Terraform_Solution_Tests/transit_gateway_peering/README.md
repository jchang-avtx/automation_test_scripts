## Transit Gateway Peering Test

### Description

This Terraform configuration creates Spoke VPC, Transit VPC, onPrem VPC. Then, it creates Aviatrix Transit GW in Transit VPC and Aviatrix Spoke GW in Spoke VPC. And then, it  attaches Spoke VPC to Transit VPC. Also, it makes connection between Aviatrix Transit GW and OnPrem AWS VGW. This completes the left half of the topology involving Spoke-Transit-onPrem. The same topology is mirrored on the right half of the topology and after that, both left and right Aviatrix Transit GWs are peered together. After that, end-to-end traffic is tested between ubuntu instances in order to verify Spoke-Spoke and Spoke-OnPrem connectivities are working along with Transit Peering topology. After test is done, copy the result output from the remote host to the local machine.

> ***Note***: This test requires to assign 6 VPCs and 8 Elastic IP addresses. Before start testing, please make sure the target AWS region can accommodate enough resources. If there are not enough resources, you may also request a service limit increase by creating an AWS support case.

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

Total Test Time = \~23min (Create=\~14min Destroy=\~9min)

### Test Result

Check **result.txt** file in the same terraform script location. It should say **"PASS"** or **"FAIL"**.

### Troubleshoot

If test result is "FAIL" or user needs to check more info, check **log.txt** file in the same terraform script location after the run.
